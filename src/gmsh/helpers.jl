function add_polygon!(m::Model,xs,ys;lc=0.,z=0,transfinite=0,holes=Vector{LineLoop}(0))
    # Add the points
    pts = add_point!.([m],xs,ys,[z],[lc;])
    # Add the lines
    lns = add_line!.([m],pts,circshift(pts,-1),[transfinite;])
    # Add the lineloop
    ll  = add_lineloop!(m,lns)
    # Add and return the surface
    return add_surface!(m,[ll;holes])
end

function add_rectangle!(m::Model,x1,y1,x2,y2;lc=0.,z=0,transfinite=0,holes=Vector{LineLoop}(0))
    return add_polygon!(m,[x1,x2,x2,x1],[y1,y1,y2,y2],lc=lc,z=z,transfinite=transfinite,holes=holes)
end
