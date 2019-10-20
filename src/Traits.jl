module Traits

import Base.parse, Base.==

include("Rule.jl")
include("Token.jl")
include("Parser.jl")

abstract type Trait end

export Trait, Rule, first_match, fragment, keyword, replacer, producer,
       Token, Parser, parse

end
