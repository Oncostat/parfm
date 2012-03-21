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
#                    x       = covariate data.frame, intercept included        #
#                    cluster = cluster ID vector,                              #
#                    ncl     = number of clusters,                             #
#                    di      = vector giving the numbers of events per cluster #
#   - dist   : the baseline hazard distribution name                           #
#   - frailty: the frailty distribution name                                   #
#   - correct  : (only for possta) the correction to use in case of many       #
#                events per cluster to get finite likelihood values.           #
#                When correct!=0 the likelihood is divided by                  #
#                10^(#clusters * correct) for computation,                     #
#                but the value of the log-likelihood in the output             #
#                is the re-adjusted value.                                     #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2011                                                   #
#   Last modification on: March 21, 2012                                       #
################################################################################

Mloglikelihood <- function(p,
                           obs,
                           dist,
                           frailty,
                           correct) { 
  # ---- Assign the number of frailty parameters 'obs$nFpar' ---------------------#
  # ---- and compute Omega for the Positive Stable frailty -------------------#
  
  if (frailty %in% c("gamma","ingau")) {
    theta <- exp(p[1])
  } else if (frailty == "possta") {
    nu <- exp(-exp(p[1]))
    D <- max(obs$dqi)
    Omega <- Omega(D, correct=correct, nu=nu)
  }
  
    
  # ---- Baseline hazard -----------------------------------------------------#
  
  # baseline parameters
  if (dist == "weibull") { 
    pars <- cbind(rho    = exp(p[obs$nFpar + 1:obs$nstr]),
                  lambda = exp(p[obs$nFpar + obs$nstr + 1:obs$nstr]))
    beta <- p[-(1:(obs$nFpar + 2 * obs$nstr))]
  } else
    if (dist == "exponential") {
      pars <- cbind(lambda = exp(p[obs$nFpar+1:obs$nstr]))
      beta <- p[-(1:(obs$nFpar + obs$nstr))]
    } else
      if (dist == "gompertz") {
        pars <- cbind(gamma  = exp(p[obs$nFpar + 1:obs$nstr]),
                      lambda = exp(p[obs$nFpar + obs$nstr + 1:obs$nstr]))    
        beta <- p[-(1:(obs$nFpar + 2 * obs$nstr))]
      } else
        if (dist == "lognormal") {
          pars <- cbind(mu    = p[obs$nFpar + 1:obs$nstr],
                        sigma = exp(p[obs$nFpar + obs$nstr + 1:obs$nstr]))    
          beta <- p[-(1:(obs$nFpar + 2 * obs$nstr))]
        } else
          if (dist == "loglogistic") {
            pars <- cbind(alpha = p[obs$nFpar + 1:obs$nstr],
                          kappa = exp(p[obs$nFpar + obs$nstr + 1:obs$nstr]))    
            beta <- p[-(1:(obs$nFpar + 2 * obs$nstr))]
  }
  rownames(pars) <- levels(as.factor(obs$strata))
  
  # baseline: from string to the associated function
  dist <- eval(parse(text=dist))

    
  # ---- Cumulative Hazard by cluster and by strata --------------------------#
  
  cumhaz <- NULL
  if (frailty == "none") { ### NO FRAILTY
    cumhaz <- sum(apply(cbind(rownames(pars), pars), 1,
                        function(x) {
                          sum(dist(as.numeric(x[-1]), 
                                   obs$time[obs$strata==x[1]], what="H") * 
                                     exp(as.matrix(obs$x[obs$strata==x[1], ]) %*% 
                                     c(0, beta)))
                        }))
    
    # Possible truncation
    if (!is.null(obs$trunc)) 
      cumhaz <- cumhaz - sum(
        apply(cbind(rownames(pars), pars), 1,
              function(x) {
                sum(dist(as.numeric(x[-1]), 
                         obs$trunc[obs$strata==x[1]], what="H") * 
                           exp(as.matrix(obs$x[obs$strata==x[1], ]) %*% 
                           c(0, beta)))
              }))
  } else { ### FRAILTY
    cumhaz <- aggregate(
      apply(cbind(t=obs$time, s=obs$strata, as.matrix(obs$x)), 1,
            function(x) {
              dist(pars[x["s"], ], x["t"], what="H") * 
                     exp(x[-(1:2)] %*% c(0, beta))
            }), 
      by=list(obs$cluster), FUN=sum)[, 2]
    
    # Possible truncation
    if (!is.null(obs$trunc)) 
      cumhaz <- cumhaz - aggregate(
        apply(cbind(t=obs$trunc, s=obs$strata, as.matrix(obs$x)), 1,
              function(x) {
                dist(pars[x["s"], ], x["t"], what="H") * 
                  exp(x[-(1:2)] %*% c(0, beta))
              }), 
        by=list(obs$cluster), FUN=sum)[, 2]
  }
  
  # ---- log-hazard by cluster -----------------------------------------------#
  
  loghaz <- NULL
  if (frailty == "none") {
    loghaz <- sum(apply(cbind(rownames(pars), pars), 1,
                        function(x) {
                          sum(obs$event[obs$strata==x[1]] * (
                            dist(as.numeric(x[-1]), 
                                 obs$time[obs$strata==x[1]], what="lh") + 
                                   as.matrix(obs$x[obs$strata==x[1], ]) %*% 
                                   c(0, beta)))
                        }))
  } else {
    loghaz <- aggregate(
      apply(cbind(t=obs$time, s=obs$strata, e=obs$event, as.matrix(obs$x)), 1,
            function(x) {
              x["e"] * (dist(pars[x["s"], ], x["t"], what="lh") + 
                x[-(1:3)] %*% c(0, beta))
            }), 
      by=list(obs$cluster), FUN=sum)[, 2]
  }

    
  # ---- log[ (-1)^di L^(di)(cumhaz) ]---------------------------------------#
    
  logSurv <- NULL
  if (frailty=="none") {
    logSurv <- mapply(fr.none, s=cumhaz, what="logLT")
  } else if (frailty=="gamma") {
    logSurv <- mapply(fr.gamma, 
                      k=obs$di, s=cumhaz, theta=rep(theta, obs$ncl), 
                      what="logLT") 
  } else if (frailty=="ingau") {
    logSurv <- mapply(fr.ingau, 
                      k=obs$di, s=cumhaz, theta=rep(theta, obs$ncl), 
                      what="logLT") 
  } else if (frailty=="possta") {
    logSurv <- sapply(1:obs$ncl, 
                      function(x) fr.possta(k=obs$di[x], s=cumhaz[x], 
                                            nu=nu, Omega=Omega, 
                                            what="logLT",
                                            correct=correct))
  }

    
  # ---- Minus the log likelihood --------------------------------------------#
  
  Mloglik <- -sum(loghaz + logSurv)
  attr(Mloglik, "cumhaz") <- cumhaz
  return(Mloglik)
}

