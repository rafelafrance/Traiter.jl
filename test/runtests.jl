using SafeTestsets

@safetestset "Function test2" begin include("my_function_tests.jl") end

@safetestset "Derivative test" begin include("my_derivative_tests.jl") end
