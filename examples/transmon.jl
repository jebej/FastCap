using FastCap

disc = true
p = 1 # 1 takes 3s, 2 takes 17s

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
rp = (gg/2,gg/2,-st/2) # reference point for dieletectrics

# Compute some distances
tl = il+2ig # Transmon length, including ground gap
tw = 2(ig+iw)+ii+dl # Transmon width, including ground gap
s1 = (cl-tl)/2 # length of smaller ground section on transmon side of tl
tf = (cl+tl)/2 # y distance to far side of transmon (up to ground plane)
cn = (cl-cw)/2 # y distance to near side of center conductor
cf = (cl+cw)/2 # y distance to far side of center conductor

# Panels
ps = ceil(Int,15p)
pg = ceil(Int,10p)
pgw = ceil(Int,3p+2)
pm = ceil(Int,15p)
pmt = ceil(Int,5+p)

function metalonsubstrate(name;ks=1.0,size=(1,1,1),panels=(3,3,3),exclude=[],discretized=true)
    # Top part of metal, including sides
    a = Conductor(name*"_top",1.,(0,0,0),Cube(name*"_top",size=size,panels=panels,exclude=["b";exclude],discretized=discretized))
    # Bottom sheet of metal (in contact with substrate)
    b = Conductor(name*"_bot",ks,(0,0,0),Cube(name*"_bot",size=size,panels=panels,exclude=["t";"p"],discretized=discretized))
    return ConductorGroup(name,(0,0,0),[a,b])
end

# Substrate
subs = Dielectric("subs",1.0,ks,(0,0,-st),rp,    Cube("subs",size=(cl,cl,st),panels=(ps,2ps,ps),discretized=disc,exclude=["t"]))
gap1 = Dielectric("gap1",1.0,ks,(0,cn-gg,-st),rp,Cube("gap1",size=(cl,gg,st),panels=(3pg,pgw,1),discretized=disc,exclude=["b","p"]))
gap2 = Dielectric("gap2",1.0,ks,(0,0,0),rp,      Cube("gap2",size=(s1,gg,st),panels=(1pg,pgw,1),discretized=disc,exclude=["b","p"]))
igp1 = Dielectric("igp1",1.0,ks,(ig,0,0),rp,     Cube("igp1",size=(il,ig,st),panels=(2pg,pgw,1),discretized=disc,exclude=["b","p"]))
igp2 = Dielectric("igp2",1.0,ks,(0,0,0),rp,      Cube("igp2",size=(ig,tw,st),panels=(pgw,1pg,1),discretized=disc,exclude=["b","p"]))
gap2 = DielectricGroup("gap2",(0,cf,-st),[gap2,move((tf,0,0),gap2)])
igap = DielectricGroup("igap",(s1,cf,-st),[igp1,igp2,move((0,tw-ig,0),igp1),move((il+ig,0,0),igp2)])

# Conductors
# Near side ground
gnda = metalonsubstrate("gnda",ks=ks,size=(cl,cn-gg,mt),panels=(1pm,1pm,pmt),discretized=disc)
# Centerline
ccon = move((0,cn,0),metalonsubstrate("ccon",ks=ks,size=(cl,cw,mt),panels=(4pm,2pgw,pmt),discretized=disc,))
# Far side ground
gndb = FastCap.regroup("gndb",(0,cf,0),[
move((0, gg,0),metalonsubstrate("gndb_1",ks=ks,size=(s1,tw-gg,mt),panels=(1pm,1pm,pmt),discretized=disc,exclude=["pfr"])),
move((0, tw,0),metalonsubstrate("gndb_2",ks=ks,size=(s1,cn-tw,mt),panels=(1pm,1pm,pmt),discretized=disc,exclude=["pfl","pbl"])),
move((s1,tw,0),metalonsubstrate("gndb_3",ks=ks,size=(tl,cn-tw,mt),panels=(2pm,2pm,pmt),discretized=disc,exclude=["pbr"])),
move((tf,gg,0),metalonsubstrate("gndb_4",ks=ks,size=(s1,tw-gg,mt),panels=(1pm,1pm,pmt),discretized=disc,exclude=["pfr"])),
move((tf,tw,0),metalonsubstrate("gndb_5",ks=ks,size=(s1,cn-tw,mt),panels=(1pm,1pm,pmt),discretized=disc,exclude=["pbl","pbr"]))
])
# Transmon
isl1 = metalonsubstrate("isl1",ks=ks,size=(il,tw-2ig,mt),panels=(2pm,1pm,pmt),discretized=disc)
isl1 = move((s1+ig,cf+ig,0),isl1)

# Group it all up
geoms = [ccon,gnda,gndb,isl1,subs,gap1,gap2,igap]

# Run!
res = fastcap2(geoms)#,o=3,t=0.001)

#linedrawing(geoms,"examples\\transmon.pdf",w=0.01)
