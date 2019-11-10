using SafeTestsets

@safetestset "Rule.jl" begin
    include("Rule.jl")
end

@safetestset "Group.jl" begin
    include("Group.jl")
end

@safetestset "Token.jl" begin
    include("Token.jl")
end

@safetestset "Parser.jl" begin
    include("Parser.jl")
end
