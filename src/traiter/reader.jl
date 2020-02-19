function jsonl(filename, vocab::Vocabulary)
    rules::Rules = []
    for line in eachline(filename)
        rule::Rule = []
        raw = JSON.parse(line)
        for predicate in raw
            append!(rule, parse_predicate(vocab, predicate))
        end
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
                # This is an error
            end
        else
            # This is an error
        end
    end
    # Need to check fields before building
    [Predicate(field, aux, rep_lo, rep_hi, greedy, phrases, func)]
end
