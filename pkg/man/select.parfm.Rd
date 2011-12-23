\name{select.parfm}
\alias{select.parfm}
\title{Compute AIC and BIC values of several Parametric Frailty Models}

\description{The function \code{select.parfm()} computes the AIC and BIC values
  of parametric frailty models with different baseline hazards and different frailty distributions.}

\usage{
select.parfm(formula, cluster, data, 
             dist=c("exponential", "weibull", "gompertz", "loglogistic", "lognormal"),
             frailty=c("gamma", "ingau", "possta"),
             method="BFGS", maxit=5000)
}

\arguments{
  \item{formula}{A formula object, with the response on the left of a ~ operator, and the terms on the right.
    The response must be a survival object as returned by the Surv function.}
  \item{cluster}{The name of a cluster variable in data.}
  \item{data}{A data.frame in which to interpret the variables named in the formula.}
  \item{dist}{The vector of the names of the baseline hazards.
    It can include any of \code{weibull}, \code{exponential}, \code{gompertz}, \code{lognormal} or \code{loglogistic}.}
  \item{frailty}{The vector of the names of the frailty distribution
    It can include any of: \code{none}, \code{gamma}, \code{ingau} or \code{possta}.}
  \item{method}{The optimization method to pass to the function \code{\link{optim}()}.}
  \item{maxit}{Maximum number of iterations (see \code{\link{optim}()}).}
  \item{showtime}{Show the execution time? (see \code{\link{parfm}()})}
}

%%\details{}
\value{An object of class \code{select.parfm}.}
%%\references{}

\author{Federico Rotolo <federico.rotolo@stat.unipd.it> and Marco Munda <marco.munda@uclouvain.be>}

%%\note{}

\seealso{\code{\link{parfm}}}

\examples{
library(parfm)
data(kidney)

# With BFGS optimization method
(models = select.parfm(Surv(time,status) ~ sex + age, 
                       cluster="id", data=kidney))

# With Nelder-Mead optimization method
(models2 = select.parfm(Surv(time,status) ~ sex + age, 
                        cluster="id", data=kidney,
                        method="Nelder-Mead"))
}

%%\keyword{}
