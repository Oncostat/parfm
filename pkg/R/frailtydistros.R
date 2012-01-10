################################################################################
#  Frailty distributions                                                       #
################################################################################
#                                                                              #
#  These are functions with parameters                                         #
#   - k        : the order of the derivative of the Laplace transform          #
#   - s        : the argument of the Laplace transform                         #
#   - theta/nu : the heterogeneity parameter of the frailty distribution       #
#   - what     : the quantity to be returned by the function,                  #
#                either "logLT" for \log[ (-1)^k \mathcal L^(k)(s) ]           #                      #
#                with \mathcal L(s) the Laplace transofrm                      #
#                and \mathcal L^(k)(s) its k-th derivative,                    #
#                or "tau", the Kendall's Tau                                   #
#                                                                              #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################



################################################################################
#                                                                              #
#   No frailty distribution                                                    #
#                                                                              #
#   Maybe to elimitate                                                         #
#                                                                              #
#                                                                              #
#   Date: December 21, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################

fr.none <- function(s,
                    what="logLT"){
  if (what=="logLT")
    return(-s)
  else if (what == "tau")
    return(NA)
}



################################################################################
#                                                                              #
#   Gamma frailty distribution                                                 #
#                                                                              #
#   Density:                                                                   #
#    f(u) = \frac{                                                             #
#     \theta^{-\frac1\theta}  u^{\frac1\theta - 1}  \exp( -u / \theta)         #
#    }{                                                                        #
#     \Gamma(1 / \theta) }                                                     #
#                                                                              #
#   Arguments of fr.gamma:                                                     #
#     [1] k = 0, 1, ...                                                        #
#     [2] s > 0                                                                #
#     [3] theta > 0                                                            #
#                                                                              #
#   Date: December 21, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################

fr.gamma <- function(k,
                     s, 
                     theta, 
                     what="logLT"){
  if (what=="logLT") {
    res <- ifelse(k == 0, 
                  - 1 / theta  * log(1 + theta * s),
                  - (k + 1 / theta) * log(1 + theta * s) +
                    sum(log(1 + (seq(from=0, to=k-1, by=1) * theta))))
    return(res)
  }
  else if (what == "tau")
    return(theta / (theta + 2))
}



################################################################################
#                                                                              #
#   Inverse Gaussian frailty distribution                                      #
#                                                                              #
#   Density:                                                                   #
#    f(u) = \frac1{ \sqrt{2 \pi \theta} }  u^{-\frac32}                        #
#           \exp( -\frac{(u-1)^2}{2 \theta u} )                                #
#                                                                              #
#   Arguments of fr.ingau:                                                     #
#     [1] k = 0, 1, ...                                                        #
#     [2] s > 0                                                                #
#     [3] theta > 0                                                            #
#                                                                              #
#   Date: December 20, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################

fr.ingau <- function(k, 
                     s, 
                     theta, 
                     what="logLT"){
  if (what=="logLT") {
    z <- sqrt(2 * theta^(-1) * (s + 0.5 * theta^(-1)))
    res <- ifelse(k == 0,
                  1 / theta * (1 - sqrt(1 + 2 * theta * s)),
                  - k / 2 * log(2 * theta * s + 1) +
                    log(besselK(z, k - 0.5)) - 
                    (log(pi / (2 * z)) / 2 - z) +
                    1 / theta * (1 - sqrt(1 + 2 * theta * s)))
    return(res)
  }
  else if (what == "tau") {
          integrand <- function(u) {
          	return(exp(-u) / u)
        	}
        	int <- integrate(integrand,
                           lower=(2/theta), 
                           upper=Inf)$value
        	return(0.5 - (1 / theta) + (2 * theta^(-2) * exp(2 / theta) * int))
        }
}



################################################################################
#                                                                              #
#   Sum of the polynomials Omega for the Positive Stable frailty distribution  #
#                                                                              #
#                                                                              #
#   Date: December 20, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################

J <- function(k, s, nu, Omega){  
  if(k == 0) sum <- 1 else {
    sum <- 0
    for(m in 0:(k - 1)) {
      sum <- sum + (Omega[k, m + 1] * s^(-m * (1 - nu)))
    }
  }
  return(sum)
}



################################################################################
#                                                                              #
#   Positive Stable frailty distribution                                       #
#                                                                              #
#   Density:                                                                   #
#    f(u) = -\frac1{\pi u}                                                     #
#           \sum_{k=1}^\infty \frac{ \Gamma( k (1 - \nu) + 1) }{ k! }          #
#           ( -u^{\nu-1} )^k  \sin( (1-\nu) k \pi)                             #
#                                                                              #
#   Arguments of fr.possta:                                                    #
#     [1] k = 0, 1, ...                                                        #
#     [2] s > 0                                                                #
#     [3] nu in (0, 1)                                                         #
#     [4] Omega is the matrix that contains the omega's                        #
#                                                                              #
#   Date: December 21, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 27, 2011                                                 #
################################################################################

fr.possta <- function(k,
                      s,
                      nu,
                      Omega,
                      what="logLT"){
  if (what=="logLT") {
    res <- k * (log(1 - nu) - nu * log(s)) - s^(1 - nu) + 
      log(J(k, s, nu, Omega))
    return(res)
  }
  else if (what == "tau")
    return(nu)
}
