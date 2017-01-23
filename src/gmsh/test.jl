using FastCap

m = FastCap.Model()

sur = FastCap.add_rectangle!(m,0,0,1,1)
FastCap.add_physicalsurf!(m,"conductor_bot",sur)
@time newsur = FastCap.extrude!(m,sur,(0,0,0.5))
FastCap.add_physicalsurf!(m,"new_cond",newsur)


open(f->println(f,FastCap.print_geo_file(m)),"simple.geo","w")
#spawn(`gmsh simple.geo`)
