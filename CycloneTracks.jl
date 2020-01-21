
############################
## Find mins and maxes from GRIB file

using ArchGDAL
const AG = ArchGDAL

dataset = AG.read("/data/hpcdata/users/steck/matlabfiles/ERA5/ERA5_2015_850hpa_rvor.grib")

timestep = AG.nraster(dataset);
x = AG.width(dataset);
y = AG.height(dataset);
y = Int16(floor(y/3)); #Subset for Southern Ocean
mins = zeros(timestep);
maxes = zeros(timestep);

for i in 1:1:timestep-1
    var = AG.read(dataset,i,1:y, 1:x);
    mins[i] = minimum(var);
    maxes[i] = maximum(var);
end

# To do: Lat/lons, map data, better contour plot, use rvor or pvor?
# Localize a large storm and see what all the fields are doing
