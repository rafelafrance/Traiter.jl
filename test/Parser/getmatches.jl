using Traits

@testset "Parser.getmaches" begin
    # Rules to use for the tests
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"bb")
    rules = [rule_a, rule_b]

    # It works at all
    actual = Traits.getmatches(rules, "aa")
    expect = [Token(rule_a, Dict(), 1, 2)]
    @test actual == expect

    # # It handles no matches
    matches = Traits.getmatches(rules, "ccc")
    @test matches == []

    # # It gets multiple matches
    actual = Traits.getmatches(rules, "aa bb")
    expect = [Token(rule_a, Dict(), 1, 2),
              Token(rule_b, Dict(), 4, 5)]
    @test actual == expect

    # It sorts matches by starting offset
    actual = Traits.getmatches(rules, "bb aa")
    expect = [Token(rule_b, Dict(), 1, 2),
              Token(rule_a, Dict(), 4, 5)]
    @test actual == expect

    # It skips noise charaters
    actual = Traits.getmatches(rules, "bb cc aa")
    expect = [Token(rule_b, Dict(), 1, 2),
              Token(rule_a, Dict(), 7, 8)]
    @test actual == expect

    # It does not return overlapping matches
    actual = Traits.getmatches(rules, "bbbaa")
    expect = [Token(rule_b, Dict(), 1, 2),
              Token(rule_a, Dict(), 4, 5)]
    @test actual == expect

    # It handles another overlapping match test
    actual = Traits.getmatches(rules, "aaaaa")
    expect = [Token(rule_a, Dict(), 1, 2),
              Token(rule_a, Dict(), 3, 4)]
    @test actual == expect

end
