module Traiter

# const Int = UInt32


export Trait, Traits, Int,
       Vocabulary, Token, Tokens, tokenize, add, token,
       TokenGenus, WORD, NUM, PUNCT,
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
