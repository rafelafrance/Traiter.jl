@testset "parser" begin

@testset "parser.getmaches" begin
    # Rules to use for the tests
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"bb")
    rules = [rule_a, rule_b]

    # It works at all
    actual = Traiter.getmatches(rules, "aa")
    expect = [Token(rule_a, match(rule_a.regex, "aa"))]
    @test actual == expect

    # It handles no matches
    matches = Traiter.getmatches(rules, "ccc")
    @test matches == []

    # It gets multiple matches
    text = "aa bb"
    actual = Traiter.getmatches(rules, text)
    expect = [Token(rule_a, match(rule_a.regex, text)),
              Token(rule_b, match(rule_b.regex, text))]
    @test actual == expect

    # It sorts matches by starting offset
    text = "bb aa"
    actual = Traiter.getmatches(rules, text)
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It skips noise charaters
    text = "bb cc aa"
    actual = Traiter.getmatches(rules, text)
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It does not return overlapping matches
    text = "bbbaa"
    actual = Traiter.getmatches(rules, "bbbaa")
    expect = [Token(rule_b, match(rule_b.regex, text)),
              Token(rule_a, match(rule_a.regex, text))]
    @test actual == expect

    # It handles another overlapping match test
    text = "aaaaa"
    actual = Traiter.getmatches(rules, text)
    matches = collect(eachmatch(rule_a.regex, text))
    @test actual == [Token(rule_a, matches[1]), Token(rule_a, matches[2])]
    @test Traiter.firstoffset(actual[1]) == 1
    @test Traiter.firstoffset(actual[2]) == 3
end

@testset "parser.remove_overlapping!" begin
    text = "aaaaaaaa"
    rule = Rule("rule", r"a")
    tokens = [Token(rule, m) for m in eachmatch(rule.regex, text)]

    # It removes the first token
    actual = copy(tokens)
    Traiter.remove_overlapping!(actual, tokens[1])
    @test actual == copy(tokens)[2:end]

    # It removes the first few tokens
    actual = copy(tokens)
    Traiter.remove_overlapping!(actual, tokens[4])
    @test actual == copy(tokens)[5:end]

    # It removes all tokens
    actual = copy(tokens)
    Traiter.remove_overlapping!(actual, tokens[end])
    @test actual == []
end

@testset "parser.firstindex" begin
    @test Traiter.firstindex("11;22;33;", 1) == 1
    @test Traiter.firstindex("11;22;33;", 2) == 1
    @test Traiter.firstindex("11;22;33;", 3) == 2
    @test Traiter.firstindex("11;22;33;", 4) == 2
    @test Traiter.firstindex("11;22;33;", 5) == 2
    @test Traiter.firstindex("11;22;33;", 6) == 3
    @test Traiter.firstindex("11;22;33;", 7) == 3
    @test Traiter.firstindex("11;22;33;", 8) == 3
    @test Traiter.firstindex("11;22;33;", 9) == 4
end

@testset "parser.lastindex" begin
    @test Traiter.lastindex("11;22;33;", 1) == 0
    @test Traiter.lastindex("11;22;33;", 2) == 0
    @test Traiter.lastindex("11;22;33;", 3) == 1
    @test Traiter.lastindex("11;22;33;", 4) == 1
    @test Traiter.lastindex("11;22;33;", 5) == 1
    @test Traiter.lastindex("11;22;33;", 6) == 2
    @test Traiter.lastindex("11;22;33;", 7) == 2
    @test Traiter.lastindex("11;22;33;", 8) == 2
    @test Traiter.lastindex("11;22;33;", 9) == 3
end

