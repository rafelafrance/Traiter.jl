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

function replace(rules::Rules, tokens::Tokens, text::String)::Tuple{Tokens,Bool}
    tokens = Token[]
    token_text = join([t.rule.name for t in tokens], TOKEN_SEPARATOR)
    matches = getmatches(rules, token_text)
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
    sort!(matches, by = x -> x.first, alg = MergeSort)
end

"""
Remove matches that overlap the current match.
"""
function remove_overlapping!(tokens::Tokens, match::Token)
    while length(tokens) > 0 && tokens[1].first <= match.last
        popfirst!(tokens)
    end
end

"""
Merge all matched tokens into one token.
"""
function merge_tokens(
    match::Token,
    tokens::Tokens,
    token_text::String,
    text::String,
)::Tuple{Token,Int,Int}
    # Get tokens in the match
    first_idx = length(matchall(TOKEN_SEPARATOR_RE, token_text[1:match.first]))
    last_idx = length(matchall(TOKEN_SEPARATOR_RE, token_text[1:match.last]))

    # Merge groups from all of the sub-tokens
    groups = merge([t.groups for t in tokens[first_idx:last_idx]])

    # Add groups from the current token
    for group in token.groups
        idx1 = length(matchall(TOKEN_SEPARATOR_RE, token_text[1:match.first]))
        idx2 = length(matchall(TOKEN_SEPARATOR_RE, token_text[1:match.last]))
        groups[group] = text[tokens[idx1].first:tokens[idx2.last]]
    end

    newtoken = Token(match.rule, groups, tokens[first_idx].first, tokens[last_idx].last)
    newtoken, first_idx, last_idx
end
