#Cyclone tracking data exploration

#Load files
#Located in: /data/hpcdata/users/steck/matlabfiles/ERA5

#ERA5_2015_850hpa_rvor.grib

using ArchGDAL
const AG = ArchGDAL

dataset = AG.read("/data/hpcdata/users/steck/matlabfiles/ERA5/ERA5_2015_850hpa_rvor.grib")

#band = AG.getband(dataset,1)

rvor = AG.read(dataset,1);
x = size(rvor,1);
y = size(rvor,2);

X = [i for i in 1:1:x];
Y = [i for i in 1:1:y];

using PlotlyJS
using WebIO
trace = contour(;z=rvor, x=X, y=Y)

#This can take awhile to render.
plot(trace)
