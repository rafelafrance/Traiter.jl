module Traiter

export Trait, Traits, Rule, Rules, fragment, keyword, replacer, producer,
       Group, Groups, GroupDict, Token, Tokens, Parser, parse

import Base.parse, Base.==, Base.replace
import DataStructures.OrderedSet

abstract type Trait end
const Traits = Array{Trait}

for i in ["rule", "group", "token", "parser"]
  include("traiter/$(i).jl")
end

end