@testset "parser.merge_tokens" begin
    text = "..john smythe.."
    part = keyword("part", raw"\w+")
    full = replacer("full", "(?<first> part) (?<last> part)" )
    tokens = Traiter.scan([part], text)
    tokentext = Traiter.token_text(tokens)
    matched = Token(full, match(full.regex, tokentext))

    actual = Traiter.merge_tokens(matched, tokens, tokentext, text)
    expect = Token(full, Dict(
        "first" => Groups([Group("john", 3, 6)]),
        "full" => Groups([Group("john smythe", 3, 13)]),
        "last"  => Groups([Group("smythe", 8, 13)]),
        "part"  => Groups([Group("john", 3, 6), Group("smythe", 8, 13)]),
    ))
    @test actual == (expect, 1, 2)
end

@testset "parser.scan" begin
    rule_a = Rule("rulea", r"aa")
    rule_b = Rule("ruleb", r"bb")
    rule_c = Rule("rulec", r"cc")
    rule_bc = Rule("rulebc", r"bc")
    scanners = [rule_a, rule_b, rule_c, rule_bc]

    # It works
    expect = [Token(rule_b, RegexMatch("bb", [], 3, [], r"bb"))]
    actual = Traiter.scan(scanners, "..bb....")
    @test actual == expect

    # It returns empty list
    expect = []
    actual = Traiter.scan(scanners, "........")
    @test actual == expect

    # It returns multiple tokens
    expect = [Token(rule_b, RegexMatch("bb", [], 3, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 6, [], r"cc"))]
    actual = Traiter.scan(scanners, "..bb.cc.")
    @test actual == expect

    # It handles overlapping text
    expect = [Token(rule_b, RegexMatch("bb", [], 2, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 4, [], r"cc"))]
    actual = Traiter.scan(scanners, ".bbcc.")
    @test actual == expect

    # It handles all text
    expect = [Token(rule_b, RegexMatch("bb", [], 1, [], r"bb")),
              Token(rule_c, RegexMatch("cc", [], 3, [], r"cc"))]
    actual = Traiter.scan(scanners, "bbcc")
    @test actual == expect
end

@testset "parser.replace" begin
    yes = replacer("yes", "yes")
    yesyes = replacer("yesyes", "yes yes")
    no = replacer("no", "no")
    rep = replacer("test", "yes")
    rep2 = replacer("test", "yes yes")

    # It replaces one token
    tokens = [
        Token(no, GroupDict()),
        Token(yes, GroupDict()),
        Token(no, GroupDict()),
    ]
    (actual, flag) = replace([rep], tokens, "..yes..")
    expect = [
        Token(no, GroupDict()),
        Token(rep, GroupDict()),
        Token(no, GroupDict())
    ]
    @test actual == expect
    @test flag

    # It replaces multiple tokens
    tokens = [
        Token(no, GroupDict()),
        Token(yes, GroupDict()), Token(yes, GroupDict()),
        Token(no, GroupDict())
    ]
    (actual, flag) = replace([rep2], tokens, "..yes.yes.")
    expect = [
        Token(no, GroupDict()),
        Token(rep2, GroupDict()),
        Token(no, GroupDict())]
    @test actual == expect
    @test flag

    # It replaces the first token
    tokens = [Token(yes, GroupDict()), Token(no, GroupDict())]
    (actual, flag) = replace([rep], tokens, "..yes..")
    expect = [Token(rep, GroupDict()), Token(no, GroupDict())]
    @test actual == expect
    @test flag

    # It replaces the last token
    tokens = [Token(no, GroupDict()), Token(yes, GroupDict())]
    (actual, flag) = replace([rep], tokens, "..yes..")
    expect = [Token(no, GroupDict()), Token(rep, GroupDict())]
    @test actual == expect
    @test flag

    # It replaces no tokens
    tokens = [Token(no, GroupDict()), Token(no, GroupDict())]
    (actual, flag) = replace([rep], tokens, "..yes..")
    expect = [Token(no, GroupDict()), Token(no, GroupDict())]
    @test actual == expect
    @test !flag

    # It replaces all tokens
    tokens = [Token(yes, GroupDict()), Token(yes, GroupDict())]
    (actual, flag) = replace([rep2], tokens, "..yes.yes.")
    expect = [Token(rep2, GroupDict())]
    @test actual == expect
    @test flag

    # It replaces multiple times
    tokens = [Token(yes, GroupDict()), Token(yes, GroupDict())]
    (actual, flag) = replace([rep], tokens, "..yes.yes.")
    expect = [Token(rep, GroupDict()), Token(rep, GroupDict())]
    @test actual == expect
    @test flag
