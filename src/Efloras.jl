#!/usr/bin/env julia

module Efloras

using Traiter

for i in ["plant_color"]
  include("efloras/parsers/$(i).jl")
end

end
