# get_msl
# Read mean sea level pressure from ERA5 netcdf files
# Then, subset for the Southern Ocean and for specific times

# Import user-based parameters (move to a separate file later?)
include("user_parameters.jl")

# Check input
isdir(era5_dir)
# lat/lons are reasonable range, time makes sense, ...
# Also need to handle missing values in msl

# Calculate parameters
using NetCDF
using Dates

files = readdir(era5_dir)
nfiles = length(files) #Do I need this?
Day1 = DateTime(Year_S,Month_S,Day_S,Hour_S,0,0)
Day2 = DateTime(Year_E,Month_E,Day_E,Hour_E,0,0)
TimeOffset = DateTime(1900,1,1) #ERA5 files start time counting at 1 Jan 1900

time1 = Dates.value((Day1-TimeOffset))/(3600*1e3) #hours
time2 = Dates.value((Day2-TimeOffset))/(3600*1e3) #same as in era5 file

#Read in non-time dependent values from first file
lat = ncread(era5_dir*"/"*files[1],"latitude")
lon = ncread(era5_dir*"/"*files[1],"longitude")
scale = ncgetatt(era5_dir*"/"*files[1],"msl","scale_factor")
offset = ncgetatt(era5_dir*"/"*files[1],"msl","add_offset")

# Subset for location based on lat/lon
ind = findall(lon .>= lon_min)
lo1 = ind[1]
ind = findall(lon .<= lon_max)
lo2 = ind[end]
lon = lon[lo1:lo2]

ind = findall(lat .<= lat_max)
la1 = ind[1]
ind = findall(lat .>= lat_min)
la2 = ind[end]
lat = lat[la1:la2]

# Read in msl and time for files that cover time period of interest
for i in 1:nfiles
    println("i is ", i)
    t = ncread(era5_dir*"/"*files[i],"time")
    if t[1] > time2 || t[end] < time1
        println("Skipping file "*files[i])
        continue
    end

    msl_temp = ncread(era5_dir*"/"*files[i],"msl")
    msl_temp = msl_temp[lo1:lo2,la1:la2,:]
    if @isdefined msl
        global msl_time = cat(msl_time, t; dims=1)
        global msl = cat(msl,msl_temp; dims=3)
    else
        global msl_time = t
        global msl = msl_temp
    end
end

# Subset for time
ind = findall(msl_time .>= time1)
t1 = ind[1]
ind = findall(msl_time .<= time2)
t2 = ind[end]
msl_time = msl_time[t1:t2]

#Apply subsets to msl
msl = msl[:,:,t1:t2]

# Write to smaller output file that contain subsetted values

#Set file and variable attributes
msl_att = Dict("scale" => scale, "offset" => offset, "units" => "Pa",
    "long_name" => "Mean sea level pressure")
lon_att = Dict("units" => "degrees_east", "long_name" => "longitude")
lat_att = Dict("units" => "degrees_north", "long_name" => "latitude")
time_att = Dict("units" => "hours since 1900-01-01 00:00:00.0",
    "long_name" => "time", "calendar" => "gregorian")
global_att = Dict("History" =>
    "Created on "*Dates.format(Dates.now(),"yyyy u d"))

# Create file and write out variables
#if isfile(outfile)
#    rm outfile
#end

nccreate(outfile, "msl",
    "longitude", lon, lon_att,
    "latitude", lat, lat_att,
    "time", msl_time, time_att,
    atts=msl_att, gatts=global_att)

ncwrite(msl,outfile,"msl")

#EOF ??  AM I DONE??  LOTS OF CHECKS FIRST PLEASE.
