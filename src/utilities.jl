function writefullfile{T<:Geometry}(geoms::Vector{T},lstfile::String=tempname())
    # Write full list file
    open(f->println(f,listfull(geoms)),lstfile,"w")
    return lstfile
end

function writefilestodir{T<:Geometry}(geoms::Vector{T},dir::String=mktempdir())
    # Create folder if it does not exist
    !ispath(dir)&&mkdir(dir)
    # Write one shape file per unique shape
    map(unique(shapes(geoms))) do shape
        open(f->println(f,getfile(shape)),joinpath(dir,shape.name),"w")
    end
    # Write list file
    lstfile = joinpath(dir,"list.lst")
    open(f->println(f,list(geoms)),lstfile,"w")
    return lstfile
end

function runandparse_ffs(cmd)
    # Run command
    stdout, process = open(cmd,"r")
    wait(process)
    res = split(strip(readstring(stdout)),NL)
    # Abort and show log if error occured
    if process.exitcode!=0
        error("FastCap2 error $(process.exitcode)",NL,replace(replace(join(res,"§"),"§§",NL),"§",""))
    end
    # Parse output (FastCap2 or FasterCap)
    nc    = parse(Int,res[end]) # number of conductors
    names = Vector{String}(res[end-nc:end-1]) # conductor names
    mem   = Int64(reinterpret(UInt32,parse(Int32,res[end-nc-1]))) # memory used by solver, correct the overflow bug
    time  = parse(Float64,res[end-nc-2]) # time used by solver
    capm  = readcsv(IOBuffer(join(res[end-2nc-2:end-nc-3],NL)),Float64,dims=(nc,nc))
    log   = replace(replace(join(res[1:end-2nc-3],"§"),"§§",NL),"§","")
    # Check if matrix is strictly diagonally dominant
    rows_bad = sum(capm,2).<0
    if any(rows_bad)
        rows = find(rows_bad)
        warn("Capacitance matrix is not stricly diagonally dominant due to row$(length(rows)>1?"s":"") $(join(rows,", "," and ")).")
    end
    # Return result
    return FastCapResult(capm,names,mem,time,log)
end

function runandparse_wr(cmd)
    # Run command while timing
    time = @elapsed log = strip(readstring(cmd))
    # Parse output
    res    = split(log,NL)
    matidx = find(x->contains(x,"CAPACITANCE MATRIX"),res)[1]
    resmat = readdlm(IOBuffer(join(res[matidx+2:end],NL)))
    names  = Vector{String}(resmat[:,1])
    capm   = Matrix{Float64}(resmat[:,3:end])
    # Return result
    return FastCapResult(capm,names,0,time,log)
end
