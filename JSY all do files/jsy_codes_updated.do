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


gen strend = v024*b2
gen dtrend = sdistri*b2

bys UID :gen post05 =1 if b2 >2005 & b2<=2010 
replace post05 =0 if b2>=2000 & b2<=2005

gen p5=1 if b2>2010 & b2<=2015
replace p5=0 if b2>=2000 & b2<=2005

bys UID :gen post =1 if b2 >2005 
replace post =0 if b2>=2000 & b2<=2005


*birth spacing
sort caseid bord
bysort caseid  : gen birth_space = b2[_n+1]-b2


* Impact on sex selection
//Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups in all India and rural India
*First with cohorts of 10 - 15 years compared to 5-10 years
* Second with cohorts of 10 - 15 years compared to 0-5 years
* Third with 2000-2005, 2005>
***** Both estimations together

bys UID :gen p05 =1 if b2 >2005 & b2<=2010 
replace p05=2 if b2>2010 & b2<=2015
replace p05 =0 if b2>=2000 & b2<=2005


** state cl
reghdfe child_sex treat##i.p05 strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo r1
reghdfe child_sex treat##post strend  if rural==1,  cl( v024) absorb(UID b2 bord v024)
est store Rural

** state cl bord>1
reghdfe child_sex treat##i.p05 strend  if  rural==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
eststo r11
reghdfe child_sex treat##post strend  if rural==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
est store Rural1

** state cl bord>2
reghdfe child_sex treat##i.p05 strend  if  rural==1 & bord>2,  cl( v024) absorb(UID b2 bord v024)
eststo r12
reghdfe child_sex treat##post strend  if rural==1 & bord>2,  cl( v024) absorb(UID b2 bord v024)
est store Rural2

esttab  r1 Rural r11 Rural1 r12 Rural12, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


*triple diff
** state cl
reghdfe child_sex treat##i.p05##fg strend  if  rural==1 & bord>=2,  cl( v024) absorb(UID b2 bord v024)
eststo r1f
reghdfe child_sex treat##post##fg strend  if rural==1 & bord>=2,  cl( v024) absorb(UID b2 bord v024)
est store Ruralf
*esttab  r1f Ruralf , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


*triple diff bord>=3
** state cl
reghdfe child_sex treat##i.p05##fg strend  if  rural==1 & bord>=3,  cl( v024) absorb(UID b2 bord v024)
eststo r1f
reghdfe child_sex treat##post##fg strend  if rural==1 & bord>=3,  cl( v024) absorb(UID b2 bord v024)
est store Ruralf
*esttab  r1f3 Ruralf3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


esttab  r1f Ruralf r1f3 Ruralf3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


******************************************************Mortality******************************************************************

* In this section we estimate the impact of the program on mortality of the children, given by perinatal (7days)
* neonatal (28 days), infant (1 year) and under 5 (5 years) mortality.

*********************************************************************************************************************************

*under5
gen dead5=1 if b6<=305
replace dead5=0 if dead5==.

*under3
gen dead3=1 if b6<=303
replace dead3=0 if dead3==.

*one year
gen dead1=1 if b6<=212 | b6==301
replace dead1=0 if dead1==.

*28 days
gen dead28=1 if b6<=128
replace dead28=0 if dead28==.

*7 days
gen dead7=1 if b6<=107
replace dead7=0 if dead7==.


*state cl

* 7 days
reghdfe dead7 treat##i.p05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo i1
reghdfe dead7 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo i3
esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##i.p05##child_sex strend if rural==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo j1
reghdfe dead28 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo j3
esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##i.p05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo k1
reghdfe dead1 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo k3
esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##i.p05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo n1
reghdfe dead3 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo n3
esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##i.p05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo m1
reghdfe dead5 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo m3
esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex

*mother cl

* 7 days
reghdfe dead7 treat##i.p05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo i1m
reghdfe dead7 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo i3m
esttab  i1m  i3m  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##i.p05##child_sex strend if rural==1 , cl(UID) absorb(  bord b2 UID v024 )
eststo j1m
reghdfe dead28 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo j3m
esttab  j1m  j3m  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##i.p05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo k1
reghdfe dead1 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo k3
esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##i.p05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo n1m
reghdfe dead3 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo n3m
esttab  n1m  n3m , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##i.p05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo m1m
reghdfe dead5 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo m3m
esttab  m1m  m3m , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex

**birth spacing mother cl

reghdfe birth_space treat##i.p05##child_sex strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo b1m
reghdfe birth_space treat##post##child_sex strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo b3m

esttab  b1m  b3m, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex

**birth spacing state cl

reghdfe birth_space treat##i.p05##child_sex strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo b1
reghdfe birth_space treat##post##child_sex strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo b3

esttab  b1  b3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex
