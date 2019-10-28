struct Token
    rule::Rule
    groups::Dict{String,Any}
    span::NamedTuple{(:first, :last), Tuple{Int,Int}}
end

function Token(rule::Rule, matched::RegexMatch)
    first = matched.offset
    last = matched.offset + length(matched.match) - 1

    if length(matched.captures) == 0
        groups = Dict()
    else
        groups = [k => matched[k] for k in Base.PCRE.capture_names(matched.regex) if matched[k] != nothing]
    end
    Token(rule, groups, (first=first, last=last))
end


const Tokens = Array{Token}


function ==(a::Token, b::Token)
    a.rule == b.rule && a.groups == b.groups && a.span == b.span
end
