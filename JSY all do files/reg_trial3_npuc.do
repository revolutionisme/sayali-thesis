
**** Treatment LPS(full) Control HPS(full) urban + rural ***


cd"C:\Users\ssj18\Documents\DHS" 


***** kids between 0-6 pre post
use "C:\Users\ssj18\Documents\DHS\use_data.dta", clear
*drop if rural==0
drop child_age
*drop if scst==1
*drop if bpl==1

bys UID: egen lb=max(bord)
keep if lb==bord

*bys UID  : egen no_g = sum(child_sex)
*bys UID  : gen p_g = no_g/v201


gen child_age = v007- b2
*gen c05=1 if b2<=2016 & b2>=1994
bys v024 b2 : gen id = _n 

/*gen samp=1 if bord==1 & b2>=1995
bys UID: egen trialsamp=max(samp)
bys UID:egen fam_s= max(bord)

***psm trials

global treatment lps
global ylist p_g
global xlist mom_edu  upcaste obc wealth_index   hv245 
global breps 500 

describe $treatment $ylist $xlist
summarize $treatment $ylist $xlist 
bysort $treatment: summarize $ylist $xlist ,sep(100)

* Regression with a dummy variable for treatment (t-test)
reg $ylist $treatment if rural==1 & trialsamp!=.

* Regression with a dummy variable for treatment controlling for x
reg $ylist $treatment $xlist fam_s  if rural==1 & samp!=.
reg no_g $treatment $xlist  if rural==1 & samp!=.


pscore $treatment $xlist if rural==1 & samp==1, pscore(myscore) blockid(myblock) comsup 
*/

bys v024 b2 : egen sum05 = total(child_sex) /*if  c05==1 tot girls in distrct at a time*/

bys v024 b2: gen id_c = _n /*if c05==1*/
bys v024 b2 : egen tot_c = max(id_c) /*total child 0-5 in the district*/

bys v024 b2: egen tot_ = max(id) /*total people in the district*/

bys v024 b2: gen tot_b = tot_c-sum05 /*if c05!=. total boy 0-5 in the district*/
order v024 b2 sum05 tot_b tot_c 

bys v024 b2: gen prop_g = sum05*100/tot_c /*if c05!=. total boy 0-5 in the district*/


bys v024 b2 : gen sex_ratio = sum05/tot_b /*if c05!=. total boy 0-5 in the district*/

bys v024 b2: egen upcastetemp = total(upcaste) 
bys v024 b2: egen scsttemp = total(scst) 
bys v024 b2: egen obctemp = total(obc) 
bys v024 b2: egen bpltemp = total(bpl) 


gen uc_prop=upcastetemp/tot_
gen scst_prop=scsttemp/tot_
gen obc_prop=obctemp/tot_
gen bpl_prop=bpltemp/tot_

bys v024 b2: egen medu = mean(mom_edu) 


bys v024 b2: egen mage = mean(mom_age) 



by v024 b2:  gen dupll = cond(_N==1,0,_n)
order  v024 b2 dupll sex_ratio uc_prop  obc_prop 

drop if sex_ratio==.


keep if dupll<=1 
drop dupll

save "C:\Users\ssj18\Documents\DHS\trial_npuc",replace


use "C:\Users\ssj18\Documents\DHS\trial_npuc",clear
egen state = group(v024),label /*1 is treatment*/


bys state : gen _id=_n	
drop if state==18


drop if b2==2016
drop if b2<=1995
*drop if state==18
*drop if state==23
*drop if state==12

tsset state b2


gen byte D = (lps==1 & b2>=2005) 

tab state
tab state,nol
synth_runner sex_ratio uc_prop medu uc_prop obc_prop scst_prop bpl_prop, d(D) trends training_propr(`=13/18')





/*


synth_runner sum05 uc_prop medu uc_prop obc_prop ///
, d(D) trends training_propr(`=13/18')
pval_graphs

synth_runner prop_g uc_prop medu uc_prop obc_prop ///
, d(D) trends training_propr(`=13/18')


synth_runner sex_ratio uc_prop medu uc_prop obc_prop ///
, d(D) trends training_propr(`=13/18')

synth_runner sum05 uc_prop medu  dedu ///
, d(D) trends training_propr(`=13/18') 


synth_runner sum05 uc_prop medu obc_prop dedu dage ///
, d(D) trends training_propr(`=13/18') 

synth_runner sum05 uc_prop medu  ///
sex_ratio(1995) sex_ratio(1998) sex_ratio(2003), d(D) trends  pre_limit_mult(10) ci

synth_runner prop_g uc_prop medu  ///
sex_ratio(1995) sex_ratio(1998) sex_ratio(2003), d(D) trends training_propr(`=13/18')

synth_runner tot_b uc_prop medu  ///
, d(D) trends training_propr(`=13/18')

synth_runner tot_c uc_prop medu  ///
, d(D) trends training_propr(`=13/18')
pval_graphs



synth_runner sex_ratio uc_prop medu  ///
sex_ratio(1995) sex_ratio(1998) sex_ratio(2003), d(D) trends training_propr(`=13/18')


synth_runner sex_ratio uc_prop  obc_prop dedu dage medu(1996(1)2004) mage(1996(1)2004) ///
sex_ratio(1996) sex_ratio(1998) sex_ratio(2003), d(D) trends training_propr(`=13/18')
pval_graphs
effect_graphs


drop if b2<=2000
drop if b2>=2011

synth_runner sex_ratio uc_prop  obc_prop dedu dage medu(2001(1)2004) mage(2001(1)2004) ///
 sex_ratio(2001) sex_ratio(2003), d(D) trends training_propr(`=13/18')

 
 
 
 
synth_runner prop_g uc_prop  obc_prop dedu dage medu mage ///
sex_ratio(1995) sex_ratio(1998) sex_ratio(2003), d(D) trends training_propr(`=13/18')
 

 
 
 
 
 
 
*****





 
 