log using "C:\Users\ssj18\Documents\DHS\results.log",replace

use "C:\Users\ssj18\Documents\DHS\use_data.dta" ,clear
*no of mothers





global xlist mom_edu i.scst i.uc_obc i.hindu i.musl v138 i.wealth_index i.land  i.v150 i.v151

gen post5=1 if b2>2005
replace post5=0 if post5==.

gen post05=1 if b2>=2005
replace post05=0 if post05==.

gen fgp5=fg*post5

order UID bord b2 child_sex fg post5 fgp5 mom_edu

* LPS rural, with mfe
reghdfe child_sex fg##post5 $xlist i.bord if b2>=1995 & lps==1 & rural==1 & bord>=2 ,cl(UID)absorb(  b2 UID  )
reghdfe child_sex fg##post05 $xlist i.bord if b2>=1995 & lps==1 & rural==1 & bord>=2,cl(UID)absorb( b2 UID  )

* HPS rural, with mfe
reghdfe child_sex fg##post5 $xlist i.bord if b2>=1995 & lps==0 & rural==1 & bord>=2 ,cl(UID)absorb(  b2 UID  )
reghdfe child_sex fg##post05 $xlist i.bord if b2>=1995 & lps==0 & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )

* All India rural, with mfe
reghdfe child_sex fg##post5 $xlist i.bord if b2>=1995  & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )
reghdfe child_sex fg##post05 $xlist i.bord if b2>=1995  & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )


* leads and lags for lps rural
reghdfe child_sex fg##post5 $xlist i.bord if b2>=1995 & lps==1 & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )
reghdfe child_sex fg##post5 $xlist i.bord if b2>=2000 & lps==1 & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )

reghdfe child_sex fg##post05 $xlist i.bord if b2>=1995 & lps==1 & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )
reghdfe child_sex fg##post05 $xlist i.bord if b2>=2000 & lps==1 & rural==1 & bord>=2,cl(UID)absorb(  b2 UID  )


**** triple difference lps/hps upcaste, obc, nonbpl

reghdfe child_sex fg##post05##lps $xlist i.bord if b2>=1995 & (obc==1| upcaste==1 | bpl==1) & rural==1 & bord>=2,cl(UID)absorb( b2 UID  )


log close
