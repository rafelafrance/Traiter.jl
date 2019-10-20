using SafeTestsets

@safetestset "Function scan" begin
    include("Parser/getmatches.jl")
    include("Parser/remove_overlapping.jl")
    include("Parser/scan.jl")
end
