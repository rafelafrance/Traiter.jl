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
    tokens = Token[]
    tokentext = token_text(tokens)
    matches = getmatches(rules, tokentext)
    again = length(matches) > 0

    while length(matches) > 0
        match = popfirst!(matches)

        remove_overlapping!(matches, match)
    end

    tokens, again
end

function produce(rules::Rules, tokens::Tokens, text::String)::Tokens
    Tokens[]
end

"""
Get all matches for a list of rules against the text. The list is sorted by
starting position. The sort is stable so if multiple rules match at a position
then the first rule in the list wins.
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
        first = firstoffset(tokens[idx1])
        last = lastoffset(tokens[idx2])
        value = text[first:last]
        addgroup!(groups, name, Group(value, first, last))
    end
    push!(tokens, Token(match.rule, groups))

    first_idx = firstindex(tokentext, firstoffset(match))
    last_idx = lastindex(tokentext, lastoffset(match))
    Token(match.rule, tokens), first_idx, last_idx
end
