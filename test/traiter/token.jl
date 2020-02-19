@testset "token" begin

    @testset "tokenize" begin
        vocab = Vocabulary()
        str = "word1"
        code1 = add(vocab, str[1:4])
        code2 = add(vocab, str[5:5])
        row1 = token(vocab, str, 1, 5, WORD)
        row2 = token(vocab, str, 5, 6, NUM)
        expect = [row1; row2]
        actual = tokenize(vocab, str)
        @test actual == expect

        vocab = Vocabulary()
        str = "word-suffix"
        code1 = add(vocab, str)
        row1 = token(vocab, str, 1, 12, WORD)
        expect = row1
        actual = tokenize(vocab, str)
        @test actual == expect
        @test vocab.int2str[row1[2]] == "wordsuffix"
    end

end
