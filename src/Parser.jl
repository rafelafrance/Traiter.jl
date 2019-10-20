struct Parser
    scanners::Array{Rule}
    parsers::Array{Rule}
    # state::Dict{Symbol, Any}
    Parser(s, p) = new(s, p)  #, dict())
    # Parser(s, p, d) = new(s, p, d)
end


function parse(parser::Parser, text::String)::Array{Token}
    return Token[]
end


function scan(parser::Parser, text::String)::Array{Token}
    tokens = Token[]
    matches = getmatches(parser.scanners, text)

    while length(matches) > 0
        token = popfirst!(matches)
        push!(tokens, token)
        remove_overlapping!(matches, token)
    end
    tokens
end


"""
Get all matches for a list of rules against the text. The list is sorted by
starting position. The sort is stable so if multiple rules match at a position
then the first rule in the list wins.
"""
function getmatches(rules::Array{Rule}, text::String)::Array{Token}
    matches = [(r, collect(eachmatch(r.regex, text))) for r in rules]
    matches = [Token(match[1].name, m) for match in matches for m in match[2]]
    sort!(matches, by=x -> x.match.offset, alg=MergeSort)
end


"""
Remove matches that overlap the current match.
"""
function remove_overlapping!(tokens::Array{Token}, token::Token)
    last = token.match.offset + length(token.match.match)
    while length(tokens) > 0 && tokens[1].match.offset < last
        popfirst!(tokens)
    end
end
