
using Traits

@testset "Parser.getmaches" begin
    # Rules to use for the tests
    rules = [Rule("rule_a", r"aa"), Rule("rule_b", r"bb")]

    # It works at all
    actual = Traits.getmatches(rules, "aa")
    expect = [Token("rule_a", RegexMatch("aa", [], 1, [], r"aa"))]
    @test actual == expect

    # It handles no matches
    matches = Traits.getmatches(rules, "ccc")
    @test matches == []

    # It gets multiple matches
    actual = Traits.getmatches(rules, "aa bb")
    expect = [Token("rule_a", RegexMatch("aa", [], 1, [], r"aa")),
              Token("rule_b", RegexMatch("bb", [], 4, [], r"bb"))]
    @test actual == expect

    # It sorts matches by starting offset
    actual = Traits.getmatches(rules, "bb aa")
    expect = [Token("rule_b", RegexMatch("bb", [], 1, [], r"bb")),
              Token("rule_a", RegexMatch("aa", [], 4, [], r"aa"))]
    @test actual == expect

    # It skips noise charaters
    actual = Traits.getmatches(rules, "bb cc aa")
    expect = [Token("rule_b", RegexMatch("bb", [], 1, [], r"bb")),
              Token("rule_a", RegexMatch("aa", [], 7, [], r"aa"))]
    @test actual == expect

    # It does not return overlapping matches
    actual = Traits.getmatches(rules, "bbbaa")
    expect = [Token("rule_b", RegexMatch("bb", [], 1, [], r"bb")),
              Token("rule_a", RegexMatch("aa", [], 4, [], r"aa"))]
    @test actual == expect

    # It handles another overlapping match test
    actual = Traits.getmatches(rules, "aaaaa")
    expect = [Token("rule_a", RegexMatch("aa", [], 1, [], r"aa")),
              Token("rule_a", RegexMatch("aa", [], 3, [], r"aa"))]
    @test actual == expect

end
