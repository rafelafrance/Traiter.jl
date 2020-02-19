using Test
using Traiter

for t in ["vocabulary", "ruler", "scanner", "matcher", "reader"]
  include("traiter/$(t).jl")
end
