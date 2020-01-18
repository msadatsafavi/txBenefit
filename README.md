
<!-- README.md is generated from README.Rmd. Please edit that file -->
txBenefit
=========

<!-- badges: start -->
<!-- badges: end -->
This tutotial provides background information and stepwise tutorial for Cb calculations.

### What is Cb?

Consider a risk model that predicts the rate or risk of an outcome (e.g., 5-year mortality due to breast cancer). The risk model estimates the risk / rate of the event given an individual's characteristics. The discriminatory performance of such a model is often communicated in terms of C-statistic (or area under the curve of the receiver operating characteristic curve).

Sometimes our interest is in using covariates to predict the benefit of treatment (rather than the risk). Cb is a summary metric that quantifies to what extend a model predicts treatment benefit.

The table below compares and contrasts C and Cb statstics.

<table style="width:100%;">
<colgroup>
<col width="15%" />
<col width="46%" />
<col width="38%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">First Header</th>
<th align="center">C-statistic</th>
<th align="left">Cb</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Application</td>
<td align="center">Models for risk</td>
<td align="left">Models for treatment benefit</td>
</tr>
<tr class="even">
<td align="left">Probabilistic interpretation</td>
<td align="center">Randomly select a pair of individuals, one that experiences the outconme and one that does not. C is the probability that the risk model predicts a higher risk for the individual with event</td>
<td align="left">Randomly select a pair of individuals. Consider the two scenarios: A) give treatment to one at random, B) give treatment to the one with the higher predicted benefit. Cb is the relative loss of efficiency of scenario A compared with scenario B</td>
</tr>
<tr class="odd">
<td align="left">Range</td>
<td align="center">[0.5,1]</td>
<td align="left">[0,1]</td>
</tr>
<tr class="even">
<td align="left">Interpretation</td>
<td align="center">The model with higher C is better</td>
<td align="left">The model with higher Cb is better</td>
</tr>
</tbody>
</table>

Formal definition of Cb
-----------------------

Let b be the benefit of treatment on the decision scale (e.g., the absolute risk reduction with treatment). Often times, this benefit is estimated from a risk model. Let Y be the outcome of interest, X the set of covariates, and A the treatment indicator. A risk model can be used to predict treatment benefit in this circumstance we can develop a model directly predicting treatment benefit:

*b* = *E*(*Y*|*X*, *A* = 1)−*E*(*Y*|*X*, *A* = 0)

Cb is a threshold-free index that describes to what extent covariates X can discriminate among individuals who will differently benefit from treatment, given their covariates.

If B1, B2, and B3 are random draws from the distribution of b (as defined in the above equation), then