end

@testset "parser.produce" begin
    dummy(x) = 2x
    yes = replacer("yes", "yes")
    yesyes = replacer("yesyes", "yes yes")
    no = replacer("no", "no")
    prod = producer(dummy, "yes")
    prod2 = producer(dummy, "yes yes")

    # It produces from one token
    tokens = [Token(no, GroupDict()),
              Token(yes, GroupDict()),
              Token(no, GroupDict())]
    actual = Traiter.produce([prod], tokens, "..yes..")
    expect = [Token(prod, GroupDict())]
    @test actual == expect

    # It produces from multiple tokens
    tokens = [
        Token(no, GroupDict()),
        Token(yes, GroupDict()), Token(yes, GroupDict()),
        Token(no, GroupDict())
    ]
    actual = Traiter.produce([prod2], tokens, "..yes.yes.")
    expect = [Token(prod2, GroupDict())]
    @test actual == expect

    # It produces from the first token
    tokens = [Token(yes, GroupDict()), Token(no, GroupDict())]
    actual = Traiter.produce([prod], tokens, "..yes..")
    expect = [Token(prod, GroupDict())]
    @test actual == expect

    # It produces from the last token
    tokens = [Token(no, GroupDict()), Token(yes, GroupDict())]
    actual = Traiter.produce([prod], tokens, "..yes..")
    expect = [Token(prod, GroupDict())]
    @test actual == expect

    # No products
    tokens = [Token(no, GroupDict()), Token(no, GroupDict())]
    actual = Traiter.produce([prod], tokens, "..yes..")
    expect = []
    @test actual == expect

    # It produces from all tokens
    tokens = [Token(yes, GroupDict()), Token(yes, GroupDict())]
    actual = Traiter.produce([prod2], tokens, "..yes.yes.")
    expect = [Token(prod2, GroupDict())]
    @test actual == expect

    # It produces multiple times
    tokens = [Token(yes, GroupDict()), Token(yes, GroupDict())]
    actual = Traiter.produce([prod], tokens, "..yes.yes.")
    expect = [Token(prod, GroupDict()), Token(prod, GroupDict())]
    @test actual == expect
end

@testset "parser.parse" begin
    fun(x) = 2x
    scn = keyword("yes", "yes")
    rep = replacer("repl", "yes")
    prod = producer(fun, "repl")

    rep2_1 = replacer("repl2_1", "yes")
    rep2_2 = replacer("repl2_2", "repl2_1")
    prod2 = producer(fun, "repl2_2")

    # It parses
    parser = Parser("Test", [scn], [rep], [prod])
    actual = parse(parser, "..yes..no..")
    expect = [Token(prod, Dict(
        "yes" => Groups([Group("yes", 3, 5)]),
        "repl" => Groups([Group("yes", 3, 5)]),
        prod.name => Groups([Group("yes", 3, 5)]),
    ))]
    @test actual == expect

    # It does a double replace
    parser = Parser("Test", [scn], [rep2_1, rep2_2], [prod2])
    actual = parse(parser, "..yes..no..")
    expect = [Token(prod2, Dict(
        "yes" => Groups([Group("yes", 3, 5)]),
        "repl2_1" => Groups([Group("yes", 3, 5)]),
        "repl2_2" => Groups([Group("yes", 3, 5)]),
        prod2.name => Groups([Group("yes", 3, 5)]),
    ))]
    @test actual == expect
end

end
