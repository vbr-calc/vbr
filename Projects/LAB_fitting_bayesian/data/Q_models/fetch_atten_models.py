# fetches Q models from Iris.
#!pip install xarray

try:
    import urllib.request as urlrequest
except ImportError:
    import urllib as urlrequest
import xarray as xr # for loading netcdf
import os
import scipy.io as scp
import numpy as np

url_base='https://ds.iris.edu/files/products/emc/emc-files/'
iris_files={
 'Gung_Romanowicz_2002':
   {
	'server_name':'QRLW8_percent.nc',
	'dQinv_x1000':'dqp','z_field':'depth','lat_field':'latitude',
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

        if fi is 'Gung_Romanowicz_2002':
            print('ref Q is QL6c.1D')
            # Values below are at the depths [80, 80, 100, 120, 140, 160, 180
            # 200, 220, 200, 265, 310, 355, 400, 400, 450, 500, 550, 600, 600,
            # 635, 670]
            QL6c = np.tile(
                    np.array([[[191., 70., 70, 70., 70., 80., 90., 100., 110.,
                                120., 130., 140., 150., 160.,  165., 165.,
                                165., 165., 165., 165., 165., 165.]]]),
                    (91, 180, 1))
            Qinv_field = (
                ds[iris_files[fi]['dQinv_x1000']].values.transpose(1, 2, 0)
                / 1000 * 1 / QL6c + 1 / QL6c)
            Q_field = 1 /  Qinv_field
        else:
            Q_field = ds[iris_files[fi]['Q_field']].values.transpose(1, 2, 0)

        save_dict={'Latitude':ds[iris_files[fi]['lat_field']].values,
                   'Longitude':ds[iris_files[fi]['lon_field']].values,
                   'Depth':ds[iris_files[fi]['z_field']].values,
                   'Q':Q_field, 'Qinv':1/Q_field}
        print(fi+'.nc converted to '+fi+'.mat')
        scp.savemat(fi+'.mat',{'Q_Model':save_dict})
    else:
        print(fi+'.mat already exists')
