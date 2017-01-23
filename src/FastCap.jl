module FastCap

# ghostcript
const ps2pdf = joinpath(dirname(dirname(readstring(`where gswin64c`))),"lib","ps2pdf.bat")
# vbscript for FastFieldSolvers programs on Windows
const fastcap2_vbs  = joinpath(dirname(dirname(@__FILE__)),"deps","fastcap2.vbs")
const fastercap_vbs = joinpath(dirname(dirname(@__FILE__)),"deps","fastercap.vbs")
# Line endings
const NL = is_windows()?"\r\n":"\n"

export Cube, Sphere,
       Model, add_rectangle!, add_polygon!, add_physicalsurf!,
       extrude!,
       Conductor, Dielectric, ConductorGroup, DielectricGroup, move,
       fastcap2, fastercap, fastcapwr, linedrawing

include("shapes.jl")
include("geometries.jl")
include("commands.jl")
include("utilities.jl")
include("gmsh/model.jl")
include("gmsh/msh.jl")
include("gmsh/helpers.jl")

type FastCapResult
    capmat::Matrix{Float64}
    condnames::Vector{String}
    memory::Int64
    time::Float64
    log::String
end

end # module
