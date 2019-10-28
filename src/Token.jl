struct Token
    rule::Rule
    groups::Groups
    first::Int
    last::Int
end


function Token(rule::Rule, match::RegexMatch)
    if length(match.captures) == 0
        groups = Dict()
    else
        groups = [k => match[k]
                  for k in Base.PCRE.capture_names(match.regex)
                  if match[k] != nothing]
    end
    Token(rule, groups, match.offset, last(match))
end


const Tokens = Array{Token}


last(match::RegexMatch) = match.offset + length(match.match) - 1


function ==(a::Token, b::Token)
    a.rule == b.rule && a.groups == b.groups && a.first == b.first && a.last == b.last
end
