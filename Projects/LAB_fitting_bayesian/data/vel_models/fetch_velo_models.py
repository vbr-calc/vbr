# fetches velocity models from Iris.
#!pip install xarray

try:
    import urllib.request as urlrequest
except ImportError:
    import urllib as urlrequest
import xarray as xr # for loading netcdf
import os
import scipy.io as scp

url_base='https://ds.iris.edu/files/products/emc/emc-files/'
iris_files={
 'Porter_Liu_Holt_2015':
    {
        'server_name':'US-Crust-Upper-mantle-Vs.Porter.Liu.Holt.2015_kmps.nc',
        'Vs_field':'vs','z_field':'depth','lat_field':'latitude',
        'lon_field':'longitude','dims':'z,lat,lon'
    },
 'Shen_Ritzwoller_2016':
    {
        'server_name':'US.2016.nc',
        'Vs_field':'vsv','z_field':'depth','lat_field':'latitude',
        'lon_field':'longitude','dims':'z,lat,lon'
    }
}

for ref in iris_files.keys():
    full_url=url_base+iris_files[ref]['server_name']
    if os.path.isfile(ref+'.nc') or os.path.isfile(ref+'.mat'):
        print(ref+' already downloaded.')
    else:
        print("attempting to fetch "+full_url)
        urlrequest.urlretrieve(full_url, ref+'.nc')
        print("file downloaded as ./"+ref+'.nc')


# slightly different fieldnames
for fi in iris_files.keys():
    if os.path.isfile(fi+'.mat') is False:
        ds=xr.open_dataset(fi+'.nc')
        save_dict={'Latitude':ds[iris_files[fi]['lat_field']].values,
                   'Longitude':ds[iris_files[fi]['lon_field']].values,
                   'Depth':ds[iris_files[fi]['z_field']].values,
                   'Vs':ds[iris_files[fi]['Vs_field']].values.transpose(1,2,0)}
        print(fi+'.nc converted to '+fi+'.mat')
        scp.savemat(fi+'.mat',{'Vs_Model':save_dict})
    else:
        print(fi+'.mat already exists')
