using Traits

@testset "Parser.remove_overlapping!" begin
    rule = Rule("rule", r"a")
    tokens = [Token(rule, Dict(), (first=1, last=2)),
              Token(rule, Dict(), (first=3, last=4)),
              Token(rule, Dict(), (first=5, last=6)),
              Token(rule, Dict(), (first=7, last=8))]

    # It removes the first token
    token = Token(rule, Dict(), (first=1, last=2))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)[2:end]

    # It removes the first few tokens
    token = Token(rule, Dict(), (first=5, last=6))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)[4:end]

    # It does not remove tokens before the current one
    token = Token(rule, Dict(), (first=0, last=0))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == copy(tokens)

    # It removes all tokens
    token = Token(rule, Dict(), (first=7, last=8))
    actual = copy(tokens)
    Traits.remove_overlapping!(actual, token)
    @test actual == []

end
