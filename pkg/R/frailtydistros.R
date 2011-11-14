############################
#  Frailty distributions   #
#  log[ (-1)^k L^(k)(s) ]  #
############################

fr.none <- function(s, what="logLT"){
  if (what=="logLT") return( -s)
}

fr.gamma <- function(k, s, theta, what="logLT"){
  if (what=="logLT") {
    if (k == 0) { 
      res <- -(1 / theta)  * log(1 + (theta * s))
    } else {
      res <- -(k + (1 / theta)) * log(1 + (theta * s)) +
        sum(log(1 + (seq(0, k-1) * theta)))
    }
    return(res)
  }
}

fr.ingau <- function(k, s, theta, what="logLT"){
  if (what=="logLT") {
    z <- sqrt(2 * theta^(-1) * (s + (0.5 * theta^(-1))))
    if (k == 0) {
      res <- (1 / theta) * (1 - sqrt(1 + (2 * theta * s))) 
    } else {
      res <- - 0.5 * log((2 * theta * s) + 1) +
        log(besselK(z, k - 0.5)) - log(besselK(z, k - 1.5)) +
        fr.ingau(k - 1, s, theta, what="logLT")
    }
    return(res)
  }
}

fr.possta <- function(k, s, theta, Omega, what="logLT"){
  if (what=="logLT") {
    J <- function(q, s, theta, Omega){
      if(q == 0){ sum <- 1} else {
        sum <- 0
        for(m in 0:(q-1)){
          sum <- sum + (Omega[q+1, m+1] * s^(-m * theta))
        }
      }
      return(sum)
    }
    res <- k * (log(theta) + ((theta - 1) * log(s))) - s^(theta) + 
      log(J(k, s, theta, Omega))
    return(res)
  }
}
