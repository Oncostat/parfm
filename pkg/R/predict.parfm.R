################################################################################
#  Prediction of frailties                                                     #
################################################################################
#                                                                              #
#  Computes the prediction of the fraities as                                  #
#                                                                              #
#  Its only parameter is                                                       #
#   - model  : the fitted model, object of class 'parfm'                       #
#                                                                              #
#   Date: February 02, 2012                                                    #
#   Last modification on: February 03, 2012                                    #
################################################################################

predict.parfm <- function(model) {
# Frailty distribution
  if (attributes(model)$frailty == "none")
    stop("The model 'model' is is a simple Cox modelm with no frailties!")
  frailty <- eval(parse(text=paste("fr", attributes(model)$frailty, sep=".")))
  frPar  <- c(rownames(model)[1],
              model[1, 1])
  
  # Baseline hazard
  dist <- eval(parse(text=attributes(model)$dist))
  
# Data needed for the derivatives of the  Laplace transform 
  cumhaz <- attributes(model)$cumhaz
  di <- attributes(model)$di
  clusters <- names(attr(model, "di"))

  res <- sapply(clusters, FUN=function(h) {
    exp(diff(sapply(
      paste("frailty(k=attributes(model)$di[", h, "]+", 0:1,
                    ", s=cumhaz[", h, "], ",
            paste(frPar, collapse="="), ", ",
            ifelse(attributes(model)$frailty == "possta", 
                   paste("Omega=Omega(D=max(di)+1, ",
                         "correct=", attr(model, 'correct'), 
                         ", nu=", frPar[2] ,")",
                         ", correct=", attr(model, 'correct'), ", ",
                         sep=""),
                   ""),
            "what='logLT'",
            ")", sep=""),
      function(x) eval(parse(text=x)),
   USE.NAMES=FALSE)))
  }, USE.NAMES=FALSE)
  
  class(res) <- "predict.parfm"
  attr(res, "clustname") <-attr(model, "clustname")
  return(res)
}
