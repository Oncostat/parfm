################################################################################
#  Computation of AIC and BIC of many models of class 'parfm'                  #
################################################################################
#                                                                              #
#  The function 'select.parfm' computes the AIC and BIC values                 #
#    of parametric frailty models with                                         #
#    different baseline hazards and                                            #
#    different frailty distributions                                           #
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
#   - dist     : the vector of the names of the baseline hazards               #
#   - frailty  : the vector of the names of the frailty distribution           #
#   - method   : the optimization method (See optim())                         #
#   - maxit    : the maximum number of iterations (See optim())                #
#   - showtime : show the execution time of each model? (See parfm())          #
#                                                                              #
#                                                                              #
#  The function returns a list with elements                                   #
#   - AIC : a table with AIC values of the required models                     #
#           with one line   per baseline hazard distribution and               #
#           with one column per frailty         distribution                   #
#   - BIC : a table with BIC values of the required models                     #
#           with one line   per baseline hazard distribution and               #
#           with one column per frailty         distribution                   #
#                                                                              #
#                                                                              #
#   Date: December 21, 2011                                                    #
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

select.parfm <- function(formula,
                         cluster,
                         data,
                         dist=c("exponential",
                                "weibull",
                                "gompertz",
                                "loglogistic",
                                "lognormal"),
                         frailty=c(#"none",
                                   "gamma",
                                   "ingau",
                                   "possta"),
                         method="BFGS",
                         maxit=5000){
  
  res <- list(AIC=NULL, BIC=NULL)
  res$AIC <- res$BIC <- matrix(NA, length(dist), length(frailty),
                               dimnames=list(dist, frailty))
  for (d in dist) {
    for (f in frailty) {
      cat(".")
      model <- try(parfm(formula=formula, 
                         cluster=cluster,
                         data=data,
                         dist=d,
                         frailty=f,
                         method=method,
                         maxit=maxit,
                         showtime=FALSE),
                   silent=TRUE)
      if (!("try-error" %in% class(model))){
        res$AIC[d, f] <- AIC(model)
        res$BIC[d, f] <- BIC(model)
      }
    }
  }
  cat("\n")
  class(res) <- "select.parfm"
  return(res)
}

