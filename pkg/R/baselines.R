################################################################################
#  Baseline hazard distributions                                               #
################################################################################
#                                                                              #
#  These are function with parameters                                          #
#   - pars: the distribution paramters vector                                  #
#   - t   : the (positive) time                                                #
#   - what: the quantity to be returned by the function                        #
#           either  "H", the cumulated hazard,                                 #
#               or "lh", the log-hazard                                        #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still 4 to check                                             #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################




################################################################################
#                                                                              #
#   Weibull baseline hazard function                                           #
#                                                                              #
#   Parameters:                                                                #
#    [1] rho    > 0                                                            #
#    [2] lambda > 0                                                            #
#                                                                              #
#   Hazard:                                                                    #
#    h(t) = \rho \lambda t^(\rho-1)                                            #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################


weibull <- function(pars,
                    t, 
                    what){
  if (min(t) < 0)
    stop("All times 't' must be non-negative!")
  if (pars[1] <=0 || pars[2] <=0)
    stop("Both the parameters ('rho' and 'lambda') must be positive!")
 
  if (what == "H")
    return(pars[2] * t^(pars[1]))
  else if (what == "lh")
    return(log(pars[1]) + log(pars[2]) + ((pars[1] - 1) * log(t)))
}



################################################################################
#                                                                              #
#   Exponential baseline hazard function                                       #
#                                                                              #
#   Parameters:                                                                #
#    [1] lambda                                                                #
#                                                                              #
#   Hazard:                                                                    #
#    h(t) = \lambda > 0                                                        #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

exponential <- function(pars,
                        t, 
                        what){
  if (min(t) < 0)
    stop("All times 't' must be non-negative!")
  if (pars <=0)
    stop("The parameter ('lambda') must be positive!")
  
  if (what == "H")
    return(weibull(c(1, pars), t, what="H"))
  else if (what == "lh") 
    return(weibull(c(1, pars), t, what="lh"))
}



################################################################################
#                                                                              #
#   Gompertz baseline hazard function                                          #
#                                                                              #
#   Parameters:                                                                #
#    [1] gamma  > 0                                                            #
#    [2] lambda > 0                                                            #
#                                                                              #
#   Hazard:                                                                    #
#    h(t) = \lambda exp(\gamma t)                                              #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

gompertz <- function(pars,
                     t, 
                     what){
  if (min(t) < 0)
    stop("All times 't' must be non-negative!")
  if (pars[1] <=0 || pars[2] <=0)
    stop("Both the parameters ('gamma' and 'lambda') must be positive!")
  
  if (what == "H") 
    return(pars[2] / pars[1] * (exp(pars[1] * t) - 1))
  else if (what == "lh") 
    return(log(pars[2]) + pars[1] * t)
}



################################################################################
#                                                                              #
#   Lognormal baseline hazard function                                         #
#                                                                              #
#   Parameters:                                                                #
#    [1] mu     \in \mathbb R                                                  #
#    [2] sigma  > 0                                                            #
#                                                                              #
#   Hazard:                                                                    #
#    h(t) = \frac{ \phi(\log t -\mu \over \sigma) }{                           #
#             \sigma t [1-\Phi(\log t -\mu \over \sigma)] }                    #
#                                                                              #
#   with \phi the density and \Phi the distribution functions                  #
#   of a standard Normal                                                       #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

lognormal <- function(pars,
                      t, 
                      what){
  if (min(t) < 0)
    stop("All times 't' must be non-negative!")
  if (pars[2] <=0)
    stop("The second parameter ('sigma') must be positive!")
  
  z <- (log(t) - pars[1]) / pars[2]
                      
  if (what == "H") 
    return(-log(1 - pnorm(z)))
  else if (what == "lh") 
    return(log(dnorm(z)) - 
           log( pars[2] * t * (1-pnorm(z))))
}



################################################################################
#                                                                              #
#   Loglogistic baseline hazard function                                       #
#                                                                              #
#   Parameters:                                                                #
#    [1] alpha \in \mathbb R                                                   #
#    [2] kappa > 0                                                             #
#                                                                              #
#   Hazard:                                                                    #
#    h(t) = \frac{ \exp(\alpha) \kappa t^{\kappa-1} }{                         #
#             1 + \exp(\alpha) t^\kappa }                                      #
#                                                                              #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

loglogistic <- function(pars,
                        t, 
                        what){
  if (min(t) < 0)
    stop("All times 't' must be non-negative!")
  if (pars[2] <=0)
    stop("The second parameter ('kappa') must be positive!")
  
  if (what == "H") 
    return(log(1 + exp(pars[1]) * t^(pars[2])))
  else if (what == "lh") 
    return(pars[1] + log(pars[2]) + (pars[2] - 1) * log(t) - 
           log(1 + exp(pars[1]) * t^pars[2]) )
}

