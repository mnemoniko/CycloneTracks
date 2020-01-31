# Track a cyclone:
# Centers of closed MSLP contours

using JLD

file = "24Aug19_ERA5_mslp.jld";
saveFile = "24AugustRossCyclone.txt"

# Load data:
mslp = load(file,"mslp");
lat = load(file,"lat");
lon = load(file,"lon");
time = load(file,"time");
offset = load(file,"offset");
scale = load(file,"scale");

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

# using DelimitedFiles
#
# open(saveFile, "w") do io
#     writedlm(io, [coordMax time])
# end
