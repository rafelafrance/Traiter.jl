module Traits

import Base.parse, Base.==, Base.replace
import DataStructures.OrderedSet

include("Rule.jl")
include("Group.jl")
include("Token.jl")
include("Parser.jl")

abstract type Trait end

export Trait,
       Rule, Rules, fragment, keyword, replacer, producer,
       Group, Groups,
       Token, Tokens, firstoffset, lastoffset,
       Parser, parse
end
