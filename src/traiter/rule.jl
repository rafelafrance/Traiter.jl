const token_separator = ";"
const token_separator_re = Regex(token_separator)

struct Rule
    name::String
    regex::Regex
    action::Union{Function,Nothing}
end

const Rules = Array{Rule}

Rule(name, regex) = Rule(name, regex, nothing)

function ==(a::Rule, b::Rule)
    a_regex = filter(x -> !isspace(x), a.regex.pattern)
    b_regex = filter(x -> !isspace(x), b.regex.pattern)
    a.name == b.name && a_regex == b_regex && a.action == b.action
end

function tokenize(re)
    word = r"(?<! [\\] ) (?<! \(\?< ) \b (?<word> [a-z]\w* ) \b "xi
    Base.replace(
        re,
        word => SubstitutionString(raw"\g<word>" * token_separator),
    )
end

build(str::AbstractString) = join(split(str), " ")
build(strs::Union{Array{String},Array{SubString{String}}}) = build(join(strs, " | "))
build(re::Regex) = build(re.pattern)

function fragment(name, re)
    re = build(re)
    re = Regex("(?<$name> $re )", "xi")
    Rule(name, re)
end

function keyword(name, re)
    re = build(re)
    re = Regex(raw"\b" * "(?<$name> $re )" * raw"\b", "xi")
    Rule(name, re)
end

function replacer(name, re)
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(name, re)
end

producer_count = 0
function producer(action, re)
    global producer_count
    producer_count += 1
    name = "producer_$producer_count"
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(name, re, action)
end
