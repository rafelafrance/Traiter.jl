using Traits

@testset "Group.==" begin
    @test Traits.Group("aa", 1, 2) == Traits.Group("aa", 1, 2)
    @test Traits.Group("aa", 1, 2) != Traits.Group("ab", 1, 2)
    @test Traits.Group("aa", 1, 2) != Traits.Group("aa", 1, 3)
    @test Traits.Group("aa", 1, 2) != Traits.Group("aa", 2, 2)
end
