@testset "rule" begin

@testset "rule.tokenize" begin
    @test Traiter.tokenize("aa bb") == "(?: aa; ) (?: bb; )"
    @test Traiter.tokenize(raw"\b aa bb") == raw"\b (?: aa; ) (?: bb; )"
    @test Traiter.tokenize(raw"(?<aa> bb) cc") == raw"(?<aa> (?: bb; )) (?: cc; )"
end


@testset "rule.build" begin
    @test Traiter.build(" aa   bb ") == "aa bb"
    @test Traiter.build(["aa ", "  bb  "]) == "aa | bb"
end

@testset "rule.fragment" begin
    func(x) = 2x
    @test fragment("test", "aa") == Rule("test", r"(?<test> aa )"xi)
    @test fragment("test", ["aa", "bb"]) == Rule(
        "test",
        r"(?<test> aa | bb )"xi,
    )
    @test fragment("test", ["aa", "bb"], func) == Rule(
        "test",
        r"(?<test> aa | bb )"xi,
        func,
    )
end

@testset "rule.keyword" begin
    func(x) = 2x
    @test keyword("test", "aa") == Rule("test", r"\b(?<test> aa )\b"xi)
    @test keyword("test", ["aa", "bb"]) == Rule(
        "test",
        r"\b(?<test> aa | bb )\b"xi,
    )
    @test keyword("test", ["aa", "bb"]) == Rule(
        "test",
        r"\b(?<test> aa | bb )\b"xi,
    )
    @test keyword("test", ["aa", "bb"], func) == Rule(
        "test",
        r"\b(?<test> aa | bb )\b"xi,
        func,
    )
end

@testset "rule.replacer" begin
    func(x) = 2x
    @test replacer("test", "aa") == Rule("test", r"\b (?<test> (?:aa;) )"xi)
    @test replacer("test", ["aa", "bb"]) == Rule(
        "test",
        r"\b (?<test> (?: aa; ) | (?: bb; ) )"xi,
    )
    @test replacer("test", ["aa", "bb"], func) == Rule(
        "test",
        r"\b (?<test> (?: aa; ) | (?: bb; ) )"xi,
        func,
    )
end

@testset "rule.producer" begin
    dummy(x) = x + 1
    @test producer(dummy, "aa") == Rule(
        "producer_1",
        r"\b (?<producer_1> (?: aa; ) )"xi,
        dummy,
    )
    @test producer(dummy, ["aa", "bb"]) == Rule(
        "producer_2",
        r"\b (?<producer_2> (?: aa; ) | (?: bb; ) )"xi,
        dummy,
    )
end

end
