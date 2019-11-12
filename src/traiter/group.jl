struct Group
    value::String
    first::Int64
    last::Int64
end

Group(v::SubString{String}, f::Integer, l::Integer) = Group(string(v), f, l)

const Groups = OrderedSet{Group}
const GroupDict = Dict{String,Groups}

function ==(a::Group, b::Group)
    a.value == b.value && a.first == b.first && a.last == b.last
end
