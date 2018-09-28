# HPC4Stats
A framework for managing embarrassingly parallel data analysis using R and the Rmpi package.


##Directories in this respository:

* **HPC4Stats.skeleton**  A tree of subdirectories (batch, data, output, src)  that is the recommended way to organize a computation/data analysis within HPC4Stats. These directories are populated with README files that explain the purpose of each directory and the files contained in them. This skeleton is setup to do an example parallel computation. See the batch subdirectory to run this example. You will need the fields package to run this example, partly as a way to show how packages are identified for the computation and loaded. 

* **HPC4StatsCMIP**  A example using a subset of climate model output. The task is to fit a Generalized Pareto distribution (GPD) to daily precipitation simulated by the NCAR CCSM4 model. This is a historical run attempting to reproduce the period 1955 01 01-1989 12 31. Here the GPD is fit by maxmimum likelihood separately for every model grid box.  Note that to reduce the size of the data set for the TEST example the full model output has been subsetted to be just a grid of 21X51 locations and 7300 (~20 years) time points. This is the R binary data object **prExample.rda** in the data subdirectory. 
For the production example the user will need to download or access the complete netcdf file in a separate step. 
* **CMIPExample** (UNDER REVISION!)Some examples to introduce fitting the Generalized Pareto distribution (GPD) in interactive mode to times series. This gives some background to these methods that is subsequently use in a larger and complete implementation. These examples are also redone as the ```laptopRmpiExample.rnl``` within the HPC4StatsCMIP application to show the use of this framework. 

###Creating the  R data object ##

* download or locate the large netcdf file ( ~2.6Gb): 
```pr_day_CCSM4_historical_r1i1p1_19550101-19891231.nc```

A link to this file : ```https://www.dropbox.com/s/80qbm1zjr7grx4i/pr_day_CCSM4_historical_r1i1p1_19550101-19891231.nc?dl=0```

On cheyenne this file is available in the directory:
```/glade/p/CMIP/CMIP5/output1/NCAR/CCSM4/historical/day/atmos/day/r1i1p1/files/pr_20120202/```


The R script to create **prExample.rda** is ```HPC4StatsCMIP/src/makeExampleData.R```. To run this one will need to 

* install the R package ncdf4

* modify the 3rd line: 

```setwd("~/sandbox/HPC4StatsCMIP/data")``` 

to be the directory 
where the netcdf output file resides. 




