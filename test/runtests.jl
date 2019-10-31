using SafeTestsets


@safetestset "Rule.jl" begin
    include("Rule.jl")
end


@safetestset "Token.jl" begin
    include("Token.jl")
end


@safetestset "Parser.jl" begin
    include("Parser/getmatches.jl")
    include("Parser/remove_overlapping.jl")
    include("Parser/scan.jl")
end
