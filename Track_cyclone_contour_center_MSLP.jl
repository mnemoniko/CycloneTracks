# Track a cyclone:
# Centers of closed MSLP contours

using NetCDF

file = "ERA5_2019_MSLP.nc";
saveFile = "24AugustRossCyclone.txt"

lat = ncread(file,"latitude");
lon = ncread(file,"longitude");
time = ncread(file,"time");
mslp = ncread(file,"msl"); #Has both offset & scale!
offset = ncgetatt(file,"msl","add_offset");
scale = ncgetatt(file,"msl","scale_factor");

#Set time range:
using Dates
Day1 = DateTime(2019,8,24,6,0,0);
Day2 = DateTime(2019,8,27);

#Set lat/lon range:
lon_min = 160;
lon_max = 220;
lat_min = -88;
lat_max = -60;

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

ind = findall(lat .<= lat_max);
la1 = ind[1];
ind = findall(lat .>= lat_min);
la2 = ind[end];
lat = lat[la1:la2];

mslp = mslp[lo1:lo2,la1:la2,t1:t2];

#Type conversions needed for using Contour:
mslp = convert(Array{Float64,3},mslp);
lon = convert(Vector{Float64},lon);
lat = convert(Vector{Float64},lat);

#Code above this is used in another file
#Function outside of *.jl file?

using Contour
# Try contour at 500 offset from maximum
max_offset = (600)/scale;
coordMax = zeros(length(time),4);
#Lon, Lat, MSLP, Radius(km)

for j = 1:length(time)
    localMax = findmin(mslp[:,:,j]);
    coordMax[j,3] = (localMax[1]*scale) + offset;
    level1 = localMax[1] + max_offset;
    isolines = contour(lon,lat,mslp[:,:,j],level1);
    isolines = lines(isolines);
    closedCon = zeros(length(isolines),5);
    #Closed, length, lon, lat, radius
    for i=1:length(isolines) #which one is closed?
        l = isolines[i];
        x, y = coordinates(l);
        if x[1]==x[end] && y[1]==y[end]
            closedCon[i,1]=1; #Closed
        else
            closedCon[i,1]=0; #Not closed
        end
        closedCon[i,2]=length(x); #Number of points
        closedCon[i,3]=(minimum(x)+maximum(x))/2;
        closedCon[i,4]=(minimum(y)+maximum(y))/2;
        closedCon[i,5]=111*(maximum(y)-minimum(y))/2;
    end
    #Find the largest closed contour & save coords
    closed = findall(closedCon[:,1] .> 0);
    closedCon = closedCon[closed,:];
    if isempty(closedCon)
        coordMax[j,1] = coordMax[j-1,1];
        coordMax[j,2] = coordMax[j-1,2];
        coordMax[j,4] = 0.0; #zero radius
    else
        max = findmax(closedCon[:,2]);
        coordMax[j,1] = closedCon[max[2],3];
        coordMax[j,2] = closedCon[max[2],4];
        coordMax[j,4] = closedCon[max[2],5];
    end
end


using PlotlyJS
using WebIO

track = scatter(;x=coordMax[:,1],y=coordMax[:,2],mode="lines+markers");
Plot(track)
plot(track)

using DelimitedFiles

open(saveFile, "w") do io
    writedlm(io, [coordMax time])
end
