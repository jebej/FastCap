function fastcap2{T<:Geometry}(geoms::Vector{T};kwargs...)
    # Write list file and shape files to temporary directory
    lstfile = writefilestodir(geoms)
    # Run FastCap2
    cmd = `cscript $fastcap2_vbs -l$lstfile $[string("-",a[1],a[2]) for a in kwargs] //nologo`
    res = runandparse_ffs(cmd)
    # Delete temp directory and files
    rm(dirname(lstfile),recursive=true,force=true)
    # Return result
    return res
end

function fastercap{T<:Geometry}(geoms::Vector{T};kwargs...)
    # Write full hierarchal list file
    lstfile = writefullfile(geoms)
    # Run FasterCap
    cmd = `cscript $fastercap_vbs $lstfile $[string("-",a[1],a[2]) for a in kwargs] //nologo`
    res = runandparse_ffs(cmd)
    # Delete temp file
    rm(lstfile)
    # Return result
    return res
end

function fastcapwr{T<:Geometry}(geoms::Vector{T};kwargs...)
    # Write full hierarchal list file
    lstfile = writefullfile(geoms)
    # Run fastcapwr
    cmd = `fastcap $[string("-",a[1],a[2]) for a in kwargs] -l$lstfile`
    res = runandparse_wr(cmd)
    # Delete temp file
    rm(lstfile)
    # Return result
    return res
end

function linedrawing{T<:Geometry}(geoms::Vector{T},filename::String;kwargs...)
    # Write full hierarchal list file
    lstfile = writefullfile(geoms)
    # Run fastcapwr in line drawing mode
    cmd = `fastcap -m $[string("-",a[1],a[2]) for a in kwargs] -l$lstfile`
    run(cmd)
    # Run ps2pdf
    psfile = lstfile[1:end-3]*"ps"
    run(`$ps2pdf -dEPSCrop $psfile $filename`)
    # Delete temp files
    rm(lstfile)
    rm(psfile)
end

function chargedensity{T<:Geometry}(geoms::Vector{T},filename;kwargs...)
    # Write full hierarchal list file
    lstfile = writefullfile(geoms)
    # Run fastcapwr in charge density mode
    cmd = `fastcap -q $[string("-",a[1],a[2]) for a in kwargs] -l$lstfile`
    run(cmd)
    # Run ps2pdf
    psfile = lstfile[1:end-3]*"ps"
    run(`$ps2pdf -dEPSCrop $psfile $filename`)
    # Delete temporary files
    rm(lstfile)
    rm(psfile)
end
