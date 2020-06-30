

******************************************************Mortality******************************************************************

* In this section we estimate the impact of the program on mortality of the children, given by perinatal (7days)
* neonatal (28 days), infant (1 year) and under 5 (5 years) mortality.

*********************************************************************************************************************************
bys UID :gen post_05 =1 if b2 >2005 & b2 <=2010 
replace post_05 =0 if  b2>=2000 & b2<=2005

gen p5=1 if b2>2010 & b2<=2015
replace p5=0 if b2>=2000 & b2<=2005

*under5
gen dead15=1 if b6<=305 & b6>212 
replace dead15=0 if dead15==.

*one year
gen dead1_28=1 if b6<=212 | b6==301 & b6> 128
replace dead1_28=0 if dead1_28==.

*28 days
gen dead28_7=1 if b6<=128 & b6>107
replace dead28_7=0 if dead28_7==.

gen dead30_1=1 if b6<=305 & b6 >=131
replace dead30_1=0 if dead30_1==.

gen dead2_5=1 if b6<=305 & b6 >224
replace dead2_5=0 if dead2_5==.



* 28 days
reghdfe dead28_7 treat##i.p05##child_sex strend if rural==1 & mtempo==1  , cl(v024) absorb(  bord b2 UID  v024)
eststo full28
reghdfe dead28_7 treat##post##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo u28_59
esttab  full28 u28_59  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1_28 treat##i.p05##child_sex strend if rural==1 & mtempo==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo full1
reghdfe dead1_28 treat##post##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo u1_05
esttab  full1 u1_05  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 5
reghdfe dead15 treat##i.p05##child_sex strend if rural==1 & mtempo==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo full5
reghdfe dead15 treat##post##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo u5_05
esttab  full5 u5_05  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex







bys UID :gen post05_f =1 if b2 >=2000 & b2<=2005 
replace post05_f =0 if b2>=1995 & b2<2000

bys UID :gen p_f =1 if b2 >=2000 & b2<=2005 
replace p_f =0 if b2>=1990 & b2<=1995


 reghdfe child_sex treat##post05_f strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
 
 
  reghdfe child_sex treat##p_f strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
 