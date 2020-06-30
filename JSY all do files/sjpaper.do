/*Cohort simulation Study for DR paper in The Stata Journal*/

set scheme sj
drop _all
set obs 1000
set seed 4567
generate x=1
replace x=0 if _n>1000/2
generate ybase=invnorm(uniform())
generate e1=invnorm(uniform())
generate pi=(1-x)/(1+exp(-1+0.1*ybase)) + x/(1+exp(+0.9-0.1*ybase))
generate u1=uniform()
gen a=0
replace a=1 if pi>=u1
gen ysqr=ybase^2
gen intxy=x*ybase
gen intxy2=x*ysqr
generate y=0.5*a-0.45+0.35*ybase+0.1*x+0.3*intxy+0.3*intxy2+0.25*ysqr+e1

summ x ybase pi a y

histogram pi, by(a)

xi:logit a i.x*ybase
predict pihat
gen invwt=a/pihat + (1-a)/(1-pihat)

histogram pihat, by(a)

regress y a [pweight=invwt]

regress y a x ybase intxy ysqr intxy2

regress y ybase x intxy ysqr intxy2 if a==1
predict mu1
regress y ybase x intxy ysqr intxy2 if a==0
predict mu0
gen mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
gen iptw=(2*a-1)*y*invwt
gen dr1=iptw+mdiff1
summ dr1

local dr_est=r(mean)
tempvar I dr_var
gen `I'=dr-`dr_est'
gen I2=`I'^2
summ I2
gen `dr_var'=r(mean)/1000
scalar dr_se=sqrt(`dr_var')
di dr_se


dr y a, ovars(ybase x intxy ysqr intxy2) pvars(x ybase intxy)

dr y a, ovars(ybase x intxy ysqr intxy2) pvars(x ybase intxy) vce(bootstrap, reps(200) seed(1234))


//Alternative DR estimators using the DR command not included in the paper

/*dr2*/
dr y a, ovars(ybase x intxy ysqr intxy2) pvars(x ybase)
dr y a, ovars(ybase x intxy ysqr intxy2) pvars(x ybase) vce(bootstrap, reps(200) seed(1234))

/*dr3*/
dr y a, ovars(ybase x intxy) pvars(x ybase intxy)
dr y a, ovars(ybase x intxy) pvars(x ybase intxy) vce(bootstrap, reps(200) seed(1234))

/*dr4*/
dr y a, ovars(ybase x intxy) pvars(x ybase) 
dr y a, ovars(ybase x intxy) pvars(x ybase) vce(bootstrap, reps(200) seed(1234))



