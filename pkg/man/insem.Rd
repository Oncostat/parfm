\name{insem}
\docType{data}
\alias{insem}
\title{Time to first insemination in dairy heifer cows 
  without time varying covariates}
\description{
In a dairy farm, the calving interval (the time between two calvings) 
  should be optimally between 12 and 13 months. 
One of the main factors determining the length of the calving interval 
  is the time from parturition to the time of first insemination. 

The objective of this study is to look for cow factors that might predict 
  the time to first insemination, 
  so that actions can be taken based on these predictors. 
As no inseminations take place in the first 29 days after calving, 
  we subtract 29 days (and not 30 days as the first event would then have 
  first insemination time zero) from the time to first insemination 
  since at risk time starts only then. 
Cows which are culled without being inseminated are censored 
  at their culling time. 
Furthermore, cows that are not yet inseminated 300 days after calving 
  are censored at that time. 

The time to first insemination is studied in dairy cows 
  as a function of covariates that are fixed over time.   
An example ofsuch a covariate is the parity of the cow, 
  corresponding to the number of calvings the cow has had already. 
As we observe only one lactation period for each cow in the study, 
  it is indeed a constant cow characteristic 
  within the time framework of the study. 

We dichotomise parity into primiparous cows or heifers
  (only one calving (\code{heifer=1})) and multiparous cows
  (more than one calving (\code{heifer=0})). 
Other covariates that are used in the analysis are 
  the different milk constituents such as protein and 
  ureum concentration at parturition. 
}
\usage{data(insem)}
 \format{A dataframe containing 10513 observations.
 \describe{
    \item{Cowid:}{Cow's identifyier.}
    \item{Time:}{Time to first insemination (in days).}
    \item{Status:}{Censored (0) or observed (1) event time.}
    \item{Herd:}{The herd to which the cow belongs.}
    \item{Urem:}{Milk urem concentration (\%)
      at the start of the lactation period.}
    \item{Protein:}{Protein concentration (\%)
      at the start of the lactation period.}
    \item{Parity:}{The number of calvings.}
    \item{Heifer:}{Multiparous cow (0) or primiparous cow (1).}
  }
}
\source{Example 1.8 of Duchateau an Janssen (2008).}
\references{
  Duchateau L., Janssen P. (2008). \emph{The frailty model. Springer}.
  New York: Springer--Verlag.
}
\note{
  These data are downloaded from
    \url{http://www.vetstat.ugent.be/research/frailty/datasets/}.
  They are simulated data sets with exactly
    the same structure as the real data used in the book,
    that could not be made publicly available.    
}
\keyword{datasets}
\keyword{insem}
\keyword{cows}
\keyword{insemination}
\keyword{frailty}