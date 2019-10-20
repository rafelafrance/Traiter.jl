using Traits

@testset "Parser.scan" begin
    rules = [Rule("rule_a", r"aa"), Rule("rule_b", r"bb"),
             Rule("rule_c", r"cc"), Rule("rule_bc", r"bc")]
    parser = Traits.Parser(rules, [])

    # It works
    expect = [Token("rule_b", RegexMatch("bb", [], 3, [], r"bb"))]
    actual = Traits.scan(parser, "..bb....")
    @test actual == expect

    # It returns empty list
    expect = []
    actual = Traits.scan(parser, "........")
    @test actual == expect

    # It returns multiple tokens
    expect = [Token("rule_b", RegexMatch("bb", [], 3, [], r"bb")),
              Token("rule_c", RegexMatch("cc", [], 6, [], r"cc"))]
    actual = Traits.scan(parser, "..bb.cc.")
    @test actual == expect

    # It handles overlapping text
    expect = [Token("rule_b", RegexMatch("bb", [], 2, [], r"bb")),
              Token("rule_c", RegexMatch("cc", [], 4, [], r"cc"))]
    actual = Traits.scan(parser, ".bbcc.")
    @test actual == expect

    # It handles all text
    expect = [Token("rule_b", RegexMatch("bb", [], 1, [], r"bb")),
              Token("rule_c", RegexMatch("cc", [], 3, [], r"cc"))]
    actual = Traits.scan(parser, "bbcc")
    @test actual == expect

end
