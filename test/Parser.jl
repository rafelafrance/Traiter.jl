using Traits

@testset "Parser.getmaches" begin
    # Rules to use for the tests
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"bb")
    rules = [rule_a, rule_b]

    # It works at all
    actual = Traits.getmatches(rules, "aa")
    expect = [Token(rule_a, match(rule_a.regex, "aa"))]
    @test actual == expect

    # It handles no matches
    matches = Traits.getmatches(rules, "ccc")
    @test matches == []

    # It gets multiple matches
    text = "aa bb"
    actual = Traits.getmatches(rules, text)
    expect = [Token(rule_a, match(rule_a.regex, text)),
              Token(rule_b, match(rule_b.regex, text))]
    @test actual == expect

    # It sorts matches by starting offset
    text = "bb aa"
    actual = Traits.getmatches(rules, text)
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It skips noise charaters
    text = "bb cc aa"
    actual = Traits.getmatches(rules, text)
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It does not return overlapping matches
    text = "bbbaa"
    actual = Traits.getmatches(rules, "bbbaa")
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It handles another overlapping match test
    text = "aaaaa"
    actual = Traits.getmatches(rules, text)
    matches = collect(eachmatch(rule_a.regex, text))
    @test actual == [Token(rule_a, matches[1]), Token(rule_a, matches[2])]
    @test firstoffset(actual[1]) == 1
    @test firstoffset(actual[2]) == 3
end

@testset "Parser.remove_overlapping!" begin
    text = "aaaaaaaa"
    rule = Rule("rule", r"a")
    tokens = [Token(rule, m) for m in eachmatch(rule.regex, text)]

    # It removes the first token
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, tokens[1])
    @test actual == copy(tokens)[2:end]

    # It removes the first few tokens
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, tokens[4])
    @test actual == copy(tokens)[5:end]

    # It removes all tokens
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, tokens[end])
    @test actual == []
end

@testset "Parser.firstindex" begin
    @test Traits.firstindex("11;22;33;", 1) == 1
    @test Traits.firstindex("11;22;33;", 2) == 1
    @test Traits.firstindex("11;22;33;", 3) == 2
    @test Traits.firstindex("11;22;33;", 4) == 2
    @test Traits.firstindex("11;22;33;", 5) == 2
    @test Traits.firstindex("11;22;33;", 6) == 3
    @test Traits.firstindex("11;22;33;", 7) == 3
    @test Traits.firstindex("11;22;33;", 8) == 3
    @test Traits.firstindex("11;22;33;", 9) == 4
end

@testset "Parser.lastindex" begin
    @test Traits.lastindex("11;22;33;", 1) == 0
    @test Traits.lastindex("11;22;33;", 2) == 0
    @test Traits.lastindex("11;22;33;", 3) == 1
    @test Traits.lastindex("11;22;33;", 4) == 1
    @test Traits.lastindex("11;22;33;", 5) == 1
    @test Traits.lastindex("11;22;33;", 6) == 2
    @test Traits.lastindex("11;22;33;", 7) == 2
    @test Traits.lastindex("11;22;33;", 8) == 2
    @test Traits.lastindex("11;22;33;", 9) == 3
end

@testset "Parser.merge_tokens" begin
    text = "..john smythe.."
    part = keyword("part", raw"\w+")
    full = replacer("full", "(?<first> part) (?<last> part)" )
    tokens = Traits.scan([part], text)
    tokentext = Traits.token_text(tokens)
    matched = Token(full, match(full.regex, tokentext))

    actual = Traits.merge_tokens(matched, tokens, tokentext, text)
    expect = Token(full, Dict(
        "first" => Groups([Group("john", 3, 6)]),
        "full" => Groups([Group("john smythe", 3, 13)]),
        "last"  => Groups([Group("smythe", 8, 13)]),
        "part"  => Groups([Group("john", 3, 6), Group("smythe", 8, 13)]),
    ))
    @test actual == (expect, 1, 2)
end

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