*C*<sub>*b*</sub> = 1 − *E*(*B*<sub>1</sub>)/*E*(*m**a**x*(*B*<sub>2</sub>, *B*<sub>3</sub>))

Installation
------------

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("msadatsafavi/txBenefit")
```

How the package works
---------------------

The package provides simple functions for calculating Cb for different regression models.

### Direct calculation of Cb when the vector of benefits are available.

Cb.simple() is for such an estimation method.

In the example below, we simply create vector B of randomly generated numbers.

``` r
library(txBenefit)
B<-runif(100)
res<-Cb.simple(B)
print(res)
#> Cb= 0.2676818 
#> e_b= 0.4596051 
#> e_max_b1b2= 0.627603 
#> Gini= 0.3655267 
#> AUCi= 0.6827634 
#> Data length: 100
```

In effect, this function equals to creating all possible pairs within the vector B, and estimating the maximum within each pair.

### Cb calculations for different regression frameworks

The package comes with functions that help you calculate Cb for different type of regression models. These function accept a fitted regression object and a few extra parameters and calculate Cb.

Let's focus on a more realistic example. The package comes with a simulated randomized clinical trial (RCT) data, named rct\_data.

``` r
data("rct_data")
```

Let's take a look at the first few rows:

|   tx|  female|       age|  prev\_hosp|  prev\_ster|      fev1|       sgrq|       time|        tte|  n\_exac|
|----:|-------:|---------:|-----------:|-----------:|---------:|----------:|----------:|----------:|--------:|
|    1|       0|  60.04992|           0|           1|  1.125416|  0.6208415|  0.7562069|         NA|        0|
|    1|       1|  74.32678|           1|           1|  1.230864|  0.5971572|  0.9685049|         NA|        0|
|    1|       1|  69.02729|           0|           1|  1.892702|  0.2350660|  0.9969646|  0.0738847|        1|
|    1|       0|  62.51775|           0|           1|  1.070905|  0.4851237|  0.9341948|         NA|        0|
|    1|       0|  72.98540|           1|           1|  1.559421|  0.0838917|  1.0000000|         NA|        0|
|    0|       0|  70.31170|           1|           0|  1.140794|  0.5489664|  0.8978731|  0.1335712|        2|
|    1|       0|  63.56974|           0|           1|  1.384113|  0.6934356|  1.0000000|  0.9150555|        1|

This is a hypothetical RCT of two treatments for Chronic Obstructive Pulmonary Disease (COPD). COPD is a chronic disease that comes with episodes of intensified activity, called exacerbations. The benefit of treatment is in reducing the rate of such exacerbations.

The columns are as follows.

<table style="width:83%;">
<colgroup>
<col width="19%" />
<col width="13%" />
<col width="50%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Variable</th>
<th align="center">Type</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">tx</td>
<td align="center">binary</td>
<td align="left">Treatment assignment variable (0: placebo, 1: treatment)</td>
</tr>
<tr class="even">
<td align="left">female</td>
<td align="center">binary</td>
<td align="left">1 for female and 0 for male</td>
</tr>
<tr class="odd">
<td align="left">age</td>
<td align="center">continuous</td>
<td align="left">Age in years at time of randomization</td>
</tr>
<tr class="even">
<td align="left">prev_hosp</td>
<td align="center">binary</td>
<td align="left">History of COPD-related hospitalization in the previous 12 months</td>
</tr>
<tr class="odd">
<td align="left">prev_ster</td>
<td align="center">binary</td>
<td align="left">History of COPD-related hospitalization in the previous 12 months</td>
</tr>
<tr class="even">
<td align="left">fev1</td>
<td align="center">continuous</td>
<td align="left">Forced expiratory volume at one second, a measure of lung capacity</td>
</tr>
<tr class="odd">
<td align="left">sgrq</td>
<td align="center">continuous</td>
<td align="left">St. George Respiratory Questionnaire score</td>
</tr>
<tr class="even">
<td align="left">time</td>
<td align="center">continuous</td>
<td align="left">Total follow-up time in years (maximum 1 year)</td>
</tr>
<tr class="odd">
<td align="left">tte</td>
<td align="center">continuous</td>
<td align="left">Time to first exacerbation in years (NA if no exacerbation)</td>
</tr>
<tr class="even">
<td align="left">n_exac</td>
<td align="center">discrete</td>
<td align="left">Total number of exacerbations during follow-up</td>
</tr>
</tbody>
</table>

#### Logistic regression

Imagine we want to evaluate the predictability of treatment benefit in terms of reducing 6-month exacerbation risk. Because in the RCT, everyone is followed for at least 6 month, there is no censoring for this outcome, and logistic regression is a valid framework for inference. We first create a binary variable indicating whether an exacerbation occurred within the first 6 months.

``` r
rct_data[,'b_exac']<-rct_data[,'tte']<0.5
rct_data[which(is.na(rct_data[,'b_exac'])),'b_exac']<-FALSE
```

Now lets fit the regression

``` r
reg.logostic<-glm(formula = b_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, family = binomial(link="logit"))

print(reg.logostic)
#> 
#> Call:  glm(formula = b_exac ~ tx + sgrq + prev_hosp + prev_ster + fev1, 
#>     family = binomial(link = "logit"), data = rct_data)
#> 
#> Coefficients:
#> (Intercept)           tx         sgrq    prev_hosp    prev_ster  
#>    -1.45847     -0.37696      0.47688      0.35028     -0.05079  
#>        fev1  
#>     0.15754  
#> 
#> Degrees of Freedom: 1107 Total (i.e. Null);  1102 Residual
#> Null Deviance:       1255 
#> Residual Deviance: 1238  AIC: 1250
```

Now we call the Cb.logistic function. This function has two mandatory parameters: the glm object containing the logit model, and a text variable indicating the name of treatment variable.

``` r
res.logistic<-Cb.logistic(reg.logostic,tx_var = "tx")
print(res.logistic)
#> Cb= 0.05618547 
#> e_b= 0.07045515 
#> e_max_b1b2= 0.07464936 
#> Gini= 0.0595302 
#> AUCi= 0.5297651 
#> Data length: 1108
```

The main output is Cb.

Cb.logistic (and similar functions) calculate Cb parametrically. The package includes semi-parametric methods for Cb calculation as well. To use the semi-parametric method, we simply set the value of optimal parameter semi\_parametric to TRUE.

``` r
res.logistic.NP<-Cb.logistic(reg.logostic,tx_var = "tx",semi_parametric = T)
print(res.logistic.NP)
#> Cb= 0.3548675 
#> e_b= 0.07137062 
#> e_max_b1b2= 0.1106294 
#> Gini= NA 
#> AUCi= NA 
#> Data length: 1108
```

##### What happens under the hood?

Cb.logistic() and other functions estimate the outcome for each subject in the data under treatment and no treatment scenarios, and then calculate the vector b as the difference, then they call the Cb.simple() function.

Below we do this manually.

``` r
new_data0<-rct_data
new_data0[,'tx']<-0
new_data1<-rct_data
new_data1[,'tx']<-1
B<-predict.glm(reg.logostic, newdata=new_data0, type="response")-predict.glm(reg.logostic, newdata =new_data1, type="response")
print(Cb.simple(B))
#> Cb= 0.05618547 
#> e_b= 0.07045515 
#> e_max_b1b2= 0.07464936 
#> Gini= 0.0595302 
#> AUCi= 0.5297651 
#> Data length: 1108
```

### Cb.poisson() for count models

Cb.poisson() calculates Cb from count models (Poisson and negative binomial). Note that unlie the logistic model, here follow-up time is relevant too. Cb.poission() by default estimates Cb at one unit of time.

Our plan for the trial data is to fit a model that associates predictor to the number of exacerbations during the follow-up time.

``` r
reg.poisson<-glm(formula = n_exac ~ tx + tx:sgrq + prev_hosp + prev_ster + fev1 + offset(log(time)), data = rct_data, family = poisson(link="log"))

print(reg.poisson)
#> 
#> Call:  glm(formula = n_exac ~ tx + tx:sgrq + prev_hosp + prev_ster + 
#>     fev1 + offset(log(time)), family = poisson(link = "log"), 
#>     data = rct_data)
#> 
#> Coefficients:
#> (Intercept)           tx    prev_hosp    prev_ster         fev1  
#>   -0.737413    -0.603839     0.372331    -0.036207     0.003777  
#>     tx:sgrq  
#>    0.513799  
#> 
#> Degrees of Freedom: 1107 Total (i.e. Null);  1102 Residual
#> Null Deviance:       1118 
#> Residual Deviance: 1083  AIC: 1985
```

Once the regression object is fitted, we call Cb.poisson() passing the regression object and the name of the treatment variable.

``` r
res.poisson<-Cb.poisson(reg.poisson,tx_var = "tx")
print(res.poisson)
#> Cb= 0.1287493 
#> e_b= 0.1660044 
#> e_max_b1b2= 0.1905358 
#> Gini= 0.1477752 
#> AUCi= 0.5738876 
#> Data length: 1108
```

Again, the Cb.poission() function estimates the difference in counterfactual outcomes for each patient, and calls Cb.simple(). Not that to do this manually in this context, we need to set the follow-up time for each subject to 1.

``` r
new_data0<-rct_data
new_data0[,'tx']<-0
new_data0[,'time']<-1
new_data1<-rct_data
new_data1[,'tx']<-1
new_data1[,'time']<-1

B<-predict.glm(reg.poisson, newdata=new_data0, type="response")-predict.glm(reg.poisson, newdata =new_data1, type="response")
print(Cb.simple(B))
#> Cb= 0.1287493 
#> e_b= 0.1660044 
#> e_max_b1b2= 0.1905358 
#> Gini= 0.1477752 
#> AUCi= 0.5738876 
#> Data length: 1108
```

### Cb.cox() for Cox proportional hazard model

Cb.cox() estimates Cb from a proportional hazards model. Like Cb.poission(), the length of time matters in the value of Cb, and Cb.cox() estimates Cb at one unit of time.

Our plan for the trial data is to estimate the effect of covariates on redicting time to the first event. txBenefit is compatible with the Cox proportional hazard model implemented in the survial package.

We create an event indicator and update the tte (time-to-event) variable to be equal to follpow-up time for censored individuals.

``` r
 library("survival")
 event<-(!is.na(rct_data[,'tte']))*1
 ids<-which(event==0)
 rct_data[ids,'tte']<-rct_data[ids,'time']
 rct_data['event']<-event
```

Now we fit the Cox model calling the coxph() function. However, AN IMPORTANT DIFFERENCE is that the object that coxph() by default does not contain the original data (unlike glm()), which is needed for the calculations. As such, we have to call coxph() with an additional argument model=TRUE.

``` r
reg.coxph<-coxph(Surv(time=tte,event=event) ~ tx + tx:female + tx:age + sgrq + prev_hosp + prev_ster + fev1, data=rct_data, model=TRUE)

print(reg.coxph)
#> Call:
#> coxph(formula = Surv(time = tte, event = event) ~ tx + tx:female + 
#>     tx:age + sgrq + prev_hosp + prev_ster + fev1, data = rct_data, 
#>     model = TRUE)
#> 
#>                coef exp(coef)  se(coef)     z       p
#> tx         0.255575  1.291204  0.544894  0.47 0.63904
#> sgrq       0.490846  1.633698  0.315023  1.56 0.11920
#> prev_hosp  0.379077  1.460936  0.104630  3.62 0.00029
#> prev_ster -0.122554  0.884658  0.144538 -0.85 0.39649
#> fev1      -0.000233  0.999767  0.102541  0.00 0.99819
#> tx:female  0.017177  1.017325  0.151408  0.11 0.90968
#> tx:age    -0.009025  0.991015  0.008315 -1.09 0.27773
#> 
#> Likelihood ratio test=29.06  on 7 df, p=1e-04
#> n= 1108, number of events= 413
```

Once this is done, we call the related Cb function:

``` r
 res.coxph<-Cb.cox(reg.coxph,tx_var = "tx")
 print(res)
#> Cb= 0.2676818 
#> e_b= 0.4596051 
#> e_max_b1b2= 0.627603 
#> Gini= 0.3655267 
#> AUCi= 0.6827634 
#> Data length: 100
```

Important note: Cb cannot currently be calculated for Cox models that have time-dependent covariates, nor for the models with strata.
