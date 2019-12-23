library(txBenefit)

data("rct_data")

rct_data$ln_time<-log(rct_data$time)

#rct_data[,'tx']<- 1-rct_data[,'tx']

reg<-glm(formula = n_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, family = poisson(link="log"), offset=ln_time)
res<-Cb.Poisson(reg,tx_var = "tx", semi_parametric = T)

plot(res)



###Logistic
rct_data[,'b_exac']<-rct_data[,'tte']<0.5
rct_data[which(is.na(rct_data[,'b_exac'])),'b_exac']<-FALSE
reg<-glm(formula = b_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, family = binomial(link="logit"))
res<-Cb.logistic(reg,tx_var = "tx", semi_parametric = T)




###cox
library(survival)
event<-(!is.na(rct_data[,'tte']))*1
ids<-which(event==0)
rct_data[ids,'tte']<-rct_data[ids,'time']
rct_data['event']<-event

reg<-coxph(Surv(time=tte,event=event) ~ tx + sgrq + prev_hosp + prev_ster + fev1, data=rct_data, model=TRUE)
