abstract Shape

immutable Cube <: Shape
    name::String
    size::Tuple{Real,Real,Real}
    panels::Tuple{Int,Int,Int}
    edgewidth::Real
    centered::Bool
    discretized::Bool
    exclude::Array{String} #top: t, bottom: b, sides: p
    function Cube(name;size=(1,1,1),panels=(3,3,3),edgewidth=.1,centered=false,discretized=true,exclude=[])
        return new(name,size,panels,edgewidth,centered,discretized,exclude)
    end
end

immutable Sphere <: Shape
    name::String
    radius::Real
    depth::Int
    function Sphere(name;radius=1,depth=1)
        return new(name,radius,depth)
    end
end

immutable GmshShape <: Shape
    name::String
    file::String
end

function getfile(sh::Cube)
    height  = ["-xh$(sh.size[1])";"-yh$(sh.size[2])";"-zh$(sh.size[3])"]
    panels  = ["-nx$(sh.panels[1])";"-ny$(sh.panels[2])";"-nz$(sh.panels[3])"]
    misc    = ["-e$(sh.edgewidth)";sh.centered?"-o":[];sh.discretized?[]:"-d"]
    exclude = ["-$x" for x in sh.exclude]
    file = strip(readstring(`cubegen_ $height $panels $misc $exclude`))[2:end]
    return "0 cube," * file
end

function getfile(sh::Sphere)
    radius = ["-r$(sh.radius)"]
    misc   = ["-d$(sh.depth)"]
    file = strip(readstring(`spheregen $radius $misc`))[121:end]
    return "0 sphere, $(sh.radius)m radius sphere (d=$(sh.depth))" * file
end

function getfile(sh::GmshShape)
    return sh.file
end
