rct_data_raw<-readRDS(file="M:\\Projects\\2018\\Project.RCTSubGroup\\Output\\1.StatMed\\R2\\Code&DataForReview\\macro_data.RDS")

n<-dim(rct_data_raw)[1]

time<-1.1-rexp(n,10)
time[which(time>1)]<-1
time[which(time<0.5)]<-0.5
rct_data_raw[,'time']<-time

rct_data_raw[,'tte']<-NA

for(i in 1:n)
{
  message(i)

  n_exac<-rct_data_raw[i,'outcome']

  if(n_exac>0)
  {
    #browser()

    fu<-rct_data_raw[i,'time']

    while(TRUE)
    {
      exac_times<-rexp(n_exac,1)
      tf<-sum(exac_times)
      if(tf<fu) break
    }

    rct_data_raw[i,'tte']<-exac_times[1]
  }
}

rct_data_raw[,'n_exac']<-rct_data_raw[,'outcome']
rct_data_raw[,'sgrq']<-rct_data_raw[,'sgrq100']

rct_data<-rct_data_raw[,c('tx','female','age','prev_hosp','prev_ster','fev1','sgrq','time','tte','n_exac')]


save(rct_data,file=paste0(getwd(),"/data/rct_data.RData"))
