
cd"C:\Users\ssj18\Documents\DHS"


***** kids between 0-6 pre post
use "C:\Users\ssj18\Documents\DHS\use_data.dta", clear
drop child_age

gen child_age = v007- b2
*gen c05=1 if b2<=2016 & b2>=1994
bys v024 b2 : gen id = _n 

bys v024 b2 : egen sum05 = total(child_sex) /*if  c05==1 tot girls in distrct at a time*/

bys v024 b2: gen id_c = _n /*if c05==1*/
bys v024 b2 : egen tot_c = max(id_c) /*total child 0-5 in the district*/

bys v024 b2: egen tot_ = max(id) /*total people in the district*/

bys v024 b2: gen tot_b = tot_c-sum05 /*if c05!=. total boy 0-5 in the district*/
order v024 b2 sum05 tot_b tot_c 

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
order  v024 b2 dupll sex_ratio uc_prop scst_prop obc_prop bpl_prop

drop if sex_ratio==.


keep if dupll==1 
drop if b2==2016
xtset v024 b2  

gen byte D = lps

save "C:\Users\ssj18\Documents\DHS\trial",replace

keep  if (lps==1 & v024==7) | lps==0

drop if b2<=1985

tsset v024 b2

*synth_runner sex_ratio uc_prop scst_prop obc_prop bpl_prop medu mage,  d(D) trends


synth sex_ratio uc_prop scst_prop obc_prop bpl_prop medu(1986(1)2004) mage(1986(1)2004) sex_ratio(1986) sex_ratio(1992) sex_ratio(1998) sex_ratio(2003), trunit(7) trperiod(2006) fig



egen state = group(v024),label /*1 is treatment*/


*https://www.statalist.org/forums/forum/general-stata-discussion/general/1303878-placebo-tests-for-synthetic-control-method

forval i=1/27{

qui synth sex_ratio uc_prop scst_prop obc_prop bpl_prop medu(1986(1)2004) mage(1986(1)2004) sex_ratio(1986) ///
sex_ratio(1992) sex_ratio(1998) sex_ratio(2003), trunit(`i') trperiod(2006)   keep(synth_`i', replace)
}



forval i=1/27{

use synth_`i', clear

rename _time years

gen tr_effect_`i' = _Y_treated - _Y_synthetic

keep years tr_effect_`i'

drop if missing(years)

save synth_`i', replace
}


use synth_1, clear

forval i=1/27{

qui merge 1:1 years using synth_`i', nogenerate
}




twoway `lp' || line tr_effect_5 years, ///
lcolor(orange) legend(off) xline(2005, lpattern(dash))
