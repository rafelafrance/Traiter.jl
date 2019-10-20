using Traits

@testset "Parser.remove_overlapping!" begin
    rule = Rule("rule", r"a")
    tokens = [Token("rule", RegexMatch("a", [], 1, [], r"a")),
              Token("rule", RegexMatch("a", [], 2, [], r"a")),
              Token("rule", RegexMatch("a", [], 3, [], r"a")),
              Token("rule", RegexMatch("a", [], 4, [], r"a"))]

    # It removes the first token
    match = Token("rule", RegexMatch("a", [], 1, [], r"a"))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, match)
    @test actual == copy(tokens)[2:end]

    # It removes the first few tokens
    match = Token("rule", RegexMatch("a", [], 3, [], r"a"))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, match)
    @test actual == copy(tokens)[4:end]

    # It does not remove tokens before the current one
    match = Token("rule", RegexMatch("a", [], 0, [], r"a"))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, match)
    @test actual == copy(tokens)

    # It does not remove all tokens
    match = Token("rule", RegexMatch("a", [], 5, [], r"a"))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, match)
    @test actual == []

end
