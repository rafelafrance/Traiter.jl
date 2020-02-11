@testset "group" begin

@testset "Group(SubString{AbstractString}, Integer, Integer)" begin
    strings = split("aa bb")
    @test Traiter.Group(strings[1], 1, 2) == Group("aa", 1, 2)
end

@testset "group.==" begin
    @test Traiter.Group("aa", 1, 2) == Traiter.Group("aa", 1, 2)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("ab", 1, 2)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("aa", 1, 3)
    @test Traiter.Group("aa", 1, 2) != Traiter.Group("aa", 2, 2)
end

end
