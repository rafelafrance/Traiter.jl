@testset "scanner" begin

    @testset "scan" begin
        vocab = Vocabulary()
        scanner = Scanner(vocab)
        add(scanner, "letters", r"\p{L}+")
        add(scanner, "digits", r"\p{N}+")
        actual = scan(scanner, "Test 1 string2")
        @test size(actual) == (4, COLS)
    end

end
