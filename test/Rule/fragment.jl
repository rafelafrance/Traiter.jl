using Traits


@testset "Rule.fragment" begin
    @test fragment("test", "aa") == Rule("test", r"(?<test> aa )"xi)
    @test fragment("test", ["aa", "bb"]) == Rule("test", r"(?<test> aa | bb )"xi)
end


@testset "Rule.replacer" begin
    @test replacer("test", "aa") == Rule("test", r"\b (?<test> aa; )"xi)
    @test replacer("test", ["aa", "bb"]) == Rule("test", r"\b (?<test> aa; | bb; )"xi)
end
