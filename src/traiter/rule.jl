const Phrase = Array[]

mutable struct Predicate
    field::Int64
    name::Int64     # Information for matched tokens
    phrases::UnitRange{Int32}
    rep_lo::Int32
    rep_hi::Int32
    greedy::Bool
    Predicate() = new(0, 0, UnitRange(0, 0), 0, 0, true)
end

==(a::Predicate, b::Predicate) =
    (a.field, a.name, a.phrases, a.rep_lo, a.rep_hi, a.greedy) ==
    (b.field, b.name, b.phrases, b.rep_lo, b.rep_hi, b.greedy)

const Rule = Array{Predicate}
const Rules = Array{Rule}
