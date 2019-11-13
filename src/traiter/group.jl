struct Group
    value::String
    first::Int64
    last::Int64
end

Group(v::SubString{AbstractString}, f::Integer, l::Integer) = Group(string(v), f, l)

const Groups = OrderedSet{Group}
const GroupDict = Dict{String,Groups}

==(a::Group, b::Group) = (a.value, a.first, a.last) == (b.value, b.first, b.last)
