const Phrase = Vector{SIZE}

mutable struct Predicate
    field::SIZE
    name::SIZE     # Information for matched tokens
    phrases::UnitRange{SIZE}
    rep_lo::SIZE
    rep_hi::SIZE
    greedy::Bool
    Predicate() = new(0, 0, UnitRange(0, 0), 0, 0, true)
end

==(a::Predicate, b::Predicate) =
    (a.field, a.name, a.phrases, a.rep_lo, a.rep_hi, a.greedy) ==
    (b.field, b.name, b.phrases, b.rep_lo, b.rep_hi, b.greedy)

const Rule = Array{Predicate}
const Rules = Array{Rule}
