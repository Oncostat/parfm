################################################################################
#  Plots the prediction of frailties                                           #
################################################################################
#                                                                              #
#  Computes the prediction of the fraities as                                  #
#                                                                              #
#  Its parameters are                                                          #
#   - x    : the prediction, object of class 'predict.parfm'                   #
#   - sort : how the values must be sorted, either                             #
#            'i' for increasing                                                #
#            'd' for decreasing                                                #
#            or any other value for keeping the current order                  #
#                                                                              #
#   Date: February 02, 2012                                                    #
#   Last modification on: February 07, 2012                                    #
################################################################################

plot.predict.parfm <- function(x, sort="i", 
                               main=NULL,
                               sub=NULL) {
  library(graphics)
  ylab = attr(x, "clustname")
  if (is.null(main)) {
    frailty <- attr(x, "frailty")
    dist <- attr(x, "dist")
    main <- paste(toupper(substr(frailty, 1, 1)), substr(frailty, 2, 100), 
                  " frailty model\nwith ", 
                  toupper(substr(dist, 1, 1)), substr(dist, 2, 100),
                  " baseline", sep="", collapse="")
  }
  if (sort == "i")
    x <- sort(x, decreasing=FALSE)
  else if (sort == "d")
    x <- sort(x, decreasing=TRUE)
  dotchart(as.numeric(x),
           xlab="Predicted frailty value", 
           ylab=ylab,
           main=main,
           sub=sub)
  axis(side=2, at=1:length(x), label=names(x), las=1)
  abline(v=1)  
}