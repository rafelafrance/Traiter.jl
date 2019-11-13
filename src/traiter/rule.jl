const Action = Union{Function,Nothing}
const Patterns = Union{String,Array{String}}

struct Rule
    name::String
    regex::Regex
    action::Action
end

const Rules = Array{Rule}

const token_separator = ";"
const token_separator_re = Regex(token_separator)

Rule(name::String, regex::Regex) = Rule(name, regex, nothing)

build(str::AbstractString) = join(split(str), " ")
build(strs::Union{Array{String},Array{SubString{String}}}) =
    build(join(strs, " | "))
build(regex::Regex) = build(regex.pattern)

function ==(a::Rule, b::Rule)
    a_regex = filter(x -> !isspace(x), a.regex.pattern)
    b_regex = filter(x -> !isspace(x), b.regex.pattern)
    (a.name, a_regex, a.action) == (b.name, b_regex, b.action)
end

function tokenize(regex::String)
    word = r"(?<! [\\] ) (?<! \(\?< ) \b (?<word> [a-z]\w* ) \b "xi
    Base.replace(
        regex,
        word => SubstitutionString(raw"(?: \g<word>" * token_separator * " )"),
    )
end

function fragment(name::String, regex::Patterns, action::Action = nothing)
    regex = build(regex)
    regex = Regex("(?<$name> $regex )", "xi")
    Rule(name, regex, action)
end

function keyword(name::String, regex::Patterns, action::Action = nothing)
    regex = build(regex)
    regex = Regex(raw"\b" * "(?<$name> $regex )" * raw"\b", "xi")
    Rule(name, regex, action)
end

function replacer(name::String, regex::Patterns, action::Action = nothing)
    regex = build(regex)
    regex = tokenize(regex)
    regex = Regex(raw"\b" * "(?<$name> $regex )", "xi")
    Rule(name, regex, action)
end

producer_count = 0
function producer(action::Function, regex::Patterns)
    global producer_count
    producer_count += 1
    name = "producer_$producer_count"
    regex = build(regex)
    regex = tokenize(regex)
    regex = Regex(raw"\b" * "(?<$name> $regex )", "xi")
    Rule(name, regex, action)
end
