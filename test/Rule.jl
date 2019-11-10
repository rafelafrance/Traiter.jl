using Traits

@testset "Rule.tokenize" begin
    @test Traits.tokenize("aa bb") == "aa; bb;"
    @test Traits.tokenize(raw"\b aa bb") == raw"\b aa; bb;"
    @test Traits.tokenize(raw"(?<aa> bb) cc") == raw"(?<aa> bb;) cc;"
end


@testset "Rule.build" begin
    @test Traits.build(" aa   bb ") == "aa bb"
    @test Traits.build(["aa ", "  bb  "]) == "aa | bb"
end

@testset "Rule.fragment" begin
    @test fragment("test", "aa") == Rule("test", r"(?<test> aa )"xi)
    @test fragment("test", ["aa", "bb"]) == Rule(
        "test",
        r"(?<test> aa | bb )"xi,
    )
end

@testset "Rule.keyword" begin
    @test keyword("test", "aa") == Rule("test", r"\b(?<test> aa )\b"xi)
    @test keyword("test", ["aa", "bb"]) == Rule(
        "test",
        r"\b(?<test> aa | bb )\b"xi,
    )
end

@testset "Rule.replacer" begin
    @test replacer("test", "aa") == Rule("test", r"\b (?<test> aa; )"xi)
    @test replacer("test", ["aa", "bb"]) == Rule(
        "test",
        r"\b (?<test> aa; | bb; )"xi,
    )
end

@testset "Rule.producer" begin
    dummy(x) = x + 1
    @test producer(dummy, "aa") == Rule(
        "producer_1",
        r"\b (?<producer_1> aa; )"xi,
        dummy,
    )
    @test producer(dummy, ["aa", "bb"]) == Rule(
        "producer_2",
        r"\b (?<producer_2> aa; | bb; )"xi,
        dummy,
    )
end
