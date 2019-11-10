struct Group
    value::String
    first::Int
    last::Int
end

const Groups = OrderedSet{Group}
const GroupDict = Dict{String,Groups}

function ==(a::Group, b::Group)
    a.value == b.value && a.first == b.first && a.last == b.last
end
