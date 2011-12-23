################################################################################
#  Minus the log-likelihood                                                    #
################################################################################
#                                                                              #
#  This function computes minus the logarithm of the likelihood function       #
#                                                                              #
#  Its parameters are                                                          #
#   - p      : the parameters vector, in the form                              #
#              c( frailty distribution parameter(s),                           #
#                 baseline hazard parameter(s),                                #
#                 regression parameter(s) )                                    #
#   - obs    : the observed data, in the form                                  #
#              list( time   = event/censoring times,                           #
#                   [trunc  = left truncation times, ]                         #
#                    event   = event indicators,                               #
#                    x       = covariate data.frame,                           #
#                    cluster = cluster ID vector,                              #
#                    ncl     = number of clusters,                             #
#                    di      = number of events per cluster                    #
#   - dist   : the baseline hazard distribution name                           #
#   - frailty: the frailty distribution name                                   #
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
#   On date: December 20, 2011                                                 #
################################################################################

Mloglikelihood <- function(p,
                           obs,
                           dist,
                           frailty) { 
  # ---- Assign the number of frailty parameters 'nFpar' ---------------------#
  # ---- and compute the polynomials Omega for the Positive Stable frailty ---#
  
  if (frailty == "none") 
    nFpar <- 0
  else if (frailty %in% c("gamma","ingau")) {
    theta <- exp(p[1])
    nFpar <- 1 
  }
  else if (frailty == "possta") {
    nu <- exp(-exp(p[1]))
    nFpar <- 1
    D <- max(obs$di)
    Omega <- matrix(NA, nrow=D+1, ncol=D)
    Omega[, 1] <- rep(1, D+1)
    
    if (D==2) { Omega[3, 2] <- 1/(1 - nu) - 1 } else if (D>2) {
      for(q in 3:(D+1))
        Omega[q, q-1] <- (1 - nu)^(2 - q) * prod(q - 1 + nu - seq(2, q-1, 1))
      for(m in 2:(D-1))
        for(q in (m+2):(D+1))
          Omega[q, m] <- Omega[q-1, m] + 
            (Omega[q-1, m-1] * ((q - 2) / (1 - nu) - (q - m)))
    }
  }
  
    
  # ---- Baseline hazard -----------------------------------------------------#
  
  # Reparametrisation and naming of baseline parameters
  if (dist == "weibull") { 
    pars <- c(rho    = exp(p[nFpar+1]),
              lambda = exp(p[nFpar+2]))
    beta <- p[-(1:(nFpar+2))]
  } else
  if (dist == "exponential") {
    pars <- c(lambda = exp(p[nFpar+1]))
    beta <- p[-(1:(nFpar+1))]
  } else
  if (dist == "gompertz") {
    pars <- c(gamma  = exp(p[nFpar+1]),
              lambda = exp(p[nFpar+2]))    
    beta <- p[-(1:(nFpar+2))]
  } else
  if (dist == "lognormal") {
    pars <- c(mu    = p[nFpar+1],
              sigma = exp(p[nFpar+2]))    
    beta <- p[-(1:(nFpar+2))]
  } else
  if (dist == "loglogistic") {
    pars <- c(alpha = p[nFpar+1],
              kappa = exp(p[nFpar+2]))    
    beta <- p[-(1:(nFpar+2))]
  }
  
  # baseline: from string to the associated function
  dist <- eval(parse(text=dist))

    
  # ---- Cumulative Hazard by cluster ----------------------------------------#
  
  cumhaz <- NULL
  cumhaz <- aggregate(
      dist(pars, obs$time, what="H") *
      exp(as.matrix(obs$x) %*% c(0, beta)), 
    by=list(obs$cluster), FUN=sum)[, 2]
  
  # Possible truncation
  if (!is.null(obs$trunc)) cumhaz <- cumhaz - aggregate(
      dist(pars, obs$trunc, what="H") *
      exp(as.matrix(obs$x) %*% c(0, beta)), 
    by=list(obs$cluster), FUN=sum)[, 2]

    
  # ---- log-hazard by cluster -----------------------------------------------#
  
  loghaz <- NULL
  loghaz <- aggregate(obs$event * (dist(pars, obs$time, what="lh") + 
    as.matrix(obs$x) %*% c(0, beta)),
    by=list(obs$cluster), FUN=sum)[, 2]

    
  # ---- log[ (-1)^di L^(di)(cumhaz) ]---------------------------------------#
    
  logSurv <- NULL
  if (frailty=="none")
    logSurv <- mapply(fr.none, cumhaz, what="logLT") else
  if (frailty=="gamma")
    logSurv <- mapply(fr.gamma, 
                      k=obs$di, s=cumhaz, theta=rep(theta, obs$ncl), 
                      what="logLT") 
  else if (frailty=="ingau")
    logSurv <- mapply(fr.ingau, 
                      k=obs$di, s=cumhaz, theta=rep(theta, obs$ncl), 
                      what="logLT") 
  else if (frailty=="possta"){
    logSurv <- rep(NA, obs$ncl)
    logSurv <- sapply(1:obs$ncl, 
                      function(x) fr.possta(k=obs$di[x], s=cumhaz[x], 
                                            nu=nu, Omega=Omega, 
                                            what="logLT") )
  }

    
  # ---- Minus the log likelihood --------------------------------------------#
  
  Mloglik <- -sum(loghaz + logSurv)
  return(Mloglik)
}
