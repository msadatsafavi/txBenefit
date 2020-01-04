library(txBenefit)

data("rct_data")

rct_data$ln_time<-log(rct_data$time)

#rct_data[,'tx']<- 1-rct_data[,'tx']

reg<-glm(formula = n_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, family = poisson(link="log"), offset=ln_time)
res.Poisson<-Cb.Poisson(reg,tx_var = "tx", semi_parametric = T)

plot(res.Poisson)



###Logistic
data("rct_data")
rct_data[,'b_exac']<-rct_data[,'tte']<0.5
rct_data[which(is.na(rct_data[,'b_exac'])),'b_exac']<-FALSE
reg.logostic<-glm(formula = b_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, family = binomial(link="logit"))
res.logistic<-Cb.logistic(reg.logostic,tx_var = "tx", semi_parametric = T)






###cox
library(survival)
data("rct_data")
event<-(!is.na(rct_data[,'tte']))*1
ids<-which(event==0)
rct_data[ids,'tte']<-rct_data[ids,'time']
rct_data['event']<-event

reg.coxph<-coxph(Surv(time=tte,event=event) ~ tx + tx:female + tx:age + sgrq + prev_hosp + prev_ster + fev1, data=rct_data, model=TRUE)

res.coxph<-Cb.coxph(reg.coxph,tx_var = "tx",semi_parametric = T)
