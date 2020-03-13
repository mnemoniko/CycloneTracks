# Identify closed contours for a cyclone

include("user_parameters.jl")
using NetCDF

#Read in values from netcdf file
msl = ncread(outfile,"msl")
msl_time = ncread(outfile,"time")
lon = ncread(outfile,"longitude")
lat = ncread(outfile,"latitude")
scale = ncgetatt(outfile,"msl","scale")
offset = ncgetatt(outfile,"msl","offset")

#Convert to proper type for Contour
msl = convert(Array{Float64,3},msl)
lon = convert(Vector{Float64},lon)
lat = convert(Vector{Float64},lat)

#Convert user input to ERA5 scale
max_depth = max_depth/scale
min_depth = min_depth/scale

#Identify largest closed contour for each time step
import Contour  #Need to do Contour.contour!

#For each time step
for j=1:length(msl_time)
    #Value and index of minimum
    mslMin = findmin(msl[:,:,j])

    #Check that there is a at least one cyclone of minimum size
    isolines = Contour.contour(lon,lat,msl[:,:,j],mslMin[1]+min_depth)
    isolines = Contour.lines(isolines)
    if(isempty(isolines))
        #Do anything else to other variables?
        continue
    end
    #

end

#Save properties of contour

#Identify all closed contours for each time step

#Remove values below a certain threshold or size? - is this quality control?
#Should I be doing this later in a separate file?

#OLD CODE FROM EARILER BELOW

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
