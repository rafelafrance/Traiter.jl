const Phrase = Vector{INT}
const Phrases = Vector{Phrase}

mutable struct Predicate
    field::INT
    aux1::INT     # Information for matched tokens
    rep_lo::INT
    rep_hi::INT
    greedy::Bool
    phrases::Phrases
    func::Function
    Predicate() = new(0, 0, 0, 0, true, [])
end


struct Result
    phrase_idx::INT
    repeat_idx::INT
    length::INT
    success::Bool
end


==(a::Predicate, b::Predicate) =
    (a.field, a.aux1, a.rep_lo, a.rep_hi, a.greedy, a.phrases) ==
    (b.field, b.aux1, b.rep_lo, b.rep_hi, b.greedy, b.phrases)

const Predicates = Vector{Predicate}
const Rule = Vector{Predicate}
const Rules = Vector{Rule}
