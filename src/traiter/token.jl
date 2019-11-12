struct Token
    rule::Rule
    groups::GroupDict
    match::Union{RegexMatch,Nothing}
end

const Tokens = Array{Token}

Token(rule::Rule, groups::GroupDict) = Token(rule, groups, nothing)

function Token(rule::Rule, dict::Dict{String,Group})
    Token(rule, GroupDict(k => Groups([v]) for (k, v) in dict))
end

function Token(rule::Rule, match::RegexMatch)
    groups = GroupDict()
    for (idx, name) in groupnames(match)
        value = match.captures[idx]
        if !isnothing(value)
            first = match.offsets[idx]
            last = lastoffset(first, value)
            addgroup!(groups, name, Group(value, first, last))
        end
    end
    group = Group(match.match, match.offset, lastoffset(match))
    addgroup!(groups, rule.name, group)
    Token(rule, groups, match)
end

function Token(rule::Rule, tokens::Tokens)
    groups = GroupDict()
    for token in tokens
        for (name, group) in token.groups
            addgroup!(groups, name, group)
        end
    end
    Token(rule, groups)
end

function ==(a::Token, b::Token)
    a.rule == b.rule && a.groups == b.groups
end

firstoffset(t::Token) = minimum(g -> minimum(x -> x.first, g), values(t.groups))

lastoffset(t::Token) = maximum(g -> maximum(x -> x.last, g), values(t.groups))
lastoffset(i::Integer, s::Union{String,SubString{String}}) = i + length(s) - 1
lastoffset(m::RegexMatch) = lastoffset(m.offset, m.match)

groupnames(match) = Base.PCRE.capture_names(match.regex.regex)

function addgroup!(groups, key, values::Groups)
    if haskey(groups, key)
        union!(groups[key], values)
    else
        groups[key] = values
    end
end

function addgroup!(groups, key, value::Group)
    if haskey(groups, key)
        push!(groups[key], value)
    else
        groups[key] = Groups([value])
    end
end
