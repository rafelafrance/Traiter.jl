using Traits

@testset "Parser.scan" begin
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"bb")
    rule_c = Rule("rulec", r"cc")
    rule_bc = Rule("rulebc", r"bc")
    scanners = [rule_a, rule_b, rule_c, rule_bc]

    # It works
    expect = [Token(rule_b, RegexMatch("bb", [], 3, [], r"bb"))]
    actual = Traits.scan(scanners, "..bb....")
    @test actual == expect

    # It returns empty list
    expect = []
    actual = Traits.scan(scanners, "........")
    @test actual == expect

    # It returns multiple tokens
    expect = [Token(rule_b, RegexMatch("bb", [], 3, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 6, [], r"cc"))]
    actual = Traits.scan(scanners, "..bb.cc.")
    @test actual == expect

    # It handles overlapping text
    expect = [Token(rule_b, RegexMatch("bb", [], 2, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 4, [], r"cc"))]
    actual = Traits.scan(scanners, ".bbcc.")
    @test actual == expect

    # It handles all text
    expect = [Token(rule_b, RegexMatch("bb", [], 1, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 3, [], r"cc"))]
    actual = Traits.scan(scanners, "bbcc")
    @test actual == expect
end
