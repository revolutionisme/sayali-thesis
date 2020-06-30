use "C:\Users\ssj18\Documents\DHS\use_data.dta", clear

gen child_age = v007- b2

*balance test full LPS. all years
bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==1 & dup<=1, by(fg)
ttest mom_age  if rural==1  & lps==1 & dup<=1, by(fg)
ttest dad_age  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest bpl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest land  if rural==1  & lps==1 & dup<=1, by(fg)
ttest bicycle  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest tv  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest refrigerator  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest child_sex  if rural==1  & lps==1 & bord>=2, by(fg)/*balanced*/






gen wife=1 if v150==2
replace wife=0 if wife==.


gen dl=1 if v150==4
replace dl=0 if dl==.


gen pre=1 if b2>=1995 & b2<=2005 & bord==1
replace pre=0 if pre==.

reg fg mom_edu mom_age dad_age dad_edu bpl upcaste scst hindu musl land v138 bicycle tv refrigerator wife [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 

reg fg mom_edu mom_age dad_age dad_edu bpl upcaste scst hindu musl land i.v150 v138 if rural==1  & lps==1 & dup<=1 ,r 



*balance test full LPS. all years
bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==1 & dup<=1 & b2>=1995, by(fg)
ttest mom_age  if rural==1  & lps==1 & dup<=1 & b2>=1995, by(fg)
ttest dad_age  if rural==1  & lps==1 & dup<=1 & b2>=1995, by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest bpl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest land  if rural==1  & lps==1 & dup<=1, by(fg)
ttest bicycle  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest tv  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest refrigerator  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest child_sex  if rural==1  & lps==1 & bord>=2, by(fg)/*balanced*/



*LPS balance test pre treatment years

bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==1 & dup<=1 & b2, by(fg)
ttest mom_age  if rural==1  & lps==1 & dup<=1, by(fg)
ttest dad_age  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest bpl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest land  if rural==1  & lps==1 & dup<=1, by(fg)
ttest bicycle  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest tv  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest refrigerator  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest child_sex  if rural==1  & lps==1 & bord>=2, by(fg)/*balanced*/




reg mom_age fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg mom_edu fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_age fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_edu fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bpl fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg upcaste  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg scst  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg hindu  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg musl  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg land  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bicycle  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg tv  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg refrigerator  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dl fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg wife fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 



7

mlogit v150  fg [aw=v005]if rural==1  & lps==1 & bord==1 & b2<=2005 & b2>=1995,r 




reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb( b2 v024 b2##v024 )

reghdfe child_sex fg##post   if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb( b2 v024 b2##v024 )



tabulate b2 child_sex  [aw=v005] if rural==1  & lps==1 & bord==1 

tabulate b2 child_sex  [aw=v005] if rural==1  & lps==1 & bord==2 & fg==1 
tabulate b2 child_sex  [aw=v005] if rural==1  & lps==1 & bord==2 & fg==0

tabulate b2 child_sex  [aw=v005] if rural==1  & bord==1  & lps==1
tabulate b2 child_sex  [aw=v005] if rural==1  & bord==1  & lps==0


reg mom_age lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg mom_edu lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_age lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_edu lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bpl lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg upcaste  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v150  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg hindu  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg musl  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg land  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bicycle  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg tv  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg refrigerator  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v138  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v221  lps [aw=v005]if rural==1  & obc==1 & bord==1 & b2<=2005 & b2>=1995,r 



reg mom_age lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg mom_edu lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_age lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_edu lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bpl lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg upcaste  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v150  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg hindu  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg musl  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg land  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bicycle  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg tv  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg refrigerator  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v138  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v221  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 





 teffects nnmatch (child_sex  ) (lps)
 
 
 teffects nnmatch (child_sex mom_edu mom_age dad_age dad_edu land  ) (lps), ematch(obc upcaste hindu musl s190rs) biasadj(mom_edu mom_age dad_age dad_edu land ) 

 
 
 
 
 
 
 
 *balance test full LPS. all years
bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==1 & dup<=1 & b2>=1995 & b2<=2005, by(fg)
ttest mom_age  if rural==1  & lps==1 & dup<=1 & b2>=1995 & b2<=2005, by(fg)
ttest dad_age  if rural==1  & lps==1 & dup<=1 & b2>=1995 & b2<=2005, by(fg)/**/
ttest dad_edu  if rural==1  & lps==1 & dup<=1 & b2>=1995 & b2<=2005, by(fg)/**/
ttest bpl  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/**/
ttest upcaste  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest land  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)
ttest bicycle  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest tv  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest refrigerator  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest s190rs  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest v150  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest v138  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest hh_musl  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest hh_hindu  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest wife  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)
ttest dl  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)
ttest child_sex  if rural==1  & lps==1 & bord>=2 & b2<=2005 & b2>=1995, by(fg)/*balanced*/
ttest hv246  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)
ttest obc  if rural==1  & lps==1 & dup<=1 & b2<=2005 & b2>=1995, by(fg)





