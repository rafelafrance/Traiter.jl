const TOKEN_SEPARATOR = ";"
const TOKEN_SEPARATOR_RE = Regex(TOKEN_SEPARATOR)

struct Rule
    name::String
    regex::Regex
    action::Union{Function,Nothing}
end

const Rules = Array{Rule}
const Patterns = Union{String,Array{String}}

Rule(name, regex) = Rule(name, regex, nothing)

function ==(a::Rule, b::Rule)
    a_regex = filter(x -> !isspace(x), a.regex.pattern)
    b_regex = filter(x -> !isspace(x), b.regex.pattern)
    a.name == b.name && a_regex == b_regex && a.action == b.action
end

function tokenize(re::String)::String
    word = r"(?<! [\\] ) (?<! \(\?< ) \b (?<word> [a-z]\w* ) \b "xi
    Base.replace(
        re,
        word => SubstitutionString(raw"\g<word>" * TOKEN_SEPARATOR),
    )
end

build(str::String)::String = join(split(str), " ")
build(strs::Array{String})::String = build(join(strs, " | "))

function fragment(name::String, re::Patterns)::Rule
    re = build(re)
    re = Regex("(?<$name> $re )", "xi")
    Rule(name, re)
end

function keyword(name::String, re::Patterns)::Rule
    re = build(re)
    re = Regex(raw"\b" * "(?<$name> $re )" * raw"\b", "xi")
    Rule(name, re)
end

function replacer(name::String, re::Patterns)::Rule
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(name, re)
end

producer_count = 0
function producer(action::Function, re::Patterns)::Rule
    global producer_count
    producer_count += 1
    name = "producer_$producer_count"
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(name, re, action)
end
