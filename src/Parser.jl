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
        token = popfirst!(matches)
        push!(tokens, token)
        remove_overlapping!(matches, token)
    end
    tokens
end


function replace(rules::Rules, tokens::Tokens, text::String)::Tuple{Tokens,Bool}
    tokens = Token[]
    again = False
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
    sort!(matches, by = x -> x.span.first, alg = MergeSort)
end


"""
Remove matches that overlap the current match.
"""
function remove_overlapping!(tokens::Tokens, token::Token)
    while length(tokens) > 0 && tokens[1].span.first <= token.span.last
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
    first_idx = length(matchall(r";", text[1:match.offset]))
    last_idx = length(matchall(r";", text[1:match.offset+length(match.match)]))
    match, 0, 0
end
