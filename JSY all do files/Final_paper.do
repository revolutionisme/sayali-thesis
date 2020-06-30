*******************************************************************************
* The Impact of a Conditional Cash Transfer Program on Household's Fertility
* Decisions in India
* Sayli Javadekar and Kritika Saxena
* 28 october 2018

clear
set more off

cd"C:\Users\ssj18\Documents\DHS"

use "mer_hh_birth",replace
gen str6 v001id = string(v001,"%06.0f")
gen str2 v002id = string(v002,"%02.0f")
gen str2 v003id = string(v003,"%02.0f")

gen one = "1"
*egen UIDBO = concat(one stateid distid psuid hhid hhsplitid personid boid)
egen UID  = concat(one v001id v002id v003id)
duplicates tag UID bord , gen(dup1)
destring UID, replace
format %20.0g UID


* Creating key variables

gen child_sex=1 if b4==2 /*fem*/
replace child_sex=0 if child_sex==.

gen rural =1 if v025==2
replace rural =0 if missing(rural)

gen child_age=v007-b2 //v007gives year of interview
*gen child_age2 = 2016-b2
gen dead =1 if b5==0
replace dead=0 if missing(dead)

gen fg_=1 if bord==1 & child_sex==1/*first child is a girl*/
replace fg_=0 if bord==1 & child_sex==0
bys UID :egen fg=max(fg_)


rename sh58 bpl

gen lps=1 if v024==4 | v024==5 | v024==7 | v024==14  | v024==15   | v024==19 | v024==26 | v024==29 | v024==33 | v024==34 
replace lps=0 if lps==.

label define lps 1"LPS" 0"HPS"
label val lps lps

* generating a var for Sc/ST that does not include OBC
gen sc_st = 1 if s116 <=2 //hh belongs to SC or ST
replace sc_st = 0 if s116>=3
replace sc_st = 0 if v131==993 & sc_st==. //v131==993 is no caste no tribe

gen treat=1 if bpl==0 & sc_st==0 & lps==1
replace treat=0 if bpl==0 & sc_st==0 & lps==0


* state time trend
gen strend = v024*b2
* district time trend
gen dtrend = sdistri*b2

bys UID :gen post05 =1 if b2 >2005 
replace post05 =0 if post05==.

gen p5=1 if b2>=2010 & b2<=2015
replace p5=0 if b2>=2000 & b2<=2005

*** Log file
log using "C:\Users\ssj18\Documents\DHS\28oct2018.log", replace

set more off

* Regression 1: Proof that sex selection is happening in India
reghdfe child_sex i.b2 strend if rural==1 ,  cl(UID) absorb(UID)
est store Rural
reghdfe child_sex i.b2 strend if rural==1 & b2>=2000,  cl(UID) absorb(UID)
est store Rural_2000
esttab Rural Rural_2000, replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions)
//for Latex
*esttab Rural Rural_2000 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


* Regression 2: Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups in all India and rural India
*First with cohorts of 10 - 15 years compared to 5-10 years
* Second with cohorts of 10 - 15 years compared to 0-5 years


  reghdfe child_sex treat##post05 strend i.bord if bord>=2 & b2>=2000 & b2<=2010,  cl(UID) absorb(UID b2 )
est store India_5_9
  reghdfe child_sex treat##post05 strend i.bord if bord>=2 & b2>=2000 & b2<=2010 & rural==1,  cl(UID) absorb(UID b2 )
est store Rural_5_9
  reghdfe child_sex treat##p5 strend i.bord if bord>=2,  cl(UID) absorb(UID b2 )
est store India_0_5
  reghdfe child_sex treat##p5 strend i.bord if bord>=2 & rural==1,  cl(UID) absorb(UID b2 )
est store Rural_0_5
esttab India_5_9 Rural_5_9 India_0_5 Rural_0_5, replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions)
//for Latex
*esttab India_5_9 Rural_5_9 India_0_5 Rural_0_5 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex

* Regression 3: Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups within First Girl Families in all India and rural India


  reghdfe child_sex treat##post05 strend i.bord if bord>=2 & b2>=2000 & b2<=2010 & fg==1,  cl(UID) absorb(UID b2 )
est store India_5_9
  reghdfe child_sex treat##post05 strend i.bord if bord>=2 & b2>=2000 & b2<=2010 & rural==1 & fg==1,  cl(UID) absorb(UID b2 )
est store Rural_5_9
  reghdfe child_sex treat##p5 strend i.bord if bord>=2 & fg==1,  cl(UID) absorb(UID b2 )
est store India_0_5
  reghdfe child_sex treat##p5 strend i.bord if bord>=2 & rural==1 & fg==1,  cl(UID) absorb(UID b2 )
est store Rural_0_5
esttab India_5_9 Rural_5_9 India_0_5 Rural_0_5, replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions)
//for Latex
*esttab India_5_9 Rural_5_9 India_0_5 Rural_0_5 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


* Regression 4: Robustness check for the program year effect.


  reghdfe child_sex treat##i.b2 strend i.bord if bord>=2 & b2>=2000  & rural==1,  cl(UID) absorb(UID b2 )
est store Rural
  reghdfe child_sex treat##i.b2 strend i.bord if bord>=2 &  b2>=2000 & rural==1 & fg==1,  cl(UID) absorb(UID b2 )
est store Rural_FG
esttab Rural Rural_FG, replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions)
//for Latex
*esttab Rural Rural_FG , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex




 log close

