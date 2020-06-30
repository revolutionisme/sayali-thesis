
**** Treatment LPS(full) Control HPS(full) urban + rural ***


cd"C:\Users\ssj18\Documents\DHS" 


***** kids between 0-6 pre post
use "C:\Users\ssj18\Documents\DHS\use_data.dta", clear
*drop if rural==0
drop child_age
drop if scst==1
drop if bpl==1


gen child_age = v007- b2
*gen c05=1 if b2<=2016 & b2>=1994
bys sdistri b2 : gen id = _n 

bys sdistri b2 : egen sum05 = total(child_sex) /*if  c05==1 tot girls in distrct at a time*/

bys sdistri b2: gen id_c = _n /*if c05==1*/
bys sdistri b2 : egen tot_c = max(id_c) /*total child 0-5 in the district*/

bys sdistri b2: egen tot_ = max(id) /*total people in the district*/

bys sdistri b2: gen tot_b = tot_c-sum05 /*if c05!=. total boy 0-5 in the district*/
order sdistri b2 sum05 tot_b tot_c 

bys sdistri b2 : gen sex_ratio = sum05/tot_b /*if c05!=. total boy 0-5 in the district*/

bys sdistri b2: egen upcastetemp = total(upcaste) 
*bys sdistri b2: egen scsttemp = total(scst) 
bys sdistri b2: egen obctemp = total(obc) 
*bys sdistri b2: egen bpltemp = total(bpl) 


gen uc_prop=upcastetemp/tot_
*gen scst_prop=scsttemp/tot_
gen obc_prop=obctemp/tot_
*gen bpl_prop=bpltemp/tot_

bys sdistri b2: egen medu = mean(mom_edu) 
bys sdistri b2: egen mage = mean(mom_age) 
bys sdistri b2: egen dedu = mean(dad_edu) 
bys sdistri b2: egen dage = mean(dad_age) 


by sdistri b2:  gen dupll = cond(_N==1,0,_n)
order  sdistri b2 dupll sex_ratio uc_prop  obc_prop 

drop if sex_ratio==.


keep if dupll==1 

save "C:\Users\ssj18\Documents\DHS\trial_npuc_dist",replace


use "C:\Users\ssj18\Documents\DHS\trial_npuc_dist",clear
egen state = group(v024),label /*1 is treatment*/


bys sdistri : gen _id=_n	
order sdistri b2 _id
drop if b2==2016
drop if b2<=1987
drop if state==18
drop if state==23

tsset state b2


gen byte D = (lps==1 & b2>=2005) 

tab state
tab state,nol
synth_runner sex_ratio uc_prop  obc_prop dedu dage medu(1995(1)2004) mage(1995(1)2004) ///
sex_ratio(1995) sex_ratio(1998) sex_ratio(2003), d(D) trends training_propr(`=13/18')
pval_graphs


drop if b2<=2000
drop if b2>=2011

synth_runner sex_ratio uc_prop  obc_prop dedu dage medu mage ///
 sex_ratio(2001) sex_ratio(2003), d(D) trends training_propr(`=13/18')
