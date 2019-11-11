@testset "token" begin

@testset "token.Token(::Rule, ::RegexMatch)" begin
    r = Rule("r", r"(?<a>aa)(?<b>bb)?(?<c>cc)")

    # It gets all captures from the regex
    m = match(r.regex, "..aabbcc..")
    actual = Token(r, m)
    expect = Token(r, Dict("r" => Group("aabbcc", 3, 8),
                           "a" => Group("aa", 3, 4),
                           "b" => Group("bb", 5, 6),
                           "c" => Group("cc", 7, 8)))
    @test actual == expect

    # It does not add empty capture groups
    m = match(r.regex, "..aacc..")
    actual = Token(r, m)
    expect = Token(r, Dict("r" => Group("aacc", 3, 6),
                           "a" => Group("aa", 3, 4),
                           "c" => Group("cc", 5, 6)))
    @test actual == expect
end

@testset "token.==" begin
    ra = Rule("rulea", r"aa")
    rb = Rule("ruleb", r"bb")
    ma = match(ra.regex, "aa")
    mb = match(rb.regex, "bb")

    @test Token(ra, ma) == Token(ra, ma)
    @test Token(ra, ma) == Token(ra, match(ra.regex, "aa"))
    @test Token(ra, ma) == Token(Rule("rulea", r"aa"), ma)
    @test Token(ra, ma) != Token(rb, mb)
    @test Token(ra, ma) != Token(ra, mb)
    @test Token(ra, ma) != Token(rb, ma)
end

@testset "token.firstoffset" begin
    ra = Rule("rulea", r"aa")
    tkn = Token(ra, match(ra.regex, "..aa.."))
    @test Traiter.firstoffset(tkn) == 3
end

@testset "token.lastoffset" begin
    ra = Rule("rulea", r"aa")
    tkn = Token(ra, match(ra.regex, "..aa.."))

    @test Traiter.lastoffset(2, "aa") == 3
    @test Traiter.lastoffset(match(ra.regex, "..aa..")) == 4

    @test Traiter.lastoffset(tkn) == 4
end

@testset "token.groupnames" begin
    re = r"(?<q>(?<a>aa)(?<b>bb))(?<c>cc)"
    actual = Traiter.groupnames(match(re, "aabbcc"))
    expect = Dict(1 => "q", 2 => "a", 3 => "b", 4 => "c")
    @test actual == expect
end

@testset "token.addgroup!(::GroupDict, ::String, ::Group)" begin
    groups = Traiter.GroupDict()
    groups["aa"] = Groups([Group("11", 1, 11)])
    groups["bb"] = Groups([Group("22", 2, 22)])
    group = Group("22", 2, 22)

    # It adds a new key
    actual = copy(groups)
    Traiter.addgroup!(actual, "cc", group)
    expect = Traiter.GroupDict()
    expect["aa"] = Groups([Group("11", 1, 11)])
    expect["bb"] = Groups([Group("22", 2, 22)])
    expect["cc"] = Groups([Group("22", 2, 22)])
    @test actual == expect

    # It does not add duplicates
    actual = copy(groups)
    Traiter.addgroup!(actual, "bb", group)
    expect = Traiter.GroupDict()
    expect["aa"] = Groups([Group("11", 1, 11)])
    expect["bb"] = Groups([Group("22", 2, 22)])
    @test actual == expect

    # It appends to a set
    actual = copy(groups)
    Traiter.addgroup!(actual, "aa", group)
    expect = Traiter.GroupDict()
    expect["aa"] = Groups([Group("11", 1, 11), Group("22", 2, 22)])
    expect["bb"] = Groups([Group("22", 2, 22)])
    @test actual == expect
end

@testset "token.addgroup!(::GroupDict, ::String, ::Groups)" begin
    groups = Traiter.GroupDict()
    groups["aa"] = Groups([Group("11", 1, 11)])
    groups["bb"] = Groups([Group("22", 2, 22)])
    group = Groups([Group("33", 1, 11)])

    # It unites the sets
    actual = copy(groups)
    Traiter.addgroup!(actual, "aa", group)
    expect = Traiter.GroupDict()
    expect["aa"] = Groups([Group("11", 1, 11), Group("33", 1, 11)])
    expect["bb"] = Groups([Group("22", 2, 22)])
    @test actual == expect
end

end
