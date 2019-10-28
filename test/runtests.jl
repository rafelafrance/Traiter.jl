using SafeTestsets


@safetestset "Rule.jl" begin
    include("Rule/fragment.jl")
end


@safetestset "Parser.jl" begin
    include("Parser/getmatches.jl")
    include("Parser/remove_overlapping.jl")
    include("Parser/scan.jl")
end
