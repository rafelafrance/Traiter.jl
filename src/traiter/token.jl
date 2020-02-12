@enum TokenAttr text=1 norm lemma pos


mutable struct Token
    attrs::Array{}
    chars::UnitRange{SIZE}
    Token(t, n, c) = new([t, n, 0, 0], c)
    Token(t, n, f, l) = new([t, n, 0, 0], UnitRange(f, l))
end


==(a::Token, b::Token) = (a.attrs, a.chars) == (b.attrs, b.chars)


mutable struct Vocabulary
    key::Int64
    splitter::Regex
    int2str::Dict{Int64,String}
    str2int::Dict{String,Int64}
    Vocabulary() = new(0, r"[^\s,;:.\"]+"xi, Dict(), Dict())
end


const Str = Union{String,SubString{String}}
const Strs = Union{Array{String},Array{SubString{String}}}
const Tokens = Array{Token}


function tokenize(vocab::Vocabulary, str::Str)::Tokens
    tokens = Token[]
    range = findfirst(vocab.splitter, str)
    while !isnothing(range)
        word = str[range]
        token = Token(
            add(vocab, word),
            add(vocab, lowercase(word)),
            range
        )
        push!(tokens, token)
        range = findnext(vocab.splitter, str, range.stop + 1)
    end
    tokens
end


function add(vocab::Vocabulary, str::Str)::Integer
    key = get(vocab.str2int, str, 0)
    if key == 0
        vocab.key += 1
        vocab.int2str[vocab.key] = str
        vocab.str2int[str] = vocab.key
        key = vocab.key
    end
    key
end
