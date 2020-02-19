module Traiter

const INT = UInt32
const MAXINT = typemax(INT)


export Trait, Traits,
       Vocabulary, add, token,
       Scanner, scan, Tokens, FIELD, FIELDS,
       Rules, Rule, Predicate,
       match,
       jsonl

import Base.==
import DataStructures.Stack
import JSON


abstract type Trait end
const Traits = Array{Trait}


for i in ["vocabulary", "scanner", "ruler", "matcher", "reader"]
  include("traiter/$(i).jl")
end

end
