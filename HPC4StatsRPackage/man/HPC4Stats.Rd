\name{HPC4Stats}
\alias{HPC4Stats}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Supervisor function to manage the HPC4Stats parallel computations.
%%  ~~function to do ... ~~
}
\description{
Reads in the R Namelist file and uses this information to do distributed computation using the Rmpi package.
}
\usage{
HPC4Stats(RNamelist = NULL, ...)
}

\arguments{
  \item{RNamelist}{
  A string giving the file name for the Rnamelist. If  \code{NULL} 

}
  \item{\dots}{
  Any other arguments to be passed to the supervisor
  function. Currently no other arguments are used.
}
}
\details{
This package is in support of the HPC4Stats framework that integrates
the suppervisor function with a suggested directory structure for data
and source code, and an mechansism for describing the parallel tasks
(the R Namelist).  The easiest way to become familiar with this setup
is to consult the HPC4Stats.skeleton example. This is a directory tree
that contains README files in each directory that explain the
function.

}
\value{
No value is returned. All output is done from within this function. 

}

\author{
Douglas Nychka
%%  ~~who you are~~
}


\keyword{programming}% use one of  RShowDoc("KEYWORDS")
