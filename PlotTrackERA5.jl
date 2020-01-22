# Plot extracted cyclone track over ERA5 data

using NetCDF
using DelimitedFiles

trackFile = "22JuneRossCyclone.txt";
mslpFile = "ERA5_2019_MSLP.nc";
tempFile = "ERA5_2019_2mTemp.nc";
uFile = "ERA5_2019_Uwind10m.nc";
vFile = "ERA5_2019_Vwind10m.nc";

track = readdlm(trackFile);
#lon, lat, min MSLP, Radius, time (h since 1900)

lat = ncread(mslpFile,"latitude");
lon = ncread(mslpFile,"longitude");
time = ncread(mslpFile,"time");
mslp = ncread(mslpFile,"msl"); #Has both offset & scale!
offset = ncgetatt(mslpFile,"msl","add_offset");
scale = ncgetatt(mslpFile,"msl","scale_factor");
