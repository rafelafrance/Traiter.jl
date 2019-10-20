struct Rule
    name:: Symbol
    regex:: Regex
    action:: Union{Function, Nothing}
    Rule(name::String, regex) = new(Symbol(name), regex, nothing)
    Rule(name::String, regex, action) = new(Symbol(name), regex, action)
end

# Rule(name, regex) = Rule(name, regex, nothing)
# Rule(name, regex, action) = Rule(name, regex, action)


function first_match(rule::Rule, text::String)::Dict{Symbol, String}
    m = match(rule.regex, text)
    Dict(Symbol(x) => m[x] for x in values(
        Base.PCRE.capture_names(m.regex.regex)) if !isnothing(m[x]))
end


function tokenize(re::String)::String
    # Find tokens in the regex. Look for words that are not part of a group
    # name or a metacharacter. So, "word" not "<word>". Neither "?P" nor "\b".
    word = r"""
        (?<! [?\\] ) (?<! < \s ) (?<! < )
        \b (?<word> [a-z]\w* ) \b
        (?! \s* > )
        """xi

    replace(re, word => s"\g<word>;")
end


build(str::String)::String = join(split(str), " ")
build(strs::Array{String})::String = build(join(strs, " | "))


function fragment(name::String, re::Union{String, Array{String}})::Rule
    re = build(re)
    re = Regex("(?<$name> $re )", "xi")
    Rule(Symbol(name), re)
end


function keyword(name::String, re::Union{String, Array{String}})::Rule
    re = build(re)
    re = Regex(raw"\b" * "(?<$name> $re )" * raw"\b", "xi")
    Rule(Symbol(name), re)
end


function replacer(name::String, re::Union{String, Array{String}})::Rule
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(Symbol(name), re)
end


SUFFIX = 0


function producer(func:: Function, re::Union{String, Array{String}})::Rule
    global SUFFIX
    SUFFIX += 1
    name = "producer_$SUFFIX"
    re = build(re)
    re = tokenize(re)
    re = Regex(raw"\b" * "(?<$name> $re )", "xi")
    Rule(Symbol(name), re, func)
end
