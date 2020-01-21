#Track a cyclone:
#Using MSLP minimum from 2019 ERA5 MSLP file

using NetCDF

file = "ERA5_2019_MSLP.nc";
saveFile = "24AugustRossCyclone.txt"

lat = ncread(file,"latitude");
lon = ncread(file,"longitude");
time = ncread(file,"time");
mslp = ncread(file,"msl");

#Set time range:
using Dates
Day1 = DateTime(2019,8,24);
Day2 = DateTime(2019,8,26);

#Set lat/lon range:
lon_min = 160;
lon_max = 220;
lat_min = -60;
lat_max = -88;

#Time is in seconds since 1900
StartDay = DateTime(1900,1,1);
time1 = Dates.value((Day1-StartDay))/(3600*1e3); #hours
time2 = Dates.value((Day2-StartDay))/(3600*1e3);

ind = findall(time .>= time1);
t1 = ind[1];
ind = findall(time .<= time2);
t2 = ind[end];
time = time[t1:t2];

#Subset lat/lon
ind = findall(lon .>= lon_min);
lo1 = ind[1];
ind = findall(lon .<= lon_max);
lo2 = ind[end];
lon = lon[lo1:lo2];

ind = findall(lat .<= lat_min);
la1 = ind[1];
ind = findall(lat .>= lat_max);
la2 = ind[end];
lat = lat[la1:la2];

mslp = mslp[lo1:lo2,la1:la2,t1:t2];

# Find maximum at each time step
# Save the coordinates

latMax = zeros(length(time));
lonMax = zeros(length(time));
mslpMax = zeros(length(time));

for i=1:length(time)
    min = findmin(mslp[:,:,i]);
    mslpMax[i] = min[1];
    lonMax[i] = lon[min[2][1]];
    latMax[i]= lat[min[2][2]];
end


using PlotlyJS
using WebIO

track = scatter(;x=lonMax,y=latMax,mode="lines+markers");
Plot(track)
plot(track)

#trace = contour(;z=test,x=lon,y=lat);
#Plot(trace);
#plot(trace);

using DelimitedFiles

open(saveFile, "w") do io
    writedlm(io, [lonMax latMax time])
end
