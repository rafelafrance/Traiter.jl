@testset "reader" begin

    @testset "jsonl" begin
        vocab = Vocabulary()
        jsonl("data/rules.jsonl", vocab)
    end

    @testset "json" begin
        vocab = Vocabulary()
        json("data/rules.json", vocab)
    end

end
