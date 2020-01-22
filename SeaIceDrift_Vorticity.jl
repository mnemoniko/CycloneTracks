# Getting sea ice drift and calculating vorticity

# 22-28 June Ross Sea cyclone

using NetCDF

file1 = "../OSISAF_IceDrift/merged/2019/06/ice_drift_sh_polstere-625_multi-oi_201906231200-201906251200.nc";
xc = ncread(file1,"xc"); #km
yc = ncread(file1,"yc"); #km
lat = ncread(file1,"lat");
lon = ncread(file1,"lon");
dispx = ncread(file1,"dX"); # km
dispy = ncread(file1,"dY"); # km
flag = ncread(file1,"status_flag");

dt = 48*3600; #Seconds elapsed in 2 days

#Calculate u and v:
u = dispx*1000/dt;
v = dispy*1000/dt;
u[flag .< 20] .= NaN;
v[flag .< 20] .= NaN;

# Calculate vorticity
# dv/dx - du/dy
n=1;
dv = v[2:end,:]-v[1:end-1,:];
du = u[:,2:end]-u[:,1:end-1];

dx = xc[2] - xc[1];
dy = yc[2] - yc[1];

dvdx = dv ./ dx;
dudy = du ./ dy;

rvor = dvdx[:,1:end-1] - dudy[1:end-1,:];
vlat = lat[1:end-1,1:end-1];
vlon = lon[1:end-1,1:end-1];

#Calculate vorticity part 2 - further apart - EDGE EFFECTS!

n = 6; #Points shifted, must be even
dv = v[1+n:end,:] - v[1:end-n,:];
du = u[:,1+n:end] - u[:,1:end-n];
dx = xc[n+1] - xc[1];
dy = yc[n+1] - yc[1];

dvdx = dv ./ dx;
dudy = du ./ dy;

rvor = dvdx[:,1:end-n] - dudy[1:end-n,:];
#Still not convinced this is correct
#Need to determine exact location as well.

#Subset for Ross Sea:
rvor = rvor[30:80,70:end];
rvor = reverse(rvor,dims=2);

#Use closed contour method to find vorticity center?

using PlotlyJS
using WebIO

#trace = contour(;z=rvor,contours=Dict(:start=>-1.0f6, :end=>1.0f6, :size=>1.0f5));
trace = contour(;z=rvor)
layout = Layout(;title="Vorticity at $n points apart")

Plot(trace, layout)
