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
#exp = 'ctsm5.3.065_transient_'
tape='h1a'

dvs = ['TOTVEGC','NPP','NPP_NUPTAKE','HTOP','GPP','TLAI','FCTR','FGEV','FCEV','BTRANMN','AR','AGNPP','pfts1d_itype_veg']

def pp(ds):
    return ds[dvs]

def pxbmean(da,lafile):
    lapxb=xr.open_dataset(f).lapxb_sg
    x=(lapxb*da).sum(dim=['pft','vegtype'])/(lapxb).sum(dim=['pft','vegtype'])
    return x

def filter_by_year(files,yr1,yr2):
    filtered = []
    for f in files:
        base = os.path.basename(f)
        year = int(base.split('.')[-2].split('-')[0])
        if (year >= yr1) & (year <= yr2):
            filtered.append(f)
    return filtered


######################################################
# load and process data
yr1 = 1985
yr2 = 2014

lafile = f='/glade/u/home/linnia/CLM6-PPE/utils/lapxb_sg_biomes_ctsm53065.nc'

files=sorted(glob.glob(dir+'*'+ens+'*.'+tape+'.*'))
filtered = filter_by_year(files,yr1,yr2)
print(filtered)

f0=filter_by_year(sorted(glob.glob(dir+'*lhc0000*.'+tape+'.*')),yr1,yr2)
if len(filtered)<len(f0):
    #hacky way to generate correctly shaped nan output for failed simulations
    # if the requested lhc is missing, we will reanalyze lhc0000 and multiply by np.nan
    bad=True
    filtered=f0
else:
    bad=False
    
ds=xr.open_mfdataset(filtered,combine='by_coords',preprocess=pp,decode_timedelta=True)

# calculate pft mean
out=xr.Dataset()
    
for v in dvs:
    if v=='TLAI':
        x=amax(ds[v].sel(time=slice(str(yr1),str(yr2))))
        out[v+'_biome_amax'] = pxbmean(x,lafile)
    else:
        x=amean(ds[v].sel(time=slice(str(yr1),str(yr2))))
        out[v+'_biome_amean'] = pxbmean(x,lafile)

    for dv in out.data_vars:
        if v in dv:
            out[dv].attrs=ds[v].attrs

# save
fout=out_dir+filtered[0].split('/')[-1].split('clm2')[0]+'postp_pxbmean.nc'
# nan output if no files
if bad:
    out=np.nan*out
    fout=fout.replace('lhc0000',ens)
    
out.to_netcdf(fout)
