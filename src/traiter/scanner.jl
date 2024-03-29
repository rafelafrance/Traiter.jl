const Tokens = Matrix{INT}


struct Fragment
    name::String
    regex::String
end


mutable struct Scanner
    vocab::Vocabulary
    fragments::Vector{Fragment}
    compiled::Bool
    regex::Regex
    Scanner(v) = new(v, [], false)
end

const FIELD = Dict(
    "text" => 1,
    "canon" => 2,
    "genus" => 3,
    "first" => 4,
    "last" => 5,
    "lemma" => 6,
    "pos" => 7,
)
const FIELDS = length(FIELD)


groupnames(match::RegexMatch)::Dict{Integer,String} =
    Base.PCRE.capture_names(match.regex.regex)


function add(scanner::Scanner, name::String, regex::String)
    regex = "(?<$name>$regex)"
    push!(scanner.fragments, Fragment(name, regex))
    scanner.compiled = false
end

add(scanner::Scanner, name::String, regex::Regex) =
    add(scanner, name, regex.pattern)


function compile(scanner::Scanner, flags::String = "xi")
    all = join([f.regex for f in scanner.fragments], "|")
    scanner.regex = Regex(all, flags)
    scanner.compiled = true
end


function canonical(str::AbstractString, group::AbstractString)
    str = lowercase(str)
    if group == "words"
        str = replace(str, r"\p{Pd}" => "")  # Strip dashes from words
    end
    str
end


function scan(scanner::Scanner, str::AbstractString)
    tokens = Matrix{INT}(undef, 0, FIELDS)
    !scanner.compiled && compile(scanner)
    for match in eachmatch(scanner.regex, str)
        group = get(groupnames(match), "1", "")
        word = match.match

        text = add(scanner.vocab, word)
        canon = add(scanner.vocab, canonical(word, group))
        genus = add(scanner.vocab, group)
        first = match.offset
        last = first + length(text) - 1
        lemma = 0
        pos = 0
        tokens = vcat(tokens, [text canon genus first last lemma pos])
    end
    tokens
end
