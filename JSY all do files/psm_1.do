* Propensity Score Matching in Stata

use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
drop if rural==0
drop if scst==1
drop if bpl==1
global treatment lps
global ylist child_sex
global xlist mom_edu hindu musl v138 wealth_index land  v150 v151

	

psmatch2 $treatment $xlist  ,  out($ylist)  caliper(.001) common noreplace neighbor(1) logit ai(1)
pstest 


gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2
gen post5=1 if b2>2005
replace post5=0 if post5==.

gen treat=1 if _treated==1
replace treat=0 if treat==.

reghdfe child_sex _treated##post5 $xlist if  b2>=1995,cl(UID) absorb( b2 UID bord )
reghdfe child_sex treat##post5  if  b2>=1995,cl(UID) absorb( b2 UID bord )




reghdfe child_sex lps##post5 $xlist if  b2>=1995,cl(UID) absorb( b2 UID )


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



reghdfe $ylist $xlist if  b2>=1995 & b2<=2004 & fg==1,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg1  if  e(sample)==1

reghdfe $ylist $xlist if  b2>=1995 & b2<=2004 & fg==0,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg0  if  e(sample)==1


tab b2 if yhatfg1!=., sum(yhatfg1)

tab b2 if yhatfg0!=., sum(yhatfg0)


psmatch2 $treatment $xlist  , out($ylist) common ai(2)
pstest



psgraph
pstest $xlist

psmatch2 $treatment $xlist , out($ylist) common


* For difference-in-differences, outcome is the differences in outcomes after and before
* global ylist REDIFF 

describe $treatment $ylist $xlist
summarize $treatment $ylist $xlist

bysort $treatment: summarize $ylist $xlist

* Regression with a dummy variable for treatment (t-test)
reg $ylist $treatment 

* Regression with a dummy variable for treatment controlling for x
reg $ylist $treatment $xlist if b2<=2011 & b2>=1999

reghdfe $ylist fg##post05 $xlist if b2<=2011 & b2>=1999,absorb(v024 b2)
reghdfe $ylist fg##post05 $xlist i.bord if  b2>=1999,absorb(v024 b2 )

reghdfe $ylist fg##post05 $xlist i.bord if  b2>=1995,absorb(v024 b2 v024##b2)

reghdfe $ylist fg##post05 $xlist i.bord if  b2>=1999,absorb(v024 b2 v024##b2)

reghdfe $ylist fg##post05 $xlist if  b2>=1995,cl(sdistri)absorb(v024 b2 bord)

reghdfe $ylist fg##post05 $xlist i.bord if  b2>=1995,cl(sdistri)absorb(v024 b2 v024##b2 )
reghdfe $ylist fg##post05 $xlist i.bord if  b2>=1995,cl(UID)absorb(v024 b2 v024##b2 )



* Propensity score matching with common support
pscore $treatment $xlist, pscore(myscore) blockid(myblock) comsup

* Matching methods 

* Nearest neighbor matching 
attnd $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots 

* Radius matching 
attr $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots radius(0.1)

* Kernel Matching
attk $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots

* Stratification Matching
atts $ylist $treatment $xlist, pscore(myscore) blockid(myblock) comsup boot reps($breps) dots

