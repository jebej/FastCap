using FastCap
disc = true
sl = 0.3 # side length (meters)
pt = 1E-3
dt = 0.1
np = 6

k = 5.7 # porcelain

csheet = Cube("csheet",size=(sl,sl, 0),panels=(np,np, 1),exclude=["t","p"],discretized=disc)
tplate = Cube("tplate",size=(sl,sl,pt),panels=(np,np,round(Int,np/4)),exclude=["b"],discretized=disc)
bplate = Cube("bplate",size=(sl,sl,pt),panels=(np,np,round(Int,np/4)),exclude=["t"],discretized=disc)
dielec = Cube("dielec",size=(sl,sl,dt),panels=(np,np,np),exclude=["t","b"],discretized=disc)

plate1 = ConductorGroup("plate1",(0,0,-pt),[
            Conductor("bplate",1,(0,0, 0),bplate),
            Conductor("csheet",k,(0,0,pt),csheet)])

plate2 = ConductorGroup("plate2",(0,0,dt),[
            Conductor("tplate",1,(0,0,0),tplate),
            Conductor("csheet",k,(0,0,0),csheet)])

filler = Dielectric("filler",1,k,(0,0,0),(sl/2,sl/2,dt/2),dielec)

geoms = [plate1,filler,plate2]

linedrawing(geoms,"examples\\platecap.pdf",x=0.4,e=75,w=0.3)

res = fastcap2(geoms,o=3,t=0.001)
#res = fastcapwr(geoms,o=3,t=0.001)
#res = fastercap(geoms,a=0.005)

println(res.log)
