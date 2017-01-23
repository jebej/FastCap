const FILE_FORMAT = ["2.2", "0", "8"]

immutable Physical
    num::Int
    dim::Int
    name::String
end

immutable Node
    x::Float64
    y::Float64
    z::Float64
end

immutable Element
    elmtype::Symbol
    phystag::Int
    geomtag::Int
    nodes::Vector{Int}
    function Element(elmtype::Int,phystag::Int,geomtag::Int,nodes::Vector{Int})
        if     elmtype==2; elmtype=:triangle
        elseif elmtype==3; elmtype=:quadrangle
        else error("The mesh can only contain 2D triangles or quadrangles!")
        end
        return new(elmtype,phystag,geomtag,nodes)
    end
end

immutable Mesh
    physicals::Vector{Physical}
    nodes::Vector{Node}
    elements::Vector{Element}
end

function get_shapes(m::Mesh)
    res = map(m.physicals) do p
        file = print_fastcap_file(m,p)
        return GmshShape(p.name,file)
    end
    return res
end

import Base.print
function print(io::IO,n::Node)
    return @printf(io,"% .6E % .6E % .6E",n.x,n.y,n.z)
end

function print_fastcap_file(m::Mesh,p::Physical)
    res = map(get_elms(m,p)) do elm
        nds = get_nodes(m,elm)
        if elm.elmtype==:triangle
            s = string("T 1 ",join(nds," ")) # join uses the print method above
        elseif elm.elmtype==:quadrangle
            s = string("Q 1 ",join(nds," "))
        else
            error("This shape is not supported by FastCap!")
        end
        return s
    end
    return join(["0 Gmsh physical: $(p.name)";res],NL)
end

function get_nodes(m::Mesh,e::Element)
    return m.nodes[e.nodes]
end

function get_elms(m::Mesh,p::Physical)
    return get_elms(m,p.num)
end

function get_elms(m::Mesh,p::Int)
    return collect(filter(e->e.phystag==p,m.elements))
end

function read_msh(filename::String)
    physicals,nodes,elms = open(parse_msh,filename,"r")
    return Mesh(physicals,nodes,elms)
end

function parse_msh(f::IOStream)
    local physicals,nodes,elms
    while !eof(f)
        header = strip( readline(f) )
        if header == "\$MeshFormat"
            fmt = split( readline(f) )
            @assert fmt == FILE_FORMAT
            @assert "\$EndMeshFormat" == strip(readline(f))
        elseif header == "\$PhysicalNames"
            nonames = parse(Int,readline(f))
            physicals = Vector{Physical}(nonames)
            for n = 1:nonames
                s = split(readline(f))
                @assert n == parse(Int,s[2])
                physicals[n] = Physical(n,
                    parse(Int,s[1]),
                    strip(s[3],'"'))
            end
            @assert "\$EndPhysicalNames" == strip(readline(f))
        elseif header == "\$Nodes"
            nonodes = parse(Int, readline(f))
            nodes = Vector{Node}(nonodes)
            for n = 1:nonodes
                s = split(readline(f))
                @assert n == parse(Int,s[1])
                nodes[n] = Node(parse(Float64,s[2]),parse(Float64,s[3]),parse(Float64,s[4]))
                #nodes[n] = Node(parse.([Float64],s[2:4])...)
            end
            @assert "\$EndNodes" == strip(readline(f))
        elseif header == "\$Elements"
            noelms = parse(Int, readline(f))
            elms = Vector{Element}(noelms)
            for n = 1:noelms
                s = [parse(Int,x) for x in split(readline(f))]
                #s = parse.([Int],split(readline(f)))
                @assert n == s[1]
                notags = s[3]
                elms[n] = Element(s[2],s[4],s[5],s[6:end])
            end
            @assert "\$EndElements" == strip(readline(f))
        elseif header == "\$Comment"
            while true
                line = readline(f)
                if strip(line) == "\$EndComment"
                    break
                end
            end
        else
            msg = string("Unknown section header: ", line)
            error(msg)
        end
    end
    return physicals,nodes,elms
end
