@testset "token" begin

@testset "tokenize" begin
    vocab = Vocabulary()
    word = "word1"
    code = add(vocab, word)
    actual = tokenize(vocab, "word1")
    expect = [Token(code, code, 1, length(word))]
    @test actual == expect
end

end
