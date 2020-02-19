@testset "reader" begin

    @testset "jsonl" begin
        vocab = Vocabulary()
        jsonl("data/rules.jsonl", vocab)
    end

end
