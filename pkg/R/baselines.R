############################
#  Baseline distributions  #
############################

weibull <- function(pars, #rho, lambda
                    t, what){
  # h(t) = \rho \lambda t^(\rho-1)
  if (what=="H") return( pars[2] * t^(pars[1]) )
  else if (what=="lh") return( log(pars[1]) + log(pars[2]) + ((pars[1] - 1) * log(t)) )
}


exponential <- function(pars, #lambda
                        t, what){
  # h(t) = \lambda 
  if (what=="H") return( weibull(c(1, pars), t, what="H") )
  if (what=="lh") return( weibull(c(1, pars), t, what="lh") )
}

gompertz <- function(pars, #gamma, lambda
                     t, what){
  # h(t) = \lambda exp(\gamma t)
  if (what=="H") return( pars[2]/pars[1] * (exp(pars[1]*t)-1) )
  if (what=="lh") return( log(pars[2]) + pars[1]*t )
}

lognormal <- function(pars, #mu, sigma
                      t, what){
  # h(t) = \phi(\log t -\mu \over \sigma) \over
  #   \sigma t [1-\Phi(\log t -\mu \over \sigma)]
  z <- (log(t)-pars[1])/pars[2]
  if (what=="H") return( -log(1-pnorm(z)) )
  if (what=="lh") return( log(dnorm(z)) - 
    log( pars[2] * t * (1-pnorm(z)) ) )
}

loglogistic <- function(pars, #alpha, kappa
                        t, what){
  # h(t) = \frac{\exp(\alpha) \kappa t^{\kappa-1} }{
  #   1 + \exp(\alpha) t^\kappa }
  if (what=="H") return( log(1+ exp(pars[1]) * t^(pars[2])) )
  if (what=="lh") return( pars[1] + log(pars[2])+ (pars[2]-1) * log(t) - 
    log(1+exp(pars[1])*t^pars[2]) )
}
