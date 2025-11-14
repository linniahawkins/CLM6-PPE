import xarray as xr
import numpy as np
import glob
import sys
sys.path.append('/glade/u/home/linnia/CLM6-PPE/')
from utils.pyfunctions import *
utils_path = '/glade/u/home/linnia/CLM6-PPE/utils/'

ens=sys.argv[1] 
out_dir=sys.argv[2]
if out_dir[-1]!='/':
    out_dir+='/'

######################################################
# setup 
dir='/glade/campaign/cgd/tss/projects/PPE/ctsm53065_lhc/hist/'
exp = 'ctsm5.3.065_transient_'
tape='h0a'

dvs=['GPP','AR','HR','NPP','NBP','NEP','ER',
     'EFLX_LH_TOT','FCTR','FCEV','FGEV','BTRANMN','FGR','FSH',
     'SOILWATER_10CM','TWS','QRUNOFF','SNOWDP','H2OSNO','FSNO',
     'TLAI','FSR','ALTMAX','TV','TG','NPP_NUPTAKE','LAND_USE_FLUX',
     'FAREA_BURNED','COL_FIRE_CLOSS',
     'TOTVEGC','TOTECOSYSC','TOTSOMC_1m',
     'TOTVEGN','TOTECOSYSN']

def pp(ds):
    return ds[dvs]

######################################################
# load and process data

f0=sorted(glob.glob(dir+exp+'lhc0000*.'+tape+'.*'))
f=sorted(glob.glob(dir+exp+ens+'*.'+tape+'.*'))

if len(f)<len(f0):
    #hacky way to generate correctly shaped nan output for failed simulations
    # if the requested lhc is missing, we will reanalyze lhc0000 and multiply by np.nan
    bad=True
    f=f0
else:
    bad=False

ds=xr.open_mfdataset(f,combine='by_coords',preprocess=pp,decode_timedelta=False)

# calculate global and biome mean
la=xr.open_dataset(os.path.join(utils_path, "sparsegrid_landarea.nc")).landarea
out=xr.Dataset()
    
for v in dvs:

        x=amean(ds[v])
        out[v+'_global_amean']=gmean(x,la)
        out[v+'_global_amean'].attrs=ds[v].attrs

# save
fout=out_dir+f[0].split('/')[-1].split('clm2')[0]+'postp.nc'
# nan output if no files
if bad:
    out=np.nan*out
    fout=fout.replace('lhc0000',ens)
    
out.to_netcdf(fout)
