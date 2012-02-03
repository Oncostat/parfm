\name{predict.parfm}
\alias{predict.parfm}
\title{Compute prediction of frailty values for Parametric Frailty Models}

\description{The function \code{predict.parfm()} computes predictions of frailty values.}

\usage{
predict.parfm(model)
}

\arguments{
  \item{model}{A parametric frailty model, object of class \code{\link{parfm}}.}
}

%%\details{}
\value{An object of class \code{predict.parfm}.}
%%\references{Munda M, Rotolo F, Legrand C (2012). parfm: Parametric Frailty Models in R. Submitted}

\author{Federico Rotolo <federico.rotolo@stat.unipd.it> and Marco Munda <marco.munda@uclouvain.be>}

%%\note{}

\seealso{\code{\link{parfm}}}

\examples{
library(parfm)
data(kidney)

model <- parfm(Surv(time,status) ~ sex + age, 
               cluster="id", data=kidney,
	       dist="exponential", frailty="gamma")
u <- predict.parfm(model)
u
plot(u)
}
%%\keyword{}
