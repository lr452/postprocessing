#!/bin/bash

# *** This script is for models with data in large chunks which span 1850-2014***

# Change this to where the raw model data downloaded by wget is located 
INPUTDIR=/disk2/lr452/Downloads/fgco2_data/raw_data

# Change the present working directory to that directory
cd $INPUTDIR

# Name of the climate variable you want processed
var=fgco2

# ******  Postprocessing raw model outputs ******

#Step 0: get variable name
# This step is run outside the script, from the command line
# Pattern is
# ncdump -h inputfile.nc
# This displays the netcdf file's header (i.e. the metadata)
# Your variable name is almost always in the file name by convention (e.g. dissic_*)
# But it is good practice to double check.
# You can do this check on one file per model (not all of them!!)
# e.g.

# ncdump -h fgco2_Omon_NorESM2-LM_historical_r1i1p1f1_gn_199001-199912.nc
# Scroll up and down and look for a multidimensional variable which is a float or double, e.g.

# [snip]
#       float fgco2(time, j, i) ;
#               fgco2:standard_name = "surface_downward_mass_flux_of_carbon_dioxide_expressed_as_carbon" ;
#               fgco2:long_name = "Surface Downward Mass Flux of Carbon as CO2 [kgC m-2 s-1]" ;
#               fgco2:comment = "Gas exchange flux of CO2 (positive into ocean)" ;
#               fgco2:units = "kg m-2 s-1" ;
# [snip]
#
# Note: [snip] is linux parlance to indicate it is a text snippet from a longer bit of text
#
# So, the variable name is fgco2.   Remember it is case sensitive. fgco2 not FGCO2.



for CMIP6MODEL in "CESM2-FV2" 
do

    case $CMIP6MODEL in
	"CESM2-FV2")   id="n" ; chunk=50 ;;
    esac

x#Step 1: Isolate years 1994-2014
    echo "Isolating year 1994-2014 from the  model data ..."


    ##### Files in 10 year chunks

  #  if [[ $chunk -eq 10 ]]
  #  then
       # Grab 1994-1999 inclusive from 1990-1999
       #cdo -selyear,1994/1999 ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199001-199912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199912.nc


       # Now concatenate 1994-2014
       # echo "Concatenating model data which comes in ten year chunks ..."
       # Pattern is 
       # ncrcat file1994-1999.rg.nc file2000-2009.rg.nc file2010-2014.rg.nc  file1994-2001.rg.nc

     #  ncrcat ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_200001-200912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_201001-201412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.nc
       
  #  elif [[ $chunk -eq 5 ]]
  #  then 
       # Grab 1994 from 1990-1994
    #   cdo -selyear,1994 ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199001-199412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199412.nc
    #   ncrcat ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199501-199912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_200001-200412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_200501-200912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_201001-201412.nc  ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.nc

  #  elif [[ $chunk -eq 20 ]]
  #  then

#	cdo -selyear,1994/2009 ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199001-200912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-200912.nc
#       ncrcat ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-200912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_201001-201412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.nc
       
 #   elif [[ $chunk -eq 50 ]]
 #   then

	cdo -selyear,1994/1999 ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_195001-199912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199912.nc
        ncrcat ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-199912.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_200001-201412.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.nc
	
	
  #  fi
    
    #Step 2:  Regrid to 1 deg by 1 deg
    echo "Regridding files to 1 degree by 1 degree ..."

    # Pattern is
    # cdo remapbil,r360x180 -selvar,[variable name] inputfile.nc outputfile.rg.nc  (rg=regridded)

    #### Many year chunk files which span 1994-2014

    cdo remapbil,r360x180 -selvar,$var  ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.nc ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.nc

    


    #Step 3: Extract Southern Ocean
    echo "Spatially extracting southern ocean data points from the regridded 1994-2014 files ..."

    # Pattern is
    # cdo sellonlatbox,-180,180,-40,-80 globalfile1994-2014.rg.nc  southern_oceanonly194-2014.rg.so.nc  (so is southern ocean)

    cdo sellonlatbox,-180,180,-40,-80   ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.nc  ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.so.nc

    #Step 4: Remove nuisance metadata component
    echo "Removing the cell_measures component from the regridded southern ocean 1994-2014 netcdf file headers ..."

    # Pattern is
    # ncatted -a ,[variable name],d,cell_measures,  inputfile.rg.so.nc  outputfile.rg.so.fix.nc

    ncatted -a ,${var},d,cell_measures,   ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.so.nc   ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.so.fix.nc
 

    #Step 5: Mask to ocean only
    echo "Masking out land points from regridded southern ocean 1994-2104 fixed metadata files so that the files only contain ocean points ..."

    # Pattern is
    # cdo setctomiss,1.0e20 inputfile.rg.so.fix.nc  outputfile.rg.so.fix.mask.nc
    
    cdo setctomiss,1.0e20  ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.so.fix.nc  ${var}_Omon_${CMIP6MODEL}_historical_r1i1p1f1_g${id}_199401-201412.rg.yr.so.fix.mask.nc

done  #End of the loop around the models


# In the end, it's the files ending in *.mask.nc  that are the final product. You can see them after the script runs by typing
# ls -l *rg.so.fix.mask.nc





