tau <- function(x) {
  if (is.null(x))
    stop("The attribute 'x' is null!")
  else if (!"parfm" %in% class(x))
    stop("The object 'x' is not of class 'parfm'!")
  
  if ((attributes(x)$frailty %in% c("gamma", "ingau", "possta"))
      && (attributes(x)$shared)) {
    tau <- eval(parse(text = 
      paste("fr.", attributes(x)$frailty, sep="")))
    
    if (attributes(x)$frailty %in% c("gamma", "ingau"))
      tau <- tau(theta=x["theta", "ESTIMATE"], what="tau")
    else if (attributes(x)$frailty == "possta")
      tau <- tau(nu=x["nu", "ESTIMATE"], what="tau")
  }
  else tau <- NULL
  
  return(tau)
}

