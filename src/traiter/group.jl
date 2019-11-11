struct Group
    value::String
    first::Integer
    last::Integer
end

const Groups = OrderedSet{Group}
const GroupDict = Dict{AbstractString,Groups}

function ==(a::Group, b::Group)
    a.value == b.value && a.first == b.first && a.last == b.last
end
