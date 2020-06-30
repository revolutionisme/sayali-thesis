use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
gen post05=1 if b2>=2005
replace post05=0 if post05==.
*drop if b2<=1998 
drop if b2<=1990 
gen post5=1 if b2>2005
replace post5=0 if post5==.
*gen treat=lps*post5
*order UID fg post05 b2 treat child_sex
*drop if bord==1
drop if rural==0
*drop if lps==0
* Define treatment, outcome, and independent variables
global treatment treat
global ylist child_sex
global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151
*global breps 500
*pscore $treatment $xlist, pscore(myscore) logit blockid(myblock) comsup
reghdfe child_sex fg##post5 $xlist i.bord if  b2>=1995 & bord>=2 & rural==1 & lps==1,cl(UID)absorb(v024 b2 v024##b2 )


*works
reghdfe child_sex lps##post5 $xlist  if  b2>=1995 & bpl==0 & (upcaste==1 | obc==1),cl(UID)absorb( b2 bord UID )


keep if b2>=1995 & b2<=2004 & fg==1
reghdfe child_sext $xlist if  b2>=1995 & b2<=2004 & fg==1,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg1 


use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
gen post05=1 if b2>=2005
replace post05=0 if post05==.
*drop if b2<=1998 
drop if b2<=1990 
gen post5=1 if b2>2005
replace post5=0 if post5==.
gen treat=fg*post05
*order UID fg post05 b2 treat child_sex
drop if bord==1
drop if rural==0
drop if lps==0
* Define treatment, outcome, and independent variables
global treatment treat
global ylist child_sex
global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151
*global breps 500
*pscore $treatment $xlist, pscore(myscore) logit blockid(myblock) comsup
*reghdfe $ylist fg##post5 $xlist i.bord if  b2>=1995,cl(UID)absorb(v024 b2 v024##b2 )



keep if b2>=1995 & b2<=2004 & fg==0
reghdfe $ylist $xlist if  b2>=1995 & b2<=2004 & fg==0,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg0  
