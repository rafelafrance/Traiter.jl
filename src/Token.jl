struct Token
    name:: Symbol
    match:: RegexMatch
    Token(name::Symbol, match::RegexMatch) = new(name, match)
    Token(name::String, match::RegexMatch) = new(Symbol(name), match)
end


function ==(a::Token, b::Token)
    (a.name == b.name
        && a.match.match == b.match.match
        && a.match.captures == b.match.captures
        && a.match.offset == b.match.offset
        && a.match.offsets == b.match.offsets
        && a.match.regex == b.match.regex)
end
