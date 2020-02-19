mutable struct Vocabulary
    key::Int64
    int2str::Dict{INT,String}
    str2int::Dict{String,INT}
    Vocabulary() = new(0, Dict(), Dict())
end


function add(vocab::Vocabulary, str::AbstractString)::INT
    key = get(vocab.str2int, str, 0)
    if key == 0
        vocab.key += 1
        vocab.int2str[vocab.key] = str
        vocab.str2int[str] = vocab.key
        key = vocab.key
    end
    key
end
