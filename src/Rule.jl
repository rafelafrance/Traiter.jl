struct Rule
    name::Symbol
    regex::Regex
    action::Union{Function,Nothing}
end


Rule(name::String, regex, action) = Rule(Symbol(name), regex, action)
Rule(name::String, regex) = Rule(Symbol(name), regex, nothing)
Rule(name::Symbol, regex) = Rule(name, regex, nothing)


const Rules = Array{Rule}
const Patterns = Union{String,Array{String}}


function ==(a::Rule, b::Rule)
    a_regex = filter(x -> !isspace(x), a.regex.pattern)
    b_regex = filter(x -> !isspace(x), b.regex.pattern)
    a.name == b.name && a_regex == b_regex && a.action == b.action
end


function first_match(rule::Rule, text::String)::Dict{Symbol,String}
    m = match(rule.regex, text)
    Dict(Symbol(x) => m[x] for x in values(Base.PCRE.capture_names(m.regex.regex)) if !isnothing(m[x]))
end


function tokenize(re::String)::String
    # Find tokens in the regex. Look for words that are not part of a group
    # name or a metacharacter. So, "word" not "<word>". Neither "?P" nor "\b".
    word = r"""
        (?<! [?\\] ) (?<! < \s ) (?<! < )
        \b (?<word> [a-z]\w* ) \b
        (?! \s* > )
        """xi

    replace(re, word => s"\g<word>;")
end


build(str::String)::String = join(split(str), " ")
build(strs::Array{String})::String = build(join(strs, " | "))


function fragment(name::String, re::Patterns)::Rule
    re = build(re)
    re = Regex("(?<$name> $re )", "xi")
    Rule(Symbol(name), re)
end


function keyword(name::String, re::Patterns)::Rule
    re = build(re)
    re = Regex(raw"\b" * "(?<$name> $re )" * raw"\b", "xi")
    Rule(Symbol(name), re)
end


function replacer(name::String, re::Patterns)::Rule
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(Symbol(name), re)
end


SUFFIX = 0


function producer(func::Function, re::Patterns)::Rule
    global SUFFIX
    SUFFIX += 1
    name = "producer_$SUFFIX"
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(Symbol(name), re, func)
end
