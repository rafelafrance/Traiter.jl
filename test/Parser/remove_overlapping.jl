using Traits

@testset "Parser.remove_overlapping!" begin
    rule = Rule("rule", r"a")
    tokens = [Token(rule, Dict(), 1, 2), Token(rule, Dict(), 3, 4),
              Token(rule, Dict(), 5, 6), Token(rule, Dict(), 7, 8)]

    # It removes the first token
    token = Token(rule, Dict(), 1, 2)
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)[2:end]

    # It removes the first few tokens
    token = Token(rule, Dict(), 5, 6)
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)[4:end]

    # It does not remove tokens before the current one
    token = Token(rule, Dict(), 0, 0)
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)

    # It removes all tokens
    token = Token(rule, Dict(), 7, 8)
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == []

end
