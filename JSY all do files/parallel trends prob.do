

log using "C:\Users\ssj18\Documents\DHS\results.log",replace


use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151
drop if lps==0
drop if rural==0
keep if b2>=1995 & fg==1
drop if bord==1
reghdfe child_sex $xlist if  b2>=1995 & fg==1 & bord>=2,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg1
tab b2 if bord>=2, sum(yhatfg1)


use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151
drop if lps==0
drop if rural==0
drop if bord==1
keep if b2>=1995 & fg==0
reghdfe child_sex $xlist if  b2>=1995 & fg==0,cl(UID)absorb(v024 b2 v024##b2 bord )
predict yhatfg0
tab b2 if bord>=2, sum(yhatfg0)


use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
drop if rural==0
drop if bord==1
drop if lps==0
gen post5=1 if b2>2005
replace post5=0 if post5==.

gen post6=1 if b2>2006
replace post6=0 if post6==.

global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151
reghdfe child_sex fg##post5 $xlist i.bord if b2>=1995 ,cl(UID)absorb( v024 b2 v024##b2  )
reghdfe child_sex fg##post5 $xlist i.bord if b2>=2000 ,cl(UID)absorb( v024 b2 v024##b2  )
reghdfe child_sex fg##post5 $xlist i.bord if b2>=2001 ,cl(UID)absorb( v024 b2 v024##b2  )



reghdfe child_sex fg##post6 $xlist i.bord if b2>=2000 ,cl(UID)absorb( v024 b2 v024##b2  )
reghdfe child_sex fg##i.b2 $xlist i.bord if b2>=1995 ,cl(UID)absorb( v024 b2 v024##b2  )



**** LPS /HPS
use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
gen post05=1 if b2>=2005
replace post05=0 if post05==.
gen post5=1 if b2>2005
replace post5=0 if post5==.
drop if rural==0
drop if bpl==1
drop if scst==1
global treatment lps
global ylist child_sex
global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151

reghdfe child_sex $xlist lps if  b2>=1995 ,cl(UID)absorb(v024 b2   )
predict cshat,xb

bys b2: egen cshatmlps=mean(cshat) if lps==1
bys b2: egen cshatmhps=mean(cshat) if lps==0

graph twoway  (line cshatmlps b2 if lps==1 & b2>=1995)(line cshatmhps b2 if lps==0 & b2>=1995)


reghdfe child_sex lps##post5 $xlist  if  b2>=1995 & bpl==0  & (upcaste==1 | obc==1),cl(UID)absorb( b2 UID )
reghdfe child_sex lps##post5 $xlist  if  b2>=2000 & bpl==0 & (upcaste==1 | obc==1),cl(UID)absorb( b2 bord UID )
reghdfe child_sex lps##i.b2 $xlist  if  b2>=1995 & bpl==0 & (upcaste==1 | obc==1),cl(UID)absorb( b2 bord UID )

reghdfe child_sex lps##post5 $xlist  if  b2>=1995 & bpl==0  & (upcaste==1 | obc==1) & v602>=5,cl(UID)absorb( b2 v024)

reghdfe child_sex lps##post5 $xlist  if  b2>=1995 & bpl==0  & (upcaste==1 | obc==1) ,cl(UID)absorb( b2 v024)





gen newfg=2 if fg==1
replace newfg=1 if fg==0

gen postn=2 if post5==1
replace postn=1 if post5==0

reghdfe child_sex newfg##postn $xlist i.bord if b2>=1995 & bord>=2 ,cl(UID)absorb( UID b2 )

reghdfe child_sex fg##post5 $xlist  if b2>=1995 & bord>=2  & lps==1,cl(UID)absorb( UID b2 bord )

reghdfe child_sex fg##post5 $xlist  if b2>=1995 & bord>=2 & lps==1,cl(sdistri)absorb( UID b2 bord )

reghdfe child_sex fg##post5 $xlist  if b2>=1995 & bord>=2 & lps==1,cl(v024)absorb( UID b2 bord )




log close



