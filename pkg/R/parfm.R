parfm <-
function(formula, cluster, data, inip=NULL, initheta=1,
  dist="weibull", frailty="none", method="Nelder-Mead",
  maxit=5000){
  obsdata <- NULL
  obsdata$cluster <- eval(parse(text=paste("data$", cluster, sep="")))
  obsdata$time <- eval(parse(text=paste("data$", formula[[2]][[2]], sep="")))
  if (length(formula[[2]])==3){
    obsdata$event <- eval(parse(text=paste("data$", formula[[2]][[3]], sep="")))
  } else if (length(formula[[2]])==4){
    obsdata$trunc <- eval(parse(text=paste("data$", formula[[2]][[3]], sep="")))
    obsdata$event <- eval(parse(text=paste("data$", formula[[2]][[4]], sep="")))
  }
  obsdata$x <- as.data.frame(model.matrix(formula, data=data)[,-1])
  
  if(!is.null(cluster)){
    obsdata$ncl <- length(levels(as.factor(obsdata$cluster)))
    obsdata$di <- aggregate(obsdata$event, by=list(obsdata$cluster), FUN=sum)[, 2]
  }
  #if (!is.null(data$x)&&class(data$x)!="data.frame") 
  #  stop("The covariates object 'x' must be of class 'data.frame'!")
  if (!(frailty%in%c("none", "gamma", "ingau", "possta"))) stop("Invalid frailty distribution!")
  
  res <- NULL
  
  #------Dimensions-------------#
  if (frailty=="none") nFpar <- 0 else
    if (frailty%in%c("gamma","ingau","possta")) nFpar <- 1
  if (dist=="exponential") nBpar <- 1 else
    if (dist%in%c("weibull","gompertz","lognormal","loglogistic")) nBpar <- 2
 
  #------Initial parameters-----#
  if (!is.null(inip)){
      if (length(inip)!=(nBpar+ncol(model.matrix(formula, data=data)))) stop(
        paste("Number of initial parameters 'inip' must be "),
        nBpar+ncol(model.matrix(formula, data=data)))
  if (dist%in%c("exponential","weibull","gompertz")) { 
                #lambda,       rho,      gamma
    p.init <- log(inip[1])}
  if (dist%in%c("weibull","gompertz","lognormal","loglogistic")) { 
                #lambda,   lambda,    sigma,      kappa
    p.init <- log(inip[2]) }
  p.init <- inip[(nBpar+1):length(inip)] #beta
     
  } else { #------Initialization via semipar cox model------#
    library(eha)
    shape = 0
    d = dist
    if (d=="exponential") {d="weibull"; shape=1}
    coxMod <- phreg(formula, data=data, dist=d, shape=shape)
    shape <- as.numeric(exp(coxMod$coefficients["log(shape)"]))
    scale <- as.numeric(exp(coxMod$coefficients["log(scale)"]))
    if (dist=="exponential"){
      p.init <- -log(scale)                # log(lambda)
    } else
    if (dist=="weibull"){
      p.init <- c( log(shape),             # log(rho)
                  -shape * log(scale) )    # log(lambda)
    } else
    if (dist=="gompertz"){
      p.init <- c( -log(scale),            #log(gamma)
                    log(shape) )           #log(lambda)
    } else
    if (dist=="lognormal"){
      p.init <- c( log(scale),             #mu
                   -log(shape) )           #log(sigma)
    } else
    if (dist=="loglogistic"){
      p.init <- c( -shape*log(scale),      #alpha
                   log(shape) )            #log(kappa)
    }
    p.init <- c(p.init, coxMod$coefficients[1:(length(coxMod$coefficients)-nBpar)] )
  }
        
  # Frailty parameters inizialization #
  if (frailty=="none") pars <- NULL else
  if (frailty%in%c("gamma","ingau")) pars <- log(initheta)
  if (frailty=="possta") {
    if (is.null(initheta)||initheta==1) initheta<-.5
    pars <- log(-log(initheta))
  }


  #################################################################
  #------Negative log-likelihood minimization --------------------#
  #################################################################
  pars <-c(pars, p.init)
  if ((frailty=="none")&&is.null(inip)) res <- list(par=pars) else
    res <- optim(pars, Nloglikelihood, method=method,
      obs=obsdata, dist=dist, frailty=frailty, hessian=TRUE,
      control=c(maxit=maxit))
  #################################################################

  
  #------Recover the frailty paramters estimates------#
  if (frailty%in%c("gamma","ingau")){
    theta <- exp(res$par[1])
  } else
  if (frailty=="possta"){
    theta <- exp(-exp(res$par[1]))
  }
  #------Recover the baseline paramters estimates------#
  if (dist=="exponential"){
    lambda <- exp(res$par[nFpar+1])
    ESTIMATE <- c(lambda=lambda)
  } else
  if (dist=="weibull"){
    rho    <- exp(res$par[nFpar+1])
    lambda <- exp(res$par[nFpar+2])
    ESTIMATE <- c(rho=rho, lambda=lambda)
  } else
  if (dist=="gompertz"){
    gamma  <- exp(res$par[nFpar+1])
    lambda <- exp(res$par[nFpar+2])
    ESTIMATE <- c(gamma=gamma, lambda=lambda)
  } else
  if (dist=="lognormal"){
    mu     <- res$par[nFpar+1]
    sigma  <- exp(res$par[nFpar+2])
    ESTIMATE <- c(mu=mu, sigma=sigma)
  } else
  if (dist=="loglogistic"){
    alpha  <- res$par[nFpar+1]
    kappa  <- exp(res$par[nFpar+2])
    ESTIMATE <- c(alpha=alpha, kappa=kappa)
  }
  #------Recover the regression coefficients estimates------#
  beta=res$par[-(1:(nFpar+nBpar))]  
  ESTIMATE <- c(ESTIMATE, beta=beta )


  #------Obtain their standard dev------ 
  if ((frailty=="none")&&is.null(inip)) {
    VAR <- coxMod$var[c("log(shape)","log(scale)"),c("log(shape)","log(scale)")]
    if (dist=="exponential") D <- c(1, 0, log(lambda), -lambda) else
    if (dist=="weibull")     D <- c(1/rho, 0, rho*log(lambda), -rho*lambda^rho) else
    if (dist=="gompertz")    D <- c(0, gamma, 1/lambda, 0) else
    if (dist=="lognormal")   D <- c(0, exp(-mu), -sigma, 0) else
    if (dist=="loglogistic") D <- c(alpha/kappa, -kappa*exp(alpha/kappa), 1/kappa, 0)
    D <- matrix(D,2)
    V <- D %*% VAR %*% t(D)
    var <- c(diag(V), diag(coxMod$var)[1:(dim(coxMod$var)[1]-2)])
  } else {  
    var <- diag(solve(res$hessian))
    if (frailty%in%c("gamma","ingau")) se.theta <- sqrt(var[1] * theta^2)
    if (frailty=="possta") se.theta <- sqrt(var[1] * (theta*log(theta))^2)
  }

  if (dist=="exponential"){SE <- c(
    se.lambda = sqrt(var[nFpar+1] * lambda^2) )
  } else
  if (dist=="weibull"){SE <- c(
    se.rho = sqrt(var[nFpar+1] * rho^2),
    se.lambda = sqrt(var[nFpar+1] * lambda^2) )
  } else
  if (dist=="gompertz"){SE <- c(
    se.gamma = sqrt(var[nFpar+1] * gamma^2), 
    se.lambda = sqrt(var[nFpar+1] * lambda^2) )
  } else
  if (dist=="lognormal"){SE <- c(
    se.mu = sqrt(var[nFpar+1]),
    se.sigma = sqrt(var[nFpar+2] * sigma^2) )
  } else
  if (dist=="loglogistic"){SE <- c(
    se.alpha = sqrt(var[nFpar+1]),
    se.kappa = sqrt(var[nFpar+2] * kappa^2) )
  }

  se.beta <- sqrt(var[-(1:(nFpar+nBpar))])
  SE <- c(SE, se.beta=se.beta)
    
  
  #------Output------
  res <- cbind(ESTIMATE, SE,
    "p-val"=c(rep(NA, nBpar), 2*pt(-abs(beta/se.beta), nrow(data)-1-length(beta)+nBpar)))
    #"p-val"=c(NA, NA, 2*pnorm(-abs(beta/se.beta))))
  if (frailty%in%c("gamma","ingau")) res <- rbind(res, theta=c(theta, se.theta, NA))
  if (frailty%in%c("possta")) res <- rbind(res, theta=c(theta, se.theta, NA))
  
  class(res) <- c("parfm", class(res))
  attributes(res)$loglik <- -Nloglikelihood(p=pars, obs=obsdata, dist=dist, frailty=frailty)
  attributes(res)$dist <- dist
  attributes(res)$frailty <- frailty
  
  return(res)
}