gen hh_hindu=1 if sh34==1
replace hh_hindu=0 if hh_hindu==.

gen hh_musl=1 if sh34==2
replace hh_musl=0 if hh_musl==.

gen hh_f=1 if hv219==2
replace hh_f =0 if hh_f==.


*All inida 

tabulate b2 child_sex  [aw=v005] if bord==1 & lps==1
tabulate b2 child_sex  [aw=v005] if bord==1 & lps==0


* Treated non treated by states, ALL INDIA
tabulate b2 child_sex  [aw=v005] if bord==1 & lps==1 & bpl==0 & (upcaste==1 | obc==1)
tabulate b2 child_sex  [aw=v005] if bord==1 & lps==0 & bpl==0 & (upcaste==1 | obc==1)



tabulate b2 child_sex  [aw=v005] if bord==2 & lps==1 & bpl==0 & (upcaste==1 | obc==1) & fg==1
tabulate b2 child_sex  [aw=v005] if bord==2 & lps==0 & bpl==0 & (upcaste==1 | obc==1) & fg==1


* Treated non treated by states, RURAL
tabulate b2 child_sex  [aw=v005] if bord==1 & lps==1 & bpl==0 & (upcaste==1 | obc==1) & rural ==1
tabulate b2 child_sex  [aw=v005] if bord==1 & lps==0 & bpl==0 & (upcaste==1 | obc==1) & rural ==1



tabulate b2 child_sex  [aw=v005] if bord==2 & lps==1 & bpl==0 & (upcaste==1 | obc==1) & fg==1 & rural ==1
tabulate b2 child_sex  [aw=v005] if bord==2 & lps==0 & bpl==0 & (upcaste==1 | obc==1) & fg==1 & rural ==1







tabulate b2 child_sex  [aw=v005] if rural==1  & bord==1  & lps==0





reghdfe mom_age lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,absorb(v024 b2) 
reg mom_edu lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_age lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg dad_edu lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bpl lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg upcaste  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v150  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg hindu  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg musl  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg land  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg bicycle  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg tv  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg refrigerator  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v138  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 
reg v221  lps [aw=v005]if rural==1  & upcaste==1 & bord==1 & b2<=2005 & b2>=1995,r 





ttest mom_edu  if rural==1 & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)
ttest mom_age  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)
ttest dad_age  if rural==1 & upcaste==1 | bpl==0 | obc==1   & dup<=1, by(lps)/*balanced*/
ttest dad_edu  if rural==1 & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest bpl  if rural==1 & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest upcaste  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest scst  if rural==1  & upcaste==1 | bpl==0 | obc==1 & dup<=1, by(lps)/*balanced*/
ttest hindu  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest musl  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest land  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)
ttest bicycle  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest tv  if rural==1  & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/
ttest refrigerator  if rural==1 & upcaste==1 | bpl==0 | obc==1  & dup<=1, by(lps)/*balanced*/




ttest child_sex  if rural==1  & upcaste==1 | bpl==0 | obc==1  & bord>=2, by(lps)/*balanced*/










/*****Synthetic trials
*total no of indivs by district
bys sdistri : gen id = _n 
bys sdistri : gen id_c = _n if child_age>=5 & child_age<=17
bys sdistri : egen tot_c = max(id_c) /*total child 0-5 in the district*/



bys sdistri : egen tot_ = max(id) /*total people in the district*/
bys sdistri : egen sum05 = total(child_sex) if child_age>=5 & child_age<=17
bys sdistri : egen sum05b = total(child_sex) if child_age>=5 & child_age<=17

bys sdistri : gen tot_b = tot_c-sum05 if id_c!=. /*total boy 0-5 in the district*/

