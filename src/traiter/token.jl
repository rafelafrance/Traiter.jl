# const Token = Vector{Int}
const Tokens = Matrix{Int}

const Str = Union{String,SubString{String}}
const Strs = Union{Array{String},Array{SubString{String}}}


# mutable struct Token
#     attrs::Array{}
#     chars::UnitRange{Int}
#     Token(t, n, c) = new([t, n, 0, 0], c)
#     Token(t, n, f, l) = new([t, n, 0, 0], UnitRange(f, l))
# end

# ==(a::Token, b::Token) = (a.attrs, a.chars) == (b.attrs, b.chars)


mutable struct Vocabulary
    key::Int64
    int2str::Dict{Int,String}
    str2int::Dict{String,Int}
    Vocabulary() = new(0, Dict(), Dict())
end


function add(vocab::Vocabulary, str::Str)::Int
    key = get(vocab.str2int, str, 0)
    if key == 0
        vocab.key += 1
        vocab.int2str[vocab.key] = str
        vocab.str2int[str] = vocab.key
        key = vocab.key
    end
    key
end


@enum TokenGenus::Int WORD=1 NUM PUNCT   # TODO: Fill out types
@enum TokenAttr::Int TEXT=1 CANNON GENUS FIRST LAST LEMMA POS

function cannonical(str::Str, genus::TokenGenus)
    str = lowercase(str)
    if genus == WORD
        str = replace(str, r"\p{Pd}" => "")  # Strip dashes from words
    end
    str
end


function token(vocab::Vocabulary, str::Str, first::Int, i::Int, genus::TokenGenus)
    last = i - 1
    word = str[first:last]
    [add(vocab, word) add(vocab, cannonical(word, genus)) Integer(genus) first last 0 0]
end

@enum States OUTSIDE=1 INWORD INNUM

function numstart(char::Char, next::Char, i::Int, str::Str)
    next2 = i < length(str) - 1 ? str[i+2] : -1
    isdigit(char) || (occursin(char, "-+.") && isdigit(next)) ||
         (occursin(char, "-+") && occursin(char, ".") && isdigit(next2))
end


# function fragment(name::String, regex::Patterns, action::TokenAction = nothing)
#     regex = build(regex)
#     regex = Regex("(?<$name> $regex )", "xi")
#     Rule(name, regex, action)
# end


# function tokenize(vocab::Vocabulary, str::Str)::Tokens
#     re = [
#     ]
# end

function tokenize(vocab::Vocabulary, str::Str)::Tokens
    tokens = Matrix{Int}(undef, 0, 7)
    state = OUTSIDE
    first = 1
    i = 1
    while i <= length(str)
        char = str[i]
        # prev = i > 1 ? str[i-1] : -1
        next = i < length(str) ? str[i+1] : Char(0)
        if state == OUTSIDE
            if isletter(char)
                first = i
                state = INWORD
            elseif numstart(char, next, i, str)
                first = i
                state = INNUM
            elseif ispunct(char)
                tokens = vcat(tokens, token(vocab, str, first, i, PUNCT))
            else
            end
        elseif state == INWORD
            if numstart(char, next, i, str)
                t = token(vocab, str, first, i, WORD)
                tokens = vcat(tokens, t)
                first = i
                state = INNUM
            elseif isspace(char)
            elseif ispunct(char)
            else
            end
        elseif state == INNUM
        else
        end
        i += 1
    end
    if state == INWORD
        t = token(vocab, str, first, i, WORD)
        tokens = vcat(tokens, t)
    elseif state == INNUM
        t = token(vocab, str, first, i, NUM)
        tokens = vcat(tokens, t)
    else
    end
    tokens
end
