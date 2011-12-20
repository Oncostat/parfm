################################################################################
#  Parametric frailty models fitting                                           #
################################################################################
#                                                                              #
#  This function is the core of the package,                                   #
#   performing estimation and returning results.                               #
#                                                                              #
#  It is also the front-end of the package,                                    #
#   being the only that will be visible to the user.                           #
#                                                                              #
#  Its parameters are                                                          #
#   - formula  : a formula object, with the response                           #
#                on the left of a ~ operator,                                  #
#                and the terms on the right.                                   #
#                The response must be a survival object                        #
#                as returned by the Surv function.                             #
#   - cluster  : the name of the variable in data containing cluster IDs       #
#   - data     : a data.frame in which to interpret the variables named        #
#                in the formula.                                               #
#   - inip     : initial values of parameters                                  #
#   - initheta : initial value of the frailty theta                            #
#   - dist     : the name of the baseline hazard                               #
#   - frailty  : the name of the frailty distribution                          #
#   - method   : optimization method (See optim())                             #
#   - maxit    : max number of iteration (See optim())                         #
#                                                                              #
#                                                                              #
#   Date: December 20, 2011                                                    #
#                                                                              #
################################################################################
#   Check status: **still to check**                                           #
#   Comments:                                                                  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#   On date:                                                                   #
################################################################################

