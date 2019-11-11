using Test
using Traiter

for t in ["rule", "group", "token", "parser"]
  include("traiter/$(t).jl")
end
