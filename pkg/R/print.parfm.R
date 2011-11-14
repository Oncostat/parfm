print.parfm <-
function(x, digits=3, na.print="", print=FALSE){
  signif <- NULL
  if (!is.null(x)){
    cat(paste("\nFrailty distribution:", attributes(x)$frailty,
      "\nBasline hazard distribution:", attributes(x)$dist,
      "\nLoglikelihood:", round(attributes(x)$loglik, digits),"\n\n") )
    x <- as.data.frame(x)
    signif <-unlist(lapply(x$"p-val", function(x) { if (!is.na(x)){
      if (x<.001) 4  else
        if (x<.01) 3  else
          if (x<.05) 2 else
            if (x<.1) 1 else 0  } else 0 }
    ))
    signif <- factor(signif, levels=0:4, labels=c("",".  ","*  ","** ","***"))
    toprint <- cbind(round(x, digits), signif)
    names(toprint)[length(names(toprint))] = ""

    rownames(toprint) <- gsub("beta.","", rownames(toprint))

    print(as.matrix(toprint), na.print=na.print, quote=FALSE)
    cat("---\nSignif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n")
  } 
}

