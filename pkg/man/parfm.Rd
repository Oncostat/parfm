\name{parfm}
\alias{parfm}
\title{Parametric Frailty Models}
\description{Fits parametric Frailty Models by maximizing the marginal likelihood.}

\usage{
parfm(formula, cluster, data, inip = NULL, initheta=NULL,
      dist = "weibull", frailty = "none", 
      method = "BFGS", maxit = 5000, showtime=TRUE)
}

\arguments{
  \item{formula}{A formula object, with the response on the left of a ~ operator, and the terms on the right.

    The response must be a survival object as returned by the Surv function.
    
    The status indicator 'event' in the Surv object must be 0=alive, 1=dead.}
  \item{cluster}{The name of a cluster variable in data.}
  \item{data}{A data.frame in which to interpret the variables named in the formula.}
  \item{inip}{The vector of initial values of parameters.}
  \item{initheta}{The initial value of frailty parameter.}
  \item{dist}{
    The baseline hazard distribution.
    One of \code{weibull}, \code{exponential}, \code{gompertz}, \code{lognormal} or \code{loglogistic}.}
  \item{frailty}{
    The Frailty distribution.
    One of: \code{none}, \code{gamma}, \code{ingau} or \code{possta}.}
  \item{method}{The optimization method to pass to the function \code{\link{optim}()}.}
  \item{maxit}{Maximum number of iterations (see \code{\link{optim}()}).}
  \item{showtime}{Show the execution time?}
}

%%\details{}

\value{An object of class \code{parfm}.}

\references{
  Duchateau, L. & Janssen, P. (2008) The frailty model. Springer.

  Wienke, A. (2010) Frailty Models in Survival Analysis. Chapman & Hall/CRC biostatistics series. Taylor and Francis.
}
\author{Federico Rotolo <federico.rotolo@stat.unipd.it> and Marco Munda <marco.munda@uclouvain.be>}
%%\note{}

\seealso{\code{\link{select.parfm}}}

\examples{
library(parfm)
data(kidney)
kidney$sex <- kidney$sex - 1

parfm(Surv(time,status) ~ sex + age, cluster="id", 
      data=kidney, dist="exponential", frailty="gamma")

parfm(Surv(time,status) ~ sex + age, cluster="id", 
      data=kidney, dist="weibull", frailty="ingau")

parfm(Surv(time,status) ~ sex + age, cluster="id", 
      data=kidney, dist="gompertz", frailty="possta", method="Nelder-Mead")
}

\keyword{survival}
\keyword{frailty}
\keyword{parametric}
\keyword{marginal likelihood}
\keyword{shared}
