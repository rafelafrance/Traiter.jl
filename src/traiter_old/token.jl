mutable struct Token
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

==(a::Token, b::Token) = (a.rule, a.groups) == (b.rule, b.groups)
firstoffset(t::Token)::Integer = minimum(g -> minimum(x -> x.first, g), values(t.groups))
lastoffset(t::Token)::Integer = maximum(g -> maximum(x -> x.last, g), values(t.groups))
lastoffset(i::Integer, s::Union{String,SubString{String}})::Integer = i + length(s) - 1
lastoffset(m::RegexMatch)::Integer = lastoffset(m.offset, m.match)
groupnames(match::RegexMatch)::Dict{Integer,String} = Base.PCRE.capture_names(match.regex.regex)
forget!(t::Token) = t.groups = GroupDict()

function addgroup!(groups::GroupDict, key::String, values::Groups)
    if haskey(groups, key)
        union!(groups[key], values)
    else
        groups[key] = values
    end
end

function addgroup!(groups::GroupDict, key::String, value::Group)
    if haskey(groups, key)
        push!(groups[key], value)
    else
        groups[key] = Groups([value])
    end
end
