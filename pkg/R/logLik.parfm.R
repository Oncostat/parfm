################################################################################
#  logLik method for class 'parfm'                                             #
################################################################################
#                                                                              #
#  logLik.parfm implemets the logLik function the objects of class 'parfm'     #
#                                                                              #
#  It is necessary in oder to compute AIC and BIC values via the standard      #
#    functions AIC() and BIC()                                                 #
#                                                                              #
#                                                                              #
#   Date: December 21, 2011                                                    #
#                                                                              #
################################################################################

logLik.parfm <- function(x) {
  lL <- attributes(x)$loglik
  attributes(lL)$df <- dim(x)[1]
  attributes(lL)$nobs <- attributes(x)$nobs
  return(lL)
}
