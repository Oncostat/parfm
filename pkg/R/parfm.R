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
#   - inip     : the initial values of parameters                              #
#   - iniFpar  : the initial value of the frailty theta                        #
#   - dist     : the name of the baseline hazard                               #
#   - frailty  : the name of the frailty distribution                          #
#   - method   : the optimization method (See optim())                         #
#   - maxit    : the maximum number of iteration (See optim())                 #
#   - showtime : show the execution time?                                      #
#                                                                              #
#                                                                              #
#   Date: December 21, 2011                                                    #
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
                  iniFpar =NULL,
                  dist="weibull",
                  frailty="none",
                  method="BFGS",
                  maxit=5000,
                  showtime=TRUE){
  if (!(dist %in% c("exponential", "weibull", "gompertz", 
                    "loglogistic", "lognormal")))
    stop("Invalid baseline hazard name!")
  
  if (!(frailty %in% c(#"none", 
                       "gamma", "ingau", "possta")))
    stop("Invalid frailty distribution name!")
  

  #----- Data in a Mloglikelihood form ----------------------------------------#  
  
  obsdata <- NULL
  # times
  if (length(formula[[2]])==3) { #     without left censoring
    obsdata$time  <- eval(parse(text=paste("data$", 
                                           formula[[2]][[2]], sep="")))
    obsdata$event <- eval(parse(text=paste("data$", 
                                           formula[[2]][[3]], sep="")))
  } else if (length(formula[[2]])==4) { # with left censoring
    obsdata$trunc <- eval(parse(text=paste("data$", 
                                           formula[[2]][[2]], sep="")))
    obsdata$time  <- eval(parse(text=paste("data$", 
                                           formula[[2]][[3]], sep="")))
    obsdata$event <- eval(parse(text=paste("data$", 
                                           formula[[2]][[4]], sep="")))
  }
  # covariates
  obsdata$x <- as.data.frame(model.matrix(formula, data=data))
  # clusters
  if(is.null(cluster)){
    if (frailty != "none")
      stop(paste("No cluster variable is specified,",
                 "while a frailty distribution (",
                 frailty, ") is.", sep=""))
  }
  else {
    obsdata$cluster <- eval(parse(text=paste("data$", cluster, sep="")))
    # Number of clusters
    obsdata$ncl <- length(levels(as.factor(obsdata$cluster)))
    # Number of events per cluster
    obsdata$di  <- aggregate(obsdata$event, 
                             by=list(obsdata$cluster), FUN=sum)[, 2]
    }
  
  
  #----- Dimensions -------------------------maybe to move into other func.'s--#
  
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
    
  # nRpar: number of regression parameters
    nRpar <- ncol(obsdata$x)-1
 
 
  #----- Initial parameters ---------------------------------------------------#
  
  if (!is.null(inip)) {
    # If there are initial parameters, check the right dimension
    # and reparametrise into the whole Real line
    
    if (length(inip) != nBpar + nRpar)
      stop( paste("Number of initial parameters 'inip' must be",
                  nBpar + nRpar))
    p.init <- inip
    if (dist %in% c("exponential","weibull","gompertz"))             # 1st par
      p.init[1] <- log(p.init[1]) # lambda, rho, gamma
    if (dist %in% c("weibull","gompertz","lognormal","loglogistic")) # 2nd par
      p.init[2] <- log(p.init[2]) # lambda, lambda, sigma, kappa
#     # the remaining are betas
#     p.init <- inip[(nBpar+1):length(inip)]
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
    coxMod <- phreg(formula, data=data, dist=d, shape=shape, center=FALSE,
                    control=list(maxiter=maxit))
    
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
    if (nRpar > 0)
      p.init <- c(p.init, 
                  coxMod$coefficients[1:nRpar] )
  }
        
  # --- Frailty parameters inizialization --- #
  if (frailty=="none")
    pars <- NULL
  else if (frailty %in% c("gamma","ingau")) {
    if (is.null(iniFpar))
      iniFpar <- 1
    else if (iniFpar <= 0)
      stop("Initial value of frailty variance 'iniFpar' must be positive!")
    pars <- log(iniFpar)
  }
  else if (frailty == "possta") {
    if (is.null(iniFpar)) 
      iniFpar <- .5
    else if (iniFpar <= 0 || iniFpar >= 1)
      stop("Initial value of frailty nu 'iniFpar' must be in (0,1)!")
    pars <- log(-log(iniFpar))
  }


  ##############################################################################
  #------ Minus log-likelihood minimization (begin) ---------------------------#
  ##############################################################################
  pars <-c(pars, p.init)
  res <- NULL
  if ((frailty=="none") && is.null(inip))
    extime <- system.time({
      res <- list(par=pars) 
    })[1]
  else
    extime <- system.time({
      res <- optim(pars, Mloglikelihood, method=method,
                                        obs=obsdata, dist=dist, frailty=frailty, 
                                        hessian=TRUE, control=c(maxit=maxit))
    })[1]
  ##############################################################################
  #------ Minus log-likelihood minimization (end) -----------------------------#
  ##############################################################################
  if (res$convergence > 0)
    warning("Optimization algorithm did not converge!")
  lL <- -res$value
  it <- res$counts[1]
  
  
  #----- Recover the frailty paramters estimates -----------------------------#
  if (frailty %in% c("gamma","ingau"))
    theta <- exp(res$par[1])
  else
    theta <- NULL
  if (frailty == "possta")
    nu <- exp(-exp(res$par[1]))
  else
    nu <- NULL
  
  #----- Recover the baseline paramters estimates ----------------------------#
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
  
  #----- Recover the regression coefficients estimates ------------------------#
  if (nRpar == 0) 
    beta <- NULL
  else {
    beta     <- res$par[-(1:(nFpar+nBpar))]
    names(beta) <- paste("beta", names(obsdata$x), sep=".")[-1]
  }
  
  # All together #################################-ESTIMATE-###
  ESTIMATE <- c(theta=theta,
                nu=nu,
                ESTIMATE, 
                beta=beta)
  ################################################-ESTIMATE-###


  #----- Obtain SE of paramters estimates -------------------------------------#
  if ((frailty == "none") && is.null(inip)) {
    # reeeeeeeeeeeeeaaaaally to carefully check and re-check
    # maybe to eliminate...................................................#?
    VAR <- coxMod$var[c("log(shape)","log(scale)"),                        #?
                      c("log(shape)","log(scale)")]                        #?
    if (dist=="exponential")                                               #?
      D <- c(1, 0, log(lambda), -lambda)                                   #?
    else if (dist == "weibull")                                            #?
      D <- c(1/rho, 0, rho*log(lambda), -rho*lambda^rho)                   #?
    else if (dist == "gompertz")                                           #?
      D <- c(0, gamma, 1/lambda, 0)                                        #?
    else if (dist == "lognormal")                                          #?
      D <- c(0, exp(-mu), -sigma, 0)                                       #?
    else if (dist == "loglogistic")                                        #?
      D <- c(alpha/kappa, -kappa*exp(alpha/kappa), 1/kappa, 0)             #?
    D <- matrix(D,2)                                                       #?
                                                                           #?
    V <- D %*% VAR %*% t(D)                                                #?
    var <- c(diag(V), diag(coxMod$var)[1:(dim(coxMod$var)[1]-2)])          #?
    # ....................................................maybe to eliminate?
  }
  else {
    var <- try(diag(solve(res$hessian)), silent=TRUE)
    if (class(var) == "try-error") 
      var <- rep(NA, ncol(res$hessian))
    se.theta <- NULL
    se.nu <- NULL
 
    if (!is.na(min(var)) && min(var[1:nFpar]) > 0) {
      if (frailty %in% c("gamma","ingau"))
        se.theta <- sqrt(var[1] * theta^2)
      else if (frailty == "possta")
        se.nu <- sqrt(var[1] * (nu*log(nu))^2)
    } else {
      warning(paste("Negative estimated variance for the frailty parameter!\n",
                    " Maybe the conditons for the Normal approximation",
                    " are not satisfied.\n",
                    " Please, try other initial values 'iniFpar'\n",
                    " or other optimization methods 'method'.\n"))
      se.theta <- NA
    }
  }

  # Reparameterization concerning baseline parameters
  if (dist=="exponential")
    SE <- c(
      se.lambda = sqrt(var[nFpar + 1] * lambda^2)
    )
  else if (dist=="weibull")
    SE <- c(
      se.rho = sqrt(var[nFpar + 1] * rho^2),
      se.lambda = sqrt(var[nFpar + 2] * lambda^2) 
    )
  else if (dist=="gompertz")
    SE <- c(
      se.gamma = sqrt(var[nFpar + 1] * gamma^2), 
      se.lambda = sqrt(var[nFpar + 2] * lambda^2) 
    )
  else if (dist=="lognormal")
    SE <- c(
      se.mu = sqrt(var[nFpar + 1]),
      se.sigma = sqrt(var[nFpar + 2] * sigma^2)
    )
  else if (dist=="loglogistic")
    SE <- c(
      se.alpha = sqrt(var[nFpar + 1]),
      se.kappa = sqrt(var[nFpar + 2] * kappa^2)
    )

  # SE of regression coefficients
  se.beta <- sqrt(var[-(1:(nFpar+nBpar))])

  # All together ########################################-SE-###
  SE <- c(se.theta=se.theta,
          se.nu=se.nu,
          SE, 
          se.beta=se.beta)
  #######################################################-SE-###
          
  
  #----- Output ---------------------------------------------------------------#
  resmodel <- cbind(ESTIMATE, SE,
                    "p-val"=c(rep(NA, nFpar+nBpar), 
                              2 * pt(-abs(beta / se.beta), 
                                     nrow(data) - length(ESTIMATE))))
  class(resmodel) <- c("parfm", class(resmodel))
  attributes(resmodel)$loglik  <- lL                                                  
  attributes(resmodel)$dist    <- dist
  attributes(resmodel)$frailty <- frailty
  attributes(resmodel)$extime  <- extime
  attributes(resmodel)$nobs    <- nrow(data)
  attributes(resmodel)$convergence <- res$convergence
  attributes(resmodel)$it     <- it
  
  if (showtime)
    cat("\nExecution time:", extime, "second(s) \n")
  return(resmodel)
}

