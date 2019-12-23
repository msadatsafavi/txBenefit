#Includes all the files for Cb calculations


Cb_output.template<-list(Cb=NA,e_b=NA,e_max_b1b2=NA,p=NA,q=NA)

class(Cb_output.template)<-"Cb_output"

print.Cb_output<-function(x)
{
  print(paste0("Cb=",x$Cb," - ","e_b=",x$e_b," - ","e_max_b1b2=",x$e_max_b1b2))
}

plot.Cb_output<-function(x)
{
  plot(x$p,x$q,type='l',xlab="p",ylab="q")
}




e_max_b1_b2<-function(B, dumb=FALSE, ordered=FALSE)
{
  out<-0

  n<-length(B)

  if(dumb)
  {
    N<-n*n

    for(i in 1:(n-1))
      for(j in (i+1):n)
      {
        out<-out+2*max(B[i],B[j])
      }

    out<-(out+sum(B))

    return(out/N)
  }
  else
  {
    if(!ordered)  B<-B[order(B,decreasing = TRUE)]
    return((2*sum(cumsum(B))-sum(B))/(n^2))
  }
}








Cb.simple<-function(B)
{
  a<-mean(B)

  if(a<0)
  {
    B<--B
    a<--a
  }

  o<-order(B,decreasing = T)
  B<-B[o]
  n<-length(B)

  b<-e_max_b1_b2(B,ordered = T)

  out<-Cb_output.template

  out$Cb<-1-a/b
  out$e_b<-a
  out$e_max_b1b2<-b
  out$p<-(1:n)/n
  out$q<-cumsum(B)
  return(out)
}








Cb.logistic<-function(reg_object,tx_var,semi_parametric=FALSE)
{
  if(!inherits(reg_object,"glm")) stop("reg_object should be an object of class glm.")
  if(is.null(tx_var)) stop("Treatment variable label (tx_var) is not speficied.")

  out<-Cb_output.template

  data<-reg_object$model

  n<-dim(data)[1]

  newdata0<-data
  newdata0[,tx_var]<-0
  y0<-predict.glm(reg_object,newdata = newdata0, type = "response")

  newdata1<-data
  newdata1[,tx_var]<-1
  y1<-predict.glm(reg_object,newdata = newdata1, type="response")

  if(semi_parametric)
  {
    outcome_var<-as.character(reg_object$call$formula[[2]])

    B<-y0-y1

    if(mean(B)<0)
    {
      B<- -B
      data[,tx_var]<- 1-data[,tx_var]
    }

    o<-order(B,runif(n),decreasing=TRUE)

    id0<-which(data[,tx_var]==0)
    data[,'y0__']<-0
    data[,'t0__']<-1
    data[id0,'y0__']<-data[id0,outcome_var]

    id1<-which(data[,tx_var]==1)
    data[,'y1__']<-0
    data[,'t1__']<-1
    data[id1,'y1__']<-data[id1,outcome_var]

    data<-data[o,]
    B<-B[o]

    tmp0<-cumsum(data[,'y0__'])*(1:n)/cumsum(data[,'t0__'])
    tmp1<-cumsum(data[,'y1__'])*(1:n)/cumsum(data[,'t1__'])

    n_nan<-sum(is.nan(tmp0))
    if(n_nan>0)
    {
      tmp0[1:n_nan]<-(1:n_nan)*tmp0[n_nan+1]/n_nan
    }
    else
    {
      n_nan<-sum(is.nan(tmp1))
      if(n_nan>0)
      {
        tmp1[1:n_nan]<-(1:n_nan)*tmp1[n_nan+1]/n_nan
      }
    }

    data[,'q_sp__']<-tmp0-tmp1

    out$e_b<-(sum(data[,'y0__'])*n/sum(data[,'t0__'])-sum(data[,'y1__'])*n/sum(data[,'t1__']))/n
    out$e_max_b1b2<-(2*sum(data[,'q_sp__']))/n/n-out$e_b/n
    out$Cb<-1-out$e_b/out$e_max_b1b2
    out$p<-(1:n)/n
    out$q<-data[,'q_sp__']

    return(out)

  }
  else
  {
    return(Cb.simple(y0-y1))
  }
}








