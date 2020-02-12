module Traiter

const SIZE = UInt32


export Trait, Traits,
       Vocabulary, Token, tokenize, add,
       Rules, Rule, Predicate,
       match

import Base.==
import DataStructures.Stack


abstract type Trait end
const Traits = Array{Trait}


for i in ["token", "rule", "matcher"]
  include("traiter/$(i).jl")
end

end
