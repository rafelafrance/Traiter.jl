using Test
using Traiter

for t in ["vocabulary", "ruler", "scanner"]
  include("traiter/$(t).jl")
end