parfm <- function(formula,
                  cluster,
                  data,
                  inip=NULL,
                  initheta=NULL,
                  dist="weibull",
                  frailty="none",
                  method="Nelder-Mead",
                  maxit=5000){
  if (!(frailty %in% c("none", "gamma", "ingau", "possta")))
    stop("Invalid frailty distribution!")
  

  #----- Data in a Mloglikelihood form ----------------------------------------#  
  
  obsdata <- NULL
  # times
  obsdata$time <- eval(parse(text=paste("data$", 
                                        formula[[2]][[2]], sep="")))
    if (length(formula[[2]])==3) {
      obsdata$event <- eval(parse(text=paste("data$", 
                                             formula[[2]][[3]], sep="")))
    } else if (length(formula[[2]])==4) {
      obsdata$trunc <- eval(parse(text=paste("data$", 
                                             formula[[2]][[3]], sep="")))
      obsdata$event <- eval(parse(text=paste("data$", 
                                             formula[[2]][[4]], sep="")))
    }
  # covariates
  obsdata$x <- as.data.frame(model.matrix(formula, data=data)[,-1])
  # clusters
  obsdata$cluster <- eval(parse(text=paste("data$", cluster, sep="")))
    if(!is.null(cluster)){
      # Number of clusters
      obsdata$ncl <- length(levels(as.factor(obsdata$cluster)))
      # Number of events per cluster
      obsdata$di  <- aggregate(obsdata$event, 
                               by=list(obsdata$cluster), FUN=sum)[, 2]
    }
  
  
  #----- Dimensions ----------------------------------------------------------#
  
  # nFpar: number of frailty parameters
  if (frailty=="none") 
    nFpar <- 0 
  else if (frailty %in% c("gamma","ingau","possta")) 
    nFpar <- 1
    
  # nBpar: number of baseline parameters
  if (dist == "exponential") 
    nBpar <- 1 
  else if (dist %in% c("weibull","gompertz","lognormal","loglogistic")) 
    nBpar <- 2
 
 
  #----- Initial parameters ---------------------------------------------------#
  
  if (!is.null(inip)) {
    # If there are initial parameters, check the right dimension
    # and reparametrise into the whole Real line
    
    if (length(inip) != (nBpar+ncol(model.matrix(formula, data=data))))
      stop( paste("Number of initial parameters 'inip' must be ",
                  nBpar+ncol(model.matrix(formula, data=data))) )
    if (dist %in% c("exponential","weibull","gompertz"))             # 1st par
      p.init <- log(inip[1]) # lambda, rho, gamma
    if (dist %in% c("weibull","gompertz","lognormal","loglogistic")) # 2nd par
      p.init <- log(inip[2]) # lambda, lambda, sigma, kappa
    # the remaining are beta
    p.init <- inip[(nBpar+1):length(inip)]
  } else {
    # In case of unspecified inital values, 
    # a parametric Cox model is fitted
    
    shape = 0 # if shape is 0 or negative phreg estimates it
    d = dist
    if (d == "exponential") {
      d <- "weibull"
      shape <- 1 # if shape is positive phreg takes it as fixed
    }
    
    require(eha)
    coxMod <- phreg(formula, data=data, dist=d, shape=shape)
    
    logshape <- as.numeric(coxMod$coefficients["log(shape)"])
    logscale <- as.numeric(coxMod$coefficients["log(scale)"])
    if (dist=="exponential"){
      p.init <-   -logscale                   # log(lambda)
    } else
    if (dist=="weibull"){
      p.init <- c( logshape,                  # log(rho)
                  -exp(logshape) * logscale ) # log(lambda)
    } else
    if (dist=="gompertz"){
      p.init <- c(-logscale,                  # log(gamma)
                  logshape )                  # log(lambda)
    } else
    if (dist=="lognormal"){
      p.init <- c( logscale,                  # mu
                  -logshape )                 # log(sigma)
    } else
    if (dist=="loglogistic"){
      p.init <- c(-exp(logshape)*logscale,    # alpha
                   logshape )                 # log(kappa)
    }
    p.init <- c(p.init, 
                coxMod$coefficients[1:(length(coxMod$coefficients)-nBpar)] )
  }
        
  # --- Frailty parameters inizialization --- #
  if (frailty=="none")
    pars <- NULL
  else if (frailty %in% c("gamma","ingau")) {
    if (is.null(initheta))
      initheta <- 1
    else if (initheta <= 0)
      stop("Initial value of frailty variance 'initheta' must be positive!")
    pars <- log(initheta)
  }
  else if (frailty == "possta") {
    if (is.null(initheta)) 
      initheta <- .5
    else if (initheta <= 0 || initheta >= 1)
      stop("Initial value of frailty theta 'initheta' must be in (0,1)!")
    pars <- log(-log(initheta))
  }


  #############################################################################
  #------ Minus log-likelihood minimization (begin) --------------------------#
  #############################################################################
  pars <-c(pars, p.init)
  extime <- system.time({ res <- NULL })
  if ((frailty=="none") && is.null(inip))
    res <- list(par=pars) 
  else
    extime <- system.time({res <- optim(pars, Mloglikelihood, method=method,
                                        obs=obsdata, dist=dist, frailty=frailty, 
                                        hessian=TRUE, control=c(maxit=maxit))
    })[1]
  #############################################################################
  #------ Minus log-likelihood minimization (end) ----------------------------#
  #############################################################################

  
  #----- Recover the frailty paramters estimates -----#
  if (frailty %in% c("gamma","ingau"))
    theta <- exp(res$par[1])
  else if (frailty == "possta")
    theta <- exp(-exp(res$par[1]))
  
  #----- Recover the baseline paramters estimates -----#
  if (dist=="exponential"){
    lambda <- exp(res$par[nFpar+1])
    ESTIMATE <- c(lambda=lambda)
  }
  else if (dist=="weibull"){
    rho    <- exp(res$par[nFpar+1])
    lambda <- exp(res$par[nFpar+2])
    ESTIMATE <- c(rho=rho, lambda=lambda)
  }
  else if (dist=="gompertz"){
    gamma  <- exp(res$par[nFpar+1])
    lambda <- exp(res$par[nFpar+2])
    ESTIMATE <- c(gamma=gamma, lambda=lambda)
  } 
  else if (dist=="lognormal"){
    mu     <- res$par[nFpar+1]
    sigma  <- exp(res$par[nFpar+2])
    ESTIMATE <- c(mu=mu, sigma=sigma)
  } 
  else if (dist=="loglogistic"){
    alpha  <- res$par[nFpar+1]
    kappa  <- exp(res$par[nFpar+2])
    ESTIMATE <- c(alpha=alpha, kappa=kappa)
  }
  
  #----- Recover the regression coefficients estimates -----#
  beta     <- res$par[-(1:(nFpar+nBpar))]  
  ESTIMATE <- c(ESTIMATE, beta=beta)


  #----- Obtain their standard dev -----#
  if ((frailty == "none") && is.null(inip)) {
    # reeeeeeeeeeeeeaaaaally to carefully check and re-check
    # maybe to eliminate............................................................
    VAR <- coxMod$var[c("log(shape)","log(scale)"),
                      c("log(shape)","log(scale)")]
    if (dist=="exponential") 
      D <- c(1, 0, log(lambda), -lambda)
    else if (dist == "weibull")     
      D <- c(1/rho, 0, rho*log(lambda), -rho*lambda^rho)
    else if (dist == "gompertz")    
      D <- c(0, gamma, 1/lambda, 0)
    else if (dist == "lognormal")   
      D <- c(0, exp(-mu), -sigma, 0)
    else if (dist == "loglogistic") 
      D <- c(alpha/kappa, -kappa*exp(alpha/kappa), 1/kappa, 0)
    D <- matrix(D,2)
    
    V <- D %*% VAR %*% t(D)
    var <- c(diag(V), diag(coxMod$var)[1:(dim(coxMod$var)[1]-2)])
    # ............................................................maybe to eliminate
  }
  else {
    var <- diag(solve(res$hessian))
    if (var[1] > 0) {
      if (frailty %in% c("gamma","ingau"))
        se.theta <- sqrt(var[1] * theta^2)
      else if (frailty == "possta")
        se.theta <- sqrt(var[1] * (theta*log(theta))^2)
    } else {
      warning(paste("Negative estimated variance for parameter theta!\n",
                    "Maybe the true value of theta is exactly 0,",
                    "so that the Normal approximation does not hold."))
      se.theta <- NA
    }
  }

  # Possible reparameterizations
  if (dist=="exponential")
    SE <- c(
      se.lambda = sqrt(var[nFpar+1] * lambda^2)
    )
  else if (dist=="weibull")
    SE <- c(
      se.rho = sqrt(var[nFpar+1] * rho^2),
      se.lambda = sqrt(var[nFpar+1] * lambda^2) 
    )
  else if (dist=="gompertz")
    SE <- c(
      se.gamma = sqrt(var[nFpar+1] * gamma^2), 
      se.lambda = sqrt(var[nFpar+1] * lambda^2) 
    )
  else if (dist=="lognormal")
    SE <- c(
      se.mu = sqrt(var[nFpar+1]),
      se.sigma = sqrt(var[nFpar+2] * sigma^2)
    )
  else if (dist=="loglogistic")
    SE <- c(
      se.alpha = sqrt(var[nFpar+1]),
      se.kappa = sqrt(var[nFpar+2] * kappa^2)
    )

  se.beta <- sqrt(var[-(1:(nFpar+nBpar))])
  SE <- c(SE, se.beta=se.beta)
    
  
  #----- Output ---------------------------------------------------------------#
  res <- cbind(ESTIMATE, SE,
               "p-val"=c(rep(NA, nBpar), 
                         2*pt(-abs(beta/se.beta), 
                              nrow(data)-1-length(beta)+nBpar)))
  if (frailty%in%c("gamma","ingau"))
    res <- rbind(res, theta=c(theta, se.theta, NA))
  if (frailty%in%c("possta")) 
    res <- rbind(res, theta=c(theta, se.theta, NA))
  
  class(res) <- c("parfm", class(res))
  attributes(res)$loglik  <- -Mloglikelihood(p=pars, obs=obsdata, 
                                             dist=dist, frailty=frailty)
  attributes(res)$dist    <- dist
  attributes(res)$frailty <- frailty
  attributes(res)$extime <- extime
  
  cat("\nExecution time:", extime, "second(s) \n")
  return(res)
}

