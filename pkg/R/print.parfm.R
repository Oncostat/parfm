################################################################################
#  Print method for class 'parfm'                                              #
################################################################################
#                                                                              #
#  This function prints the objects of class 'parfm'                           #
#                                                                              #
#  Its parameters are                                                          #
#   - x         : the fitted model, object of class 'parfm'                    #
#   - digits    : number of significant digits                                 #
#   - na.prints : character string indicating NA values in printed output      #
#                                                                              #
#                                                                              #
#                                                                              #
#  The function returns                                                        #
#   - a header like                                                            #
#                                                                              #
#       Frailty distribution: Positive Stable                                  #
#       Basline hazard distribution: Gompertz                                  #
#       Loglikelihood: -357.113                                                #
#                                                                              #
#   - estimated values in a table like                                         #
#                                                                              #
#              ESTIMATE SE     p-val                                           #
#       gamma   0.000    0.000                                                 #
#       lambda  0.035   13.329                                                 #
#       sex    -0.951    0.348 0.008 **                                        #
#       age     0.004    0.011 0.692                                           #
#       theta   0.888    0.084                                                 #
#       ---                                                                    #
#       Signif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1          #
#                                                                              #
#                                                                              #
#                                                                              #
#   Date: December, 19, 2012                                                   #
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

print.parfm <- function(x,
                        digits=3,
                        na.print="") {
  if (!is.null(x)){

    # Which frailty distribution, pretty expression
    frailty <- list(gamma  = "Gamma",
                    possta = "Positive Stable",
                    ingau  = "Inverse Gaussian")[paste(attributes(x)$frailty)]
    
    # Kendall's Tau
    tau <- eval(parse(text=paste("fr.", attributes(x)$frailty, sep="")))(
                theta=x["theta", "ESTIMATE"], what="tau")
    
    # Which baseline hazard, pretty expression
    baseline <- paste(toupper(substr(attributes(x)$dist, 1, 1)), 
                     substr(attributes(x)$dist, 2, 100), 
                     sep="")

    # Loglikelihood value
    loglikelihood <-round(attributes(x)$loglik, digits)
    
    x <- as.data.frame(x)

    # Significance of regression parameters with symbols
    signif <-unlist(lapply(x$"p-val", function(x) { if (!is.na(x)){
      if (x<.001) 4  else
        if (x<.01) 3  else
          if (x<.05) 2 else
            if (x<.1) 1 else 0  } else 0 }
    ))
    signif <- factor(signif, levels=0:4, labels=c("",".  ","*  ","** ","***"))

    # Object to printed out
    toprint <- cbind(round(x, digits), signif)
    names(toprint)[length(names(toprint))] = ""
    rownames(toprint) <- gsub("beta.","", rownames(toprint))
    if (frailty == "Positive Stable") {
      toprint["theta", "ESTIMATE"] <- 1 - toprint["theta", "ESTIMATE"]
      rownames(toprint)[rownames(toprint)=="theta"] <- "nu"
    }

    # Output
    cat(paste("\nFrailty distribution:", 
              frailty,
              "\nBasline hazard distribution:",
              baseline,
              "\nLoglikelihood:", 
              loglikelihood,
              "\n\n"))
    print(as.matrix(toprint), na.print=na.print, quote=FALSE)
    cat("---\nSignif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n")
    cat(paste("\nKendall's Tau:", round(tau, digits), "\n"))
  } 
}

