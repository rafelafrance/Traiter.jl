const Phrase = Vector{INT}
const Phrases = Vector{Phrase}

mutable struct Predicate
    field::INT
    aux::INT     # Information for matched tokens
    rep_lo::INT
    rep_hi::INT
    greedy::Bool
    phrases::Phrases
    func::Function
    Predicate() = new(0, 0, 0, 0, true, [])
    Predicate(f, a, l, h, g, p, fn) = new(f, a, l, h, g, p, fn)
end


struct Result
    phrase_idx::INT
    repeat_idx::INT
    length::INT
    success::Bool
end


const Rule = Vector{Predicate}
const Rules = Vector{Rule}


==(a::Predicate, b::Predicate) =
    (a.field, a.aux, a.rep_lo, a.rep_hi, a.greedy, a.phrases) ==
    (b.field, b.aux, b.rep_lo, b.rep_hi, b.greedy, b.phrases)


to_phrase(vocab::Vocabulary, str::AbstractString)::Phrase =
    [add(vocab, s) for s in split(str)]

to_phrases(vocab::Vocabulary, str::AbstractString)::Phrases =
    [to_phrase(vocab, str)]

to_phrases(vocab::Vocabulary, strs::Vector{Any})::Phrases =
    [to_phrase(vocab, s) for s in strs]
