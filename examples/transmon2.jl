using FastCap

cl = 500E-6 # side length of the chip
mt = 0.1E-6 # metal thickness
st = 50E-6 # substrate thickness

cw = 10E-6 # center cconuctor width
gg = 6E-6 # ground gap width

il = 249E-6 # transmon island length
iw = 10E-6 # transmon island width (sans digits)
ig = 3E-6 # transmon island gap to ground
ii = 6E-6 # transmon island to island gap

dl = 14E-6 # digit length
dw = 6E-6 # digit width
ds = 12E-6 # digit spacing

ks = 11.9 # substrate relative permitivitty

# Compute some distances
tl = il+2ig # Transmon length, including ground gap
tw = 2(ig+iw)+ii+dl # Transmon width, including ground gap
s1 = (cl-tl)/2 # length of smaller ground section on transmon side of tl
tf = (cl+tl)/2 # y distance to far side of transmon (up to ground plane)
cn = (cl-cw)/2 # y distance to near side of center conductor
cf = (cl+cw)/2 # y distance to far side of center conductor

m = Model(recombineall=true)

# Center conductor
cen = add_rectangle!(m,0,cn,cl,cn+cw,lc=gg,transfinite=[0,(8,"Bump",0.1),0,(8,"Bump",0.1)])
add_physicalsurf!(m,"center_bot",cen)
ext = extrude!(m,cen,(0,0,mt),transfinite=(6,"Bump",0.1))
add_physicalsurf!(m,"center_top",ext)

# Island
isl = add_rectangle!(m,s1+ig,cf+ig,s1+ig+il,cf+ig+tw-2ig,lc=gg,transfinite=[0,(8,"Bump",0.1),0,(8,"Bump",0.1)])
add_physicalsurf!(m,"island_bot",isl)
ext = extrude!(m,isl,(0,0,mt),transfinite=(6,"Bump",0.1))
add_physicalsurf!(m,"island_top",ext)

# Substrate around island and centerline, including holes for island and center cond
xs = [0-gg, cl+gg,cl+gg,s1+tl,s1+tl,s1,   s1,   0-gg]
ys = [cn-gg,cn-gg,cf+gg,cf+gg,cf+tw,cf+tw,cf+gg,cf+gg]
sub = add_polygon!(m,xs,ys,holes=[cen.lineloops[1],isl.lineloops[1]],lc=gg)

# Ground plane around substrate
gnd = add_rectangle!(m,-10gg,-10gg,cl+10gg,cl+10gg,holes=sub.lineloops[1],lc=4gg)
add_physicalsurf!(m,"ground_bot",gnd)
ext = extrude!(m,gnd,(0,0,mt),transfinite=(6,"Bump",0.1))
add_physicalsurf!(m,"ground_top",ext)

# Make temporary surface for substrate
tmp = FastCap.add_surface!(m,gnd.lineloops[1])
ext = extrude!(m,tmp,(0,0,-st),transfinite=(6,"Progression",2))
deleteat!(m.surfaces,length(m.surfaces)-5)
add_physicalsurf!(m,"substrate",[sub;ext])

# Mesh
open(f->println(f,FastCap.print_geo_file(m)),"examples\\transmon2\\transmon2.geo","w")
readstring(`gmsh examples\\transmon2\\transmon2.geo -2 -algo front2d -o examples\\transmon2\\transmon2.msh`)
spawn(`gmsh examples\\transmon2\\transmon2.geo examples\\transmon2\\transmon2.msh`)
msh = FastCap.read_msh("examples\\transmon2\\transmon2.msh")
@time shapes = FastCap.get_shapes(msh)

geoms = [
    ConductorGroup("center",[Conductor("center_bot",ks,shapes[1]),Conductor("center_top",1.,shapes[2])]),
    ConductorGroup("island",[Conductor("island_bot",ks,shapes[3]),Conductor("island_top",1.,shapes[4])]),
    ConductorGroup("gnd",[Conductor("ground_bot",ks,shapes[5]),Conductor("ground_top",1.,shapes[6])]),
    Dielectric("substrate",1.,ks,(cl/2,cl/2,-st/2),shapes[7])
    ]

FastCap.writefilestodir(geoms,"examples\\transmon2")

#res = fastcapwr(geoms)
res = fastcap2(geoms)
