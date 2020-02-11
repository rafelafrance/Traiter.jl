struct Parser
    name::String
    scanners::Rules
    replacers::Rules
    producers::Rules
end

Parser(; name = "parser", scanners = [], replacers = [], producers = []) =
    Parser(name, scanners, replacers, producers)

token_text(tokens::Tokens)::String =
    join([t.rule.name for t in tokens], token_separator) * token_separator

tokenindex(tokentext::String, idx::Integer)::Integer =
    length(collect(eachmatch(token_separator_re, tokentext[1:idx])))

firstindex(tokentext::String, idx::Integer)::Integer =
    tokenindex(tokentext, idx) + 1

lastindex(tokentext::String, idx::Integer)::Integer =
    tokenindex(tokentext, idx)

function parse(parser::Parser, text::String)::Tokens
    tokens = scan(parser.scanners, text)
    again = length(parser.replacers) > 0
    while again
        tokens, again = replace(parser.replacers, tokens, text)
    end
    produce(parser.producers, tokens, text)
end

function scan(rules::Rules, text::String)::Tokens
    tokens = Token[]
    matches = getmatches(rules, text)

    while length(matches) > 0
        match = popfirst!(matches)
        if !isnothing(match.rule.action)
            match.rule.action(match)
        end
        push!(tokens, match)
        remove_overlapping!(matches, match)
    end
    tokens
end

function replace(rules::Rules, tokens::Tokens, text::String)::Tuple{Tokens,Bool}
    replaced = Token[]
    tokentext = token_text(tokens)
    matches = getmatches(rules, tokentext)
    again = length(matches) > 0

    prev_first, prev_last = 1, 0
    while length(matches) > 0
        match = popfirst!(matches)
        token, first_idx, last_idx = merge_tokens(match, tokens, tokentext, text)
        if !isnothing(match.rule.action)
            match.rule.action(match)
        end
        if prev_last + 1 != first_idx
            append!(replaced, tokens[prev_first:first_idx-1])
        end
        push!(replaced, token)
        prev_first, prev_last = first_idx, last_idx
        remove_overlapping!(matches, match)
    end
    if prev_last != length(tokens)
        append!(replaced, tokens[prev_last+1:end])
    end

    replaced, again
end

function produce(rules::Rules, tokens::Tokens, text::String)::Tokens
    produced = Token[]
    tokentext = token_text(tokens)
    matches = getmatches(rules, tokentext)

    while length(matches) > 0
        match = popfirst!(matches)
        token, idx1, idx2 = merge_tokens(match, tokens, tokentext, text)
        push!(produced, token)
        remove_overlapping!(matches, match)
    end

    produced
end

function getmatches(rules::Rules, text::String)::Tokens
    pairs = [(r, collect(eachmatch(r.regex, text))) for r in rules]
    matches = [Token(p[1], m) for p in pairs for m in p[2]]
    sort!(matches, by = x -> firstoffset(x), alg = MergeSort)
end

function remove_overlapping!(tokens::Tokens, token::Token)
    while length(tokens) > 0 && firstoffset(tokens[1]) <= lastoffset(token)
        popfirst!(tokens)
    end
end

function merge_tokens(
    token::Token,
    tokens::Tokens,
    tokentext::String,
    text::String,
)::Tuple{Token,Integer,Integer}
    groups = GroupDict()
    names = groupnames(token.match)
    for (i, value) in enumerate(token.match.captures)
        offset = token.match.offsets[i]
        tkn1 = tokens[firstindex(tokentext, offset)]
        tkn2 = tokens[lastindex(tokentext, lastoffset(offset, value))]
        if length(tkn1.groups) == 0 || length(tkn2.groups) == 0
            continue
        end
        first = firstoffset(tkn1)
        last = lastoffset(tkn2)
        addgroup!(groups, names[i], Group(text[first:last], first, last))
    end

    newtokens = copy(tokens)
    push!(newtokens, Token(token.rule, groups, token.match))

    first_idx = firstindex(tokentext, firstoffset(token))
    last_idx = lastindex(tokentext, lastoffset(token))
    Token(token.rule, newtokens), first_idx, last_idx
end