bys sdistri : gen sex_ratio = sum05/tot_b if id_c!=. /*total boy 0-5 in the district*/

bys sdistri : egen upcastetemp = total(upcaste) 
bys sdistri : egen scsttemp = total(scst) 
bys sdistri : egen obctemp = total(obc) 
bys sdistri : egen bpltemp = total(bpl) 


gen uc_prop=upcastetemp/tot_
gen scst_prop=scsttemp/tot_
gen obc_prop=obctemp/tot_
gen bpl_prop=bpltemp/tot_

bys sdistri : egen medu = mean(mom_edu) 
bys sdistri : egen mage = mean(mom_age) 

order   sdistri b2 sex_ratio uc_prop scst_prop obc_prop bpl_prop




tsset sdistri b2
synth sex_ratio uc_prop scst_prop obc_prop bpl_prop sex_ratio(2004) sex_ratio(2003) sex_ratio(2002) ,trunit(lps) trperiod(2005) nested fig

*/




****

gen treat =1 if (upcaste==1| obc==1 | bpl==1) & lps==1
replace treat =0 if (upcaste==1| obc==1 | bpl==1) & lps==0

reghdfe child_sex treat [aw=v005] if rural==1 & bord==1 & b2<=2005 & b2>=1995 & treat!=., absorb(b2) 
reghdfe child_sex treat [aw=v005] if rural==1 & bord==2 & b2<=2005 & b2>=1995 & treat!=., absorb(b2) 






















***** kids between 0-6 pre post
use "C:\Users\ssj18\Documents\DHS\use_data.dta", clear
drop child_age

gen c05=1 if b2<=2012 & b2>=1998
bys sdistri : gen id = _n 
bys sdistri b2 : egen sum05 = total(child_sex) if c05==1 /*tot girls in distrct at a time*/

bys sdistri b2: gen id_c = _n if c05==1
bys sdistri b2 : egen tot_c = max(id_c) /*total child 0-5 in the district*/
bys sdistri b2: egen tot_ = max(id) /*total people in the district*/

bys sdistri b2: gen tot_b = tot_c-sum05 if c05!=. /*total boy 0-5 in the district*/
order sdistri b2 sum05 tot_b tot_c 

bys sdistri b2 : gen sex_ratio = sum05/tot_b if c05!=. /*total boy 0-5 in the district*/

bys sdistri b2: egen upcastetemp = total(upcaste) 
bys sdistri b2: egen scsttemp = total(scst) 
bys sdistri b2: egen obctemp = total(obc) 
bys sdistri b2: egen bpltemp = total(bpl) 


gen uc_prop=upcastetemp/tot_
gen scst_prop=scsttemp/tot_
gen obc_prop=obctemp/tot_
gen bpl_prop=bpltemp/tot_

bys sdistri b2: egen medu = mean(mom_edu) 
bys sdistri b2: egen mage = mean(mom_age) 


by sdistri b2:  gen dupll = cond(_N==1,0,_n)
order  sdistri b2 dupll


xtset sdistri b2  if dupll==1


keep if dupl==1 & b2<=2010 & b2>=2000

xtset sdistri b2



synth_runner sex_ratio uc_prop scst_prop obc_prop bpl_prop , d(lps) trends 
synth_runner sex_ratio uc_prop bpl_prop , d(lps) trends 



gen byte D = 1 if lps==1
replace D=0 if lps==0

synth_runner sex_ratio uc_prop(2000(1)2005) scst_prop(2000(1)2005) medu mage, d(D) trends




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



synth_runner sex_ratio uc_prop scst_prop obc_prop bpl_prop medu mage,  d(D) trends


synth sex_ratio uc_prop scst_prop obc_prop bpl_prop medu(1985(1)2004) mage(1985(1)2004) sex_ratio(1985) sex_ratio(1992) sex_ratio(1998) sex_ratio(2003), trunit(7) trperiod(2006) fig

egen state = group(v024), label


*https://www.statalist.org/forums/forum/general-stata-discussion/general/1303878-placebo-tests-for-synthetic-control-method
forval i=1/27{

qui synth sex_ratio uc_prop scst_prop obc_prop bpl_prop medu(1985(1)2004) mage(1985(1)2004) sex_ratio(1985) ///
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




twoway `lp' || line tr_effect_3 years, ///
lcolor(orange) legend(off) xline(2005, lpattern(dash))
