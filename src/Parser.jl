struct Parser
    name::String
    scanners::Rules
    replacers::Rules
    producers::Rules
end

function parse(parser::Parser, text::String)::Tokens
    tokens = scan(parser.scanners, text)
    again = length(parser.replacers) != 0
    while again
        tokens, again = replace()
    end
    Token[]
end

function scan(rules::Rules, text::String)::Tokens
    tokens = Token[]
    matches = getmatches(rules, text)

    while length(matches) > 0
        match = popfirst!(matches)
        push!(tokens, match)
        remove_overlapping!(matches, match)
    end
    tokens
end

function token_text(tokens::Tokens)::String
    join([t.rule.name for t in tokens], TOKEN_SEPARATOR) * TOKEN_SEPARATOR
end

function replace(rules::Rules, tokens::Tokens, text::String)::Tuple{Tokens,Bool}
    replaced = Token[]
    tokentext = token_text(tokens)
    matches = getmatches(rules, tokentext)
    if length(matches) == 0
        return tokens, false
    end

    prev_idx = 1
    while length(matches) > 0
        match = popfirst!(matches)
        token, first_idx, last_idx = merge_tokens(
            match, tokens, tokentext, text)
        if prev_idx != first_idx
            append!(replaced, tokens[prev_idx:first_idx-1])
        end
        push!(replaced, token)
        prev_idx = last_idx
        remove_overlapping!(matches, match)
    end
    if prev_idx != length(tokens)
        append!(replaced, tokens[prev_idx+1:end])
    end

    replaced, true
end

function produce(rules::Rules, tokens::Tokens, text::String)::Tokens
    Tokens[]
end

"""
Get all matches for a list of rules against the text. The list is sorted by
starting position. The sort is stable, preserving insertion order.
"""
function getmatches(rules::Rules, text::String)::Tokens
    pairs = [(r, collect(eachmatch(r.regex, text))) for r in rules]
    matches = [Token(p[1], m) for p in pairs for m in p[2]]
    sort!(matches, by = x -> firstoffset(x), alg = MergeSort)
end

"""
Remove matches that overlap the current match.
"""
function remove_overlapping!(tokens::Tokens, match::Token)
    while length(tokens) > 0 && firstoffset(tokens[1]) <= lastoffset(match)
        popfirst!(tokens)
    end
end

"""
Merge all matched tokens into one token.

When a pattern of tokens (in replace or produce) is matched we need to gather
the data from all of the matched tokens and put it into a single token. For
instance if we want to replace the first_name and last_name tokens with a
full_name token.
"""

function tokenindex(tokentext::String, idx::Int)
    length(collect(eachmatch(TOKEN_SEPARATOR_RE, tokentext[1:idx])))
end
firstindex(tokentext::String, idx::Int) = tokenindex(tokentext, idx) + 1
lastindex(tokentext::String, idx::Int) = tokenindex(tokentext, idx)

function merge_tokens(
    match::Token,
    tokens::Tokens,
    tokentext::String,
    text::String,
)::Tuple{Token,Int,Int}
    groups = GroupDict()
    for (name, value) in match.groups
        idx1 = firstindex(tokentext, firstoffset(match, name))
        idx2 = lastindex(tokentext, lastoffset(match, name))
        if length(tokens[idx1].groups) == 0 || length(tokens[idx2].groups) == 0
            continue
        end
        first = firstoffset(tokens[idx1])
        last = lastoffset(tokens[idx2])
        addgroup!(groups, name, Group(text[first:last], first, last))
    end

    newtokens = copy(tokens)
    push!(newtokens, Token(match.rule, groups))

    first_idx = firstindex(tokentext, firstoffset(match))
    last_idx = lastindex(tokentext, lastoffset(match))
    Token(match.rule, newtokens), first_idx, last_idx
end
