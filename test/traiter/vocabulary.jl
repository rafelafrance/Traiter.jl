@testset "vocabulary" begin

    @testset "add" begin
        vocab = Vocabulary()
        str = "word"
        code = add(vocab, str)
        @test vocab.int2str[code] == str

        vocab = Vocabulary()
        str = "word-suffix"
        code = add(vocab, str)
        @test vocab.int2str[code] == str
    end

end
