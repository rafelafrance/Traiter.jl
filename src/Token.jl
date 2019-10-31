struct Token
    rule::Rule
    groups::Dict
    first::Int
    last::Int
end

const Tokens = Array{Token}

function Token(rule::Rule, match::RegexMatch)
    groups = Dict()
    if length(match.captures) > 0
        names = values(Base.PCRE.capture_names(match.regex.regex))
        groups = Dict(n => match[n] for n in names if match[n] != nothing)
    end
    Token(rule, groups, match.offset, last(match))
end

last(match::RegexMatch) = match.offset + length(match.match) - 1

function ==(a::Token, b::Token)
    a.rule == b.rule &&
        a.groups == b.groups && a.first == b.first && a.last == b.last
end
