################################################################################
#  Frailty distributions                                                       #
################################################################################
#                                                                              #
#  These are functions with parameters                                         #
#   - k    : the order of the derivative of the Laplace transform              #
#   - s    : the argument of the Laplace transform                             #
#   - theta: the heterogeneity parameter of the frailty distribution           #
#   - what : the quantity to be returned by the function                       #
#            only "logLT" can be chosen, giving                                #
#                                                                              #
#            \log[ (-1)^k \mathcal L^(k)(s) ]                                  #
#                                                                              #
#            with \mathcal L(s) the Laplace transofrm                          #
#            and \mathcal L^(k)(s) its k-th derivative                         #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: still 1 to be checked                                        #
#   Comments: J'ai remplace 'if ... else' par 'ifelse'                         #
#             J'ai enleve 'stop ...'                                           #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 20, 2011                                                 #
################################################################################



################################################################################
#                                                                              #
#   No frailty distribution                                                    #
#                                                                              #
#   Maybe to elimitate                                                         #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: still to check                                               #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

fr.none <- function(k,
                    s,
                    theta,
                    what="logLT"){
  if (what=="logLT")
    return( -s)
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
#   Date: December, 19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 20, 2011                                                 #
################################################################################

fr.gamma <- function(k,
                     s, 
                     theta, 
                     what="logLT"){
  if (what=="logLT") {
    res <- ifelse(k == 0, 
                  - 1 / theta  * log(1 + theta * s),
                  - (k + 1 / theta) * log(1 + theta * s) +
                    sum(log(1 + (seq(0, k-1) * theta))))
    return(res)
  }
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
#   Date: December, 19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments: Il y avait un signe '-' de trop, et un '-' qui devait etre '+'   #                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 20, 2011                                                 #
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
}




################################################################################
#                                                                              #
#   Second part of the LT of the Positive Stable frailty distribution          #
#                                                                              #
#                                                                              #
#   Date: December 20, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments: Dans la fct J, j'ai change 'q' en 'k'                            #
#             J'ai mis J a l'exterieur, sinon J est recreee a chaque fois      #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 20, 2011                                                 #
################################################################################

J <- function(k, s, theta, Omega){
  if(k == 0){sum <- 1} else {
    sum <- 0
    for(m in 0:(k-1)){
      sum <- sum + (Omega[k+1, m+1] * s^(-m * theta))
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
#     [3] theta = 1-nu, in (0, 1)                                              #
#     [4] Omega is the matrix that contains the omega's                        #
#                                                                              #
#   Date: December  19, 2011                                                   #
#                                                                              #
################################################################################
#   Check status: checked                                                      #
#   Comments: Dans la fct J, j'ai change 'q' en 'k'                            #
#             J'ai mis J a l'exterieur, sinon J est recreee a chaque fois      #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date: December 20, 2011                                                 #
################################################################################

fr.possta <- function(k, 
                      s, 
                      theta, 
                      Omega, 
                      what="logLT"){
  if (what=="logLT") {
    res <- k * (log(theta) + ((theta - 1) * log(s))) - s^(theta) + 
      log(J(k, s, theta, Omega))
    return(res)
  }
}

