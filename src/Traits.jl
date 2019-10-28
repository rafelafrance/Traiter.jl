module Traits

import Base.parse, Base.==, Base.replace

include("Rule.jl")
include("Token.jl")
include("Parser.jl")

abstract type Trait end

export Trait,
       Rule, Rules, first_match, fragment, keyword, replacer, producer,
       Token, Tokens, Parser, parse

end
