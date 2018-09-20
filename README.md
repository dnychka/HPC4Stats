# HPC4Stats
A framework for managing embarrassingly parallel data analysis using R and the Rmpi package.


##Directories in this respository:

* **HPC4Stats.skeleton**  A tree of subdirectories (batch, data, output, src)  that is the recommended way to organize a computation/data analysis within HPC4Stats. These directories are populated with README files that explain the purpose of each directory and the files contained in them. This skeleton is setup to do an example parallel computation. See the batch subdirectory to run this example. You will need the fields package to run this example, partly as a way to show how packages are identified for the computation and loaded. 
* **CMIPExample** (UNDER REVISION!)Some examples to introduce fitting the Generalized Pareto distribution (GPD) in interactive mode to times series. This gives some background to these methods that is subsequently use in a larger and complete implementation. 
* **HPC4StatsCMIP** (UNDER REVISION!) A example using a subset of climate model output. The task is to fit a Generalized Pareto distribution (GPD) to daily precipitation simulated by the NCAR CCSM4 model. This is a historical run attempting to reproduce the period 1955 01 01-1989 12 31. Here the GPD is fit my maxmimum likelihood separately for every model grid box.  Note that to reduce the size of the data set for inclusion the full model output has been subsetted to be just a grid of 21X51 locations and 7300 (~20 years) time points. 



