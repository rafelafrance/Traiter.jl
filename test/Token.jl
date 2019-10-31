using Traits

@testset "Token.Token" begin
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"..(?<bs>bb)(?<cs>cc)(?<ds>dd)?")

    m = match(rule_a.regex, "aa")
    actual = Token(rule_a, m)
    expect = Token(rule_a, Dict(), 1, 2)
    @test actual == expect

    m = match(rule_b.regex, "aabbcc")
    actual = Token(rule_b, m)
    expect = Token(rule_b, Dict("bs" => "bb", "cs" => "cc"), 1, 6)
    @test actual == expect
end

@testset "Token.last" begin
    @test Traits.last(match(r"aa", "aaa")) == 2
    @test Traits.last(match(r"aa", "baaa")) == 3
end
