Nloglikelihood <-
function(p, # parameters
  obs, dist="weibull", frailty="none")
{ # nFpar: number of frailty parameters
  if (frailty=="none") nFpar <- 0 else
  if (frailty%in%c("gamma","ingau")){
    theta <- exp(p[1])
    nFpar <- 1 
  } else
  if (frailty=="possta"){
    theta <- exp(-exp(p[1]))
    nFpar <- 1
    D <- max(obs$di)
    Omega <- matrix(NA, nrow=D+1, ncol=D)
    Omega[, 1] <- rep(1, D+1)
    
    if (D==2) { Omega[3,2] <- 1/theta - 1 } else if (D>2) {
      for(q in 3:(D+1))
        Omega[q, q-1] <- theta^(2 - q) * prod(q - theta - seq(2, q-1, 1))
      for(m in 2:(D-1))
        for(q in (m+2):(D+1))
          Omega[q, m] <- Omega[q-1, m] + 
            (Omega[q-1, m-1] * ((q - 2) / theta - (q - m)))
    }
  }
  
  if (dist=="weibull"){ 
    pars <- c(rho = exp(p[nFpar+1]),
              lambda = exp(p[nFpar+2]))
    beta <- p[-(1:(nFpar+2))]
  } else
  if (dist=="exponential"){
    pars <- c(lambda = exp(p[nFpar+1]))
    beta <- p[-(1:(nFpar+1))]
  } else
  if (dist=="gompertz"){
    pars <- c(gamma = exp(p[nFpar+1]),
              lambda = exp(p[nFpar+2]))    
    beta   <- p[-(1:(nFpar+2))]
  } else
  if (dist=="lognormal"){
    pars <- c(mu = p[nFpar+1],
              sigma = exp(p[nFpar+2]))    
    beta   <- p[-(1:(nFpar+2))]
  } else
  if (dist=="loglogistic"){
    pars <- c(alpha = p[nFpar+1],
              kappa = exp(p[nFpar+2]))    
    beta   <- p[-(1:(nFpar+2))]
  }
  
  cumhaz <- logSurv <- loghaz <- NULL
  dist <- eval(parse(text=dist))

  cumhaz <- aggregate(
      dist(pars, obs$time, what="H") *
      if (is.null(obs$x)) 1 else exp(as.matrix(obs$x) %*% beta), 
    by=list(obs$cluster), FUN=sum)[, 2]
  
  if (!is.null(obs$trunc)) cumhaz <- cumhaz - aggregate(
      dist(pars, obs$time, what="H") *
      if (is.null(obs$x)) 1 else exp(as.matrix(obs$x) %*% beta), 
    by=list(obs$cluster), FUN=sum)[, 2]
  
  if (frailty=="none")
    logSurv <-mapply(fr.none, cumhaz, what="logLT") else
  if (frailty=="gamma")
    logSurv <-mapply(fr.gamma, obs$di, cumhaz, rep(theta, obs$ncl), what="logLT") else
  if (frailty=="ingau")
    logSurv <-mapply(fr.ingau, obs$di, cumhaz, rep(theta, obs$ncl), what="logLT") else
  if (frailty=="possta"){
    logSurv <- rep(NA, obs$ncl)
    for(i in 1:obs$ncl) logSurv[i] <- fr.possta(obs$di[i], cumhaz[i], theta, Omega, what="logLT")
  }
  loghaz <- aggregate(obs$event * (dist(pars, obs$time, what="lh") + 
      if (is.null(obs$x)) 0 else (as.matrix(obs$x) %*% beta)),
    by=list(obs$cluster), FUN=sum)[, 2]
 
  Nloglik <- -sum(loghaz + logSurv)
  return(Nloglik)
}
