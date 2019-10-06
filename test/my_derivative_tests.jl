using Traits

@testset "Derivative tests" begin
    @test derivative_of_my_f(2, 1) == 2
    @test derivative_of_my_f(2, 3) == 2
end
