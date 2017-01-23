abstract Geometry

immutable Conductor <: Geometry
    name::String
    outperm::Real
    tran::Tuple{Real,Real,Real}
    shape::Shape
end

function Conductor(name::String,outperm::Real,shape::Shape)
    return Conductor(name,outperm,(0,0,0),shape)
end

immutable Dielectric <: Geometry
    name::String
    outperm::Real
    inperm::Real
    tran::Tuple{Real,Real,Real}
    ref::Tuple{Real,Real,Real}
    shape::Shape
end

function Dielectric(name::String,outperm::Real,inperm::Real,ref::Tuple{Real,Real,Real},shape::Shape)
    return Dielectric(name,outperm,inperm,(0,0,0),ref,shape)
end

immutable ConductorGroup <: Geometry
    name::String
    tran::Tuple{Real,Real,Real}
    geoms::Vector{Conductor}
end

function ConductorGroup(name::String,geoms::Vector{Conductor})
    return ConductorGroup(name,(0,0,0),geoms)
end

immutable DielectricGroup <: Geometry
    name::String
    tran::Tuple{Real,Real,Real}
    geoms::Vector{Dielectric}
end

function DielectricGroup(name::String,geoms::Vector{Conductor})
    return DielectricGroup(name,(0,0,0),geoms)
end

move(tran::Tuple{Real,Real,Real},g::Conductor) = Conductor(g.name,g.outperm,g.tran+tran,g.shape)
move(tran::Tuple{Real,Real,Real},g::Dielectric) = Dielectric(g.name,g.outperm,g.inperm,g.tran+tran,g.ref+tran,g.shape)
move(tran::Tuple{Real,Real,Real},g::ConductorGroup) = ConductorGroup(g.name,g.tran+tran,g.geoms)
move(tran::Tuple{Real,Real,Real},g::DielectricGroup) = DielectricGroup(g.name,g.tran+tran,g.geoms)

function regroup(name::String,tran,groups::Vector{ConductorGroup})
    # Return a new conductor group with the given name
    return ConductorGroup(name,tran,geometries(groups))
end

function regroup(name::String,tran,groups::Vector{DielectricGroup})
    # Return a new dielectric group with the given name
    return ConductorGroup(name,tran,geometries(groups))
end

function geometries{T<:Union{ConductorGroup,DielectricGroup}}(groups::Vector{T})
    # Extract the geometries from each group applying the group
    # translation directly to the extracted geometry
    return mapreduce(group->mapreduce(g->move(group.tran,g),vcat,group.geoms),vcat,groups)
end

function shapes{T<:Geometry}(geoms::Vector{T})
    # Extract all the shapes from a list of geometries
    return mapreduce(shapes,vcat,geoms)
end

function shapes(g::Union{Conductor,Dielectric})
    # Extract shape from geometry
    return g.shape
end

function shapes(g::Union{ConductorGroup,DielectricGroup})
    # Extract shapes from geometry group
    return [e.shape for e in g.geoms]
end

function listfull{T<:Geometry}(geoms::Vector{T})
    listfile   = list(geoms)
    shapefiles = hierfile.(unique(shapes(geoms)))
    return join([listfile;"End";shapefiles],NL)
end

hierfile(shape::Shape) = "File "*shape.name*NL*getfile(shape)*NL*"End"

function list{T<:Geometry}(geoms::Vector{T})
    return join(listline.(geoms),NL)
end

prtu(tu) = @sprintf(" % .5E % .5E % .5E",tu...)

function listline(g::Conductor)
    lg = "G $(g.name)"
    lf = "C $(g.shape.name) $(g.outperm)"*prtu(g.tran)
    return join([lg,lf],NL)
end

function listline(g::Dielectric)
    lg = "G $(g.name)"
    lf = "D $(g.shape.name) $(g.outperm) $(g.inperm)"*prtu(g.tran)*prtu(g.ref)*" - 0x7a49a5ff"
    return join([lg,lf],NL)
end

function listline(g::ConductorGroup)
    lg = "G $(g.name)"
    lf = ["C $(c.shape.name) $(c.outperm)"*prtu(c.tran+g.tran) for c in g.geoms]
    return join([lg,join(lf," +$NL")],NL)
end

function listline(g::DielectricGroup)
    lg = "G $(g.name)"
    lf = ["D $(d.shape.name) $(d.outperm) $(d.inperm)"*prtu(d.tran+g.tran)*prtu(d.ref+g.tran)*" - 0x7a49a5ff" for d in g.geoms]
    return join([lg,join(lf,NL)],NL)
end

import Base.+
+(a::Tuple{Real,Real,Real},b::Tuple{Real,Real,Real}) = (a[1]+b[1],a[2]+b[2],a[3]+b[3])
