module Traiter

const INT = UInt32


export Trait, Traits,
       Vocabulary, add, token,
       Scanner, scan, Tokens,
       TEXT, CANON, GENUS, FIRST, LAST, LEMMA, POS, COLS,
       Rules, Rule, Predicate,
       match

import Base.==
import DataStructures.Stack


abstract type Trait end
const Traits = Array{Trait}


for i in ["vocabulary", "scanner", "ruler", "matcher"]
  include("traiter/$(i).jl")
end

end
