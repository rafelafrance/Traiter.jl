struct Token
    rule::Rule
    groups::GroupDict
    match::Union{RegexMatch,Nothing}
end

Token(rule, groups) = Token(rule, groups, nothing)

const Tokens = Array{Token}

function ==(a::Token, b::Token)
    a.rule == b.rule && a.groups == b.groups
end

firstoffset(t::Token) = t.match.offset

lastoffset(t::Token) = t.match.offset + length(t.match.match) - 1
lastoffset(i::Int, s::Union{String,SubString{String}}) = i + length(s) - 1
lastoffset(m::RegexMatch) = lastoffset(m.offset, m.match)

groupnames(match::RegexMatch) = Base.PCRE.capture_names(match.regex.regex)

function addgroup!(groups::GroupDict, name::String, group::Groups)
    if haskey(groups, name)
        union!(groups[name], group)
    else
        groups[name] = group
    end
end

function addgroup!(groups::GroupDict, name::String, group::Group)
    if haskey(groups, name)
        push!(groups[name], group)
    else
        groups[name] = Groups([group])
    end
end

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
