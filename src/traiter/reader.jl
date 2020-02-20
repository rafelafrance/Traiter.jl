function jsonl(filename, vocab::Vocabulary)
    rules::Rules = []
    for line in eachline(filename)
        rule::Rule = []
        raw = JSON.parse(line, inttype=INT)
        for predicate in raw
            append!(rule, parse_predicate(vocab, predicate))
        end
        append!(rules, [rule])
    end
end


function json(filename, vocab::Vocabulary)
    rules::Rules = []
    json = JSON.parsefile(filename, inttype=INT)
    for raw in json
        rule::Rule = []
        for predicate in raw
            append!(rule, parse_predicate(vocab, predicate))
        end
        append!(rules, [rule])
    end
end


function parse_predicate(vocab::Vocabulary, predicate::Dict)::Vector{Predicate}
    field::INT = 0
    rep_lo::INT = 1
    rep_hi::INT = 1
    greedy::Bool = true
    phrases = []
    aux = ""
    func = PREDICATES["isin"]

    for (key, value) in predicate
        key = lowercase(key)

        if key in keys(FIELD)
            field = FIELD[key]
            phrases = to_phrases(vocab, value)
        elseif key == "aux"
            aux = add(vocab, value)
        elseif key == "rep"
            if isa(value, Vector)
                rep_lo, rep_hi = value
            elseif value == "?"
                rep_lo, rep_hi = 0, 1
            elseif value == "*"
                rep_lo, rep_hi = 0, MAXINT
            elseif value == "+"
                rep_lo, rep_hi = 1, MAXINT
            else
                # TODO This is an error
            end
        else
            # TODO This is an error
        end
    end
    # TODO Validate before returning
    [Predicate(field, aux, rep_lo, rep_hi, greedy, phrases, func)]
end
