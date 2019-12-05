'''
fetch_data.py

python script for fetching velocity and Q models from IRIS. If fetch is succesful,
will process the files and save as .mat files.

Required libraries: xarray, scipy, numpy (all are easily installed with pip)

Works with Python 2 or 3. 
'''

try:
    import urllib.request as urlrequest
except ImportError:
    import urllib as urlrequest
import xarray as xr # for loading netcdf
import os, argparse
import scipy.io as scp
import numpy as np


url_base='https://ds.iris.edu/files/products/emc/emc-files/'

vel_models={
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

Q_models={
 'Gung_Romanowicz_2002':
   {
    'server_name':'QRLW8_percent.nc',
    'dQinv_x1000':'dqp','z_field':'depth','lat_field':'latitude',
    'lon_field':'longitude','dims':'z,lat,lon'
   }
}

def fetchVelModels(savedir='./vel_models'):
    ''' fetchVelModels: fetches and processes velocity files from IRIS '''

    setupDir(savedir)
    iris_files=vel_models

    for ref in iris_files.keys():
        full_url=url_base+iris_files[ref]['server_name']
        if os.path.isfile(os.path.join(savedir,ref)+'.nc') or os.path.isfile(os.path.join(savedir,ref)+'.mat'):
            print('  '+ref+' already downloaded.')
        else:
            print("'  '+attempting to fetch "+full_url)
            urlrequest.urlretrieve(full_url, os.path.join(savedir,ref)+'.nc')
            print("'  '+file downloaded as "+os.path.join(savedir,ref)+'.nc')


    # slightly different fieldnames
    for fi in iris_files.keys():
        if os.path.isfile(os.path.join(savedir,fi)+'.mat') is False:
            ds=xr.open_dataset(os.path.join(savedir,fi)+'.nc')
            save_dict={'Latitude':ds[iris_files[fi]['lat_field']].values,
                       'Longitude':ds[iris_files[fi]['lon_field']].values,
                       'Depth':ds[iris_files[fi]['z_field']].values,
                       'Vs':ds[iris_files[fi]['Vs_field']].values.transpose(1,2,0)}
            print('  '+fi+'.nc converted to '+fi+'.mat')
            scp.savemat(os.path.join(savedir,fi)+'.mat',{'Vs_Model':save_dict})
        else:
            print('  '+fi+'.mat already exists')
    return

def fetchQModels(savedir='./Q_models'):
    ''' fetchVelModels: fetches and processes Q model files from IRIS '''

    iris_files=Q_models
    setupDir(savedir)
    for ref in iris_files.keys():
        full_url=url_base+iris_files[ref]['server_name']
        if os.path.isfile(os.path.join(savedir,ref)+'.nc') or os.path.isfile(os.path.join(savedir,ref)+'.mat'):
            print('  '+ref+' already downloaded.')
        else:
            print('  '+"attempting to fetch "+full_url)
            urlrequest.urlretrieve(full_url, os.path.join(savedir,ref)+'.nc')
            print('  '+"file downloaded as "+os.path.join(savedir,ref)+'.nc')

    # slightly different fieldnames
    for fi in iris_files.keys():
        if os.path.isfile(os.path.join(savedir,fi)+'.mat') is False:
            ds=xr.open_dataset(os.path.join(savedir,fi)+'.nc')

            if fi is 'Gung_Romanowicz_2002':
                print('  '+'ref Q is QL6c.1D')
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
            print('  '+fi+'.nc converted to '+fi+'.mat')
            scp.savemat(os.path.join(savedir,fi)+'.mat',{'Q_Model':save_dict})
        else:
            print('  '+fi+'.mat already exists')
    return

def setupDir(savedir):
    ''' checks if directory exists, tries to make it '''

    if os.path.isdir(savedir) is not True:
        try:
            os.mkdir(savedir)
        except:
            raise ValueError(savedir + ' does not exist and could not be built. Check permissions?')

if __name__=='__main__':

    parser = argparse.ArgumentParser(description='fetch IRIS data')
    parser.add_argument('--velDir',
            type=str,default='./data/vel_models',
            help='directory to save velocity models')
    parser.add_argument('--QDir',
            type=str,default='./data/Q_models',
            help='directory to save Q models')
    arg = parser.parse_args()

    print("\nAttempting to fetch Q Models\n")
    fetchQModels(arg.QDir)
    print("\nAttempting to fetch Velocity Models\n")
    fetchVelModels(arg.velDir)
