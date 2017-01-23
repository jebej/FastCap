using FastCap

# Generate the two wire shapes
np = 4
nl = 5
ew = 0.2
c1 = Cube("bar1",edgewidth=ew,size=(1,nl,1),panels=(np,(np-2)*nl+2,np))
c2 = Cube("bar2",edgewidth=ew,size=(nl,1,1),panels=((np-2)*nl+2,np,np))

# Generate the geometries
geoms = [
    Conductor("cond1",1,(1,0,0),c1),
    Conductor("cond2",1,(3,0,0),c1),
    Conductor("cond3",1,(0,1,2),c2),
    Conductor("cond4",1,(0,3,2),c2)
    ]

# View
#linedrawing(geoms,"examples\\buscrossing.pdf",x="5")

# Simulate!
res1 = fastcapwr(geoms,o=3,t=0.001)
res2 = fastcap2(geoms,o=3,t=0.001)
res3 = fastercap(geoms,a=0.005)
