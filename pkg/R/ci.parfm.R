################################################################################
#  Confidence intervals of regression parameters' estimates                    #
################################################################################
#                                                                              #
#  Computes confidence intervals of regression parameters' estimates           #
#  for objects of class 'parfm'                                                #
#                                                                              #
#  Its parameters are                                                          #
#   - x         : the fitted model, object of class 'parfm'                    #
#   - dist      : the distribution to be used for the estimator                #
#   - level     : the coverage probability of the interval                     #
#   - digits    : number of significant digits                                 #
#                                                                              #
#                                                                              #
#   Date: January, 16, 2012                                                    #
#   Last modification on: January, 16, 2012                                    #
################################################################################

ci.parfm <- function(x, 
                     dist  ="norm", 
                     level =.05,
                     digits=3) {
  beta <- which (!is.na(x[, "p-val"]))
  
  if (dist == "norm")
    q <- qnorm(level/2)
  else if (dist == "t")
    q <- qt(level/2, df=attributes(x)$nobs-nrow(x))
  
  res <- exp(x[beta, "ESTIMATE"] + outer(x[beta, "SE"], c(1, -1) * q))
  
  colnames(res) <- c("low", "up")
  
  return(round(res, digits))
}
  