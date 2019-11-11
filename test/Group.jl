using Traiter

@testset "Group.==" begin
    @test Traiter.Group("aa", 1, 2) == Traiter.Group("aa", 1, 2)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("ab", 1, 2)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("aa", 1, 3)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("aa", 2, 2)
end