Cb.Poisson<-function(reg_object,tx_var,semi_parametric=FALSE)
{
  if(!inherits(reg_object,"glm")) stop("reg_object should be an object of class glm.")
  if(is.null(tx_var)) stop("Treatment variable label (tx_var) is not speficied.")

  out<-Cb_output.template

  data<-reg_object$model

  n<-dim(data)[1]

  offset_var<-as.character(reg_object$call$offset)
  data[,offset_var]<-data[,"(offset)"]

  newdata0<-data
  newdata0[,tx_var]<-0
  newdata0[,offset_var]<-0
  y0<-predict.glm(reg_object,newdata = newdata0, type = "response")

  newdata1<-data
  newdata1[,tx_var]<-1
  newdata1[,offset_var]<-0
  y1<-predict.glm(reg_object,newdata = newdata1, type="response")

  if(semi_parametric)
  {
    outcome_var<-as.character(reg_object$call$formula[[2]])

    B<-y0-y1

    if(mean(B)<0)
    {
      B<- -B
      data[,tx_var]<- 1-data[,tx_var]
    }

    o<-order(B,runif(n),decreasing=TRUE)

    id0<-which(data[,tx_var]==0)
    data[,'y0__']<-0
    data[,'t0__']<-0
    data[id0,'y0__']<-data[id0,outcome_var]
    data[id0,'t0__']<-exp(data[id0,offset_var])

    id1<-which(data[,tx_var]==1)
    data[,'y1__']<-0
    data[,'t1__']<-0
    data[id1,'y1__']<-data[id1,outcome_var]
    data[id1,'t1__']<-exp(data[id1,offset_var])

    data<-data[o,]
    B<-B[o]

    tmp0<-cumsum(data[,'y0__'])*(1:n)/cumsum(data[,'t0__'])
    tmp1<-cumsum(data[,'y1__'])*(1:n)/cumsum(data[,'t1__'])

    n_nan<-sum(is.nan(tmp0))
    if(n_nan>0)
    {
      tmp0[1:n_nan]<-(1:n_nan)*tmp0[n_nan+1]/n_nan
    }
    else
    {
      n_nan<-sum(is.nan(tmp1))
      if(n_nan>0)
      {
        tmp1[1:n_nan]<-(1:n_nan)*tmp1[n_nan+1]/n_nan
      }
    }

    data[,'q_sp__']<-tmp0-tmp1

    out$e_b<-(sum(data[,'y0__'])*n/sum(data[,'t0__'])-sum(data[,'y1__'])*n/sum(data[,'t1__']))/n
    out$e_max_b1b2<-(2*sum(data[,'q_sp__']))/n/n-out$e_b/n
    out$Cb<-1-out$e_b/out$e_max_b1b2
    out$p<-(1:n)/n
    out$q<-data[,'q_sp__']

    return(out)

  }
  else
  {
    return(Cb.simple(y0-y1))
  }
}









Cb.coxph<-function(reg_object,tx_var,semi_parametric=FALSE)
{
  if(!inherits(reg_object,"coxph")) stop("reg_object should be an object of class coxph.")
  if(is.null(tx_var)) stop("Treatment variable label (tx_var) is not speficied.")
  if(!exists(reg_object$model)) stop("No model data available in the regression object. Run coxph with model=TRUE argument.")

  out<-Cb_output.template

  data<-reg_object$model

  n<-dim(data)[1]

  newdata0<-data
  newdata0[,tx_var]<-0
  y0<-predict.glm(reg_object,newdata = newdata0, type = "response")

  newdata1<-data
  newdata1[,tx_var]<-1
  newdata1[,offset_var]<-0
  y1<-predict.glm(reg_object,newdata = newdata1, type="response")

  if(semi_parametric)
  {
    outcome_var<-as.character(reg_object$call$formula[[2]])

    B<-y0-y1

    if(mean(B)<0)
    {
      B<- -B
      data[,tx_var]<- 1-data[,tx_var]
    }

    o<-order(B,runif(n),decreasing=TRUE)

    id0<-which(data[,tx_var]==0)
    data[,'y0__']<-0
    data[,'t0__']<-0
    data[id0,'y0__']<-data[id0,outcome_var]
    data[id0,'t0__']<-exp(data[id0,offset_var])

    id1<-which(data[,tx_var]==1)
    data[,'y1__']<-0
    data[,'t1__']<-0
    data[id1,'y1__']<-data[id1,outcome_var]
    data[id1,'t1__']<-exp(data[id1,offset_var])

    data<-data[o,]
    B<-B[o]

    tmp0<-cumsum(data[,'y0__'])*(1:n)/cumsum(data[,'t0__'])
    tmp1<-cumsum(data[,'y1__'])*(1:n)/cumsum(data[,'t1__'])

    n_nan<-sum(is.nan(tmp0))
    if(n_nan>0)
    {
      tmp0[1:n_nan]<-(1:n_nan)*tmp0[n_nan+1]/n_nan
    }
    else
    {
      n_nan<-sum(is.nan(tmp1))
      if(n_nan>0)
      {
        tmp1[1:n_nan]<-(1:n_nan)*tmp1[n_nan+1]/n_nan
      }
    }

    data[,'q_sp__']<-tmp0-tmp1

    out$e_b<-(sum(data[,'y0__'])*n/sum(data[,'t0__'])-sum(data[,'y1__'])*n/sum(data[,'t1__']))/n
    out$e_max_b1b2<-(2*sum(data[,'q_sp__']))/n/n-out$e_b/n
    out$Cb<-1-out$e_b/out$e_max_b1b2
    out$p<-(1:n)/n
    out$q<-data[,'q_sp__']

    return(out)

  }
  else
  {
    return(Cb.simple(y0-y1))
  }
}

