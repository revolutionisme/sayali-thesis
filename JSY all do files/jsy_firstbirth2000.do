*******************************************************************************
* The Impact of a Conditional Cash Transfer Program on Household's Fertility
* Decisions in India
* Sayli Javadekar and Kritika Saxena
* 11 Dec 2018
* state cl

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


***self reported ultrasond by state
reghdfe s236 treat##i.b2 strend if rural==1 & b2 <2006 & b2>1990, cl(v024) absorb(v024 b2 bord)
coefplot, drop(_cons) keep(*#*) xline(0) ci(90)


*birth spacing
sort caseid bord
bysort caseid  : gen birth_space = b2[_n+1]-b2

/*families with first birth after 2000*/

bys UID :gen tempo=1 if b2>=2000 & bord==1
replace tempo=0 if tempo==.
bys UID :egen mtempo=max(tempo) 

bys UID :gen p05 =1 if b2 >2005 & b2<=2010 
replace p05=2 if b2>2010 & b2<=2015
replace p05 =0 if b2>=2000 & b2<=2005

gen hh_sex=1 if v151==1
replace hh_sex=0 if hh_sex==.
gen elec=1 if v119==1
replace elec=0 if elec==.
** descriptive stats
sum fg v133 i.v130 i.sh36 v138 hh_sex v152  s190rs elec v120 v121 v122 v123 v124 v125 child_sex v201 if  rural==1 & mtempo==1 & bord==1 & treat==1

sum fg v133 i.v130 i.sh36 v138 hh_sex v152  s190rs elec v120 v121 v122 v123 v124 v125 child_sex v201 if  rural==1 & mtempo==1 & bord==1 & treat==0

**** treat not different - 31st Aug2019
/*generate an indicator if the mother used ultasound or not. This is done
 because the regr you run below has bord==1 so u want an indicator for ultrasound usage in the reg*/

gen sh36_=sh36
replace sh36=4 if sh36_==8


bys UID : gen pg=sum(child_sex)
bys UID : egen pgm=max(pg)
*order UID child_sex pgm pg bord
bys UID : gen propg=pgm/v201

gen fcaste=1 if sc_st==0
replace fcaste=0 if fcaste==.
	
reghdfe treat propg v133 i.v130 fcaste v138 hh_sex v152  s190rs elec v120 v121 v122 v123 v124 v125 v201 s236  if  rural==1 & mtempo==1 & bord==1 ,  cl( v024) absorb( b2 )
eststo tr1
coefplot (tr1,  drop(strend)), levels( 95) vertical yline(0) xlabel(,angle(90)) msymbol(S) coeflabels(fcaste= "forward caste, obc" v133="mother's education" v138 = "no of women in hh" hh_sex= "sex of hh head" v152="age of hh head" s190rs="wealth index" elec="elec" v120="radio" v121="tv" v122="refri" v123="cycle" v124="scooter" v125="truck" v201="tot chil" s236="ultrasound usage" propg ="prop of girl births") ytitle(Coefficient) graphregion(fcolor(white)) title(`"Test of balance between treatment and control"')




/*
sum v024
local max = r(max)
local min = r(min)

forval c = `min'/`max' {
gen st_`c' = 1 if v024==`c'
replace st_`c' = 0 if v024 !=`c'
}


gen y = 1 if b2==2000
replace y = 2 if b2==2002
replace y = 3 if b2==2003
replace y = 4 if b2==2004
replace y = 5 if b2==2005
replace y = 6 if b2==2006
replace y = 7 if b2==2007
replace y = 8 if b2==2008
replace y = 9 if b2==2009
replace y = 10 if b2==2010
replace y = 11 if b2==2011
replace y = 12 if b2==2012
replace y = 13 if b2==2013
replace y = 14 if b2==2014
replace y = 15 if b2==2015

gen staye=v024*10+y
*/
****Fg random or not (Bhalotra Style)

reghdfe fg v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125  if  rural==1 & b2>=2000 & b2 <=2005 & bord==1 & treat!=.  & bpl==0,  cl( v024) absorb( b2  v024)
eststo fg1
*title(`"Test of balance by the sex of the first born"')
coefplot (fg1), levels( 95) vertical yline(0) xlabel(,angle(90)) msymbol(S) coeflabels(v133="mother's education" v138 = "no of Women in hh" v151= "sex of hh Head" v152="gge of hh head" s190rs="wealth index" v119="elec" v120="radio" v121="tv" v122="refri" v123="cycle" v124="scooter" v125="truck" ) ytitle(Coefficient) graphregion(fcolor(white)) title(`"Test of balance by the sex of the first born"')




reghdfe fg v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 treat strend  if  rural==1 & b2>=1990 & b2 <2000 & bord==1 & treat!=.  & bpl==0,  cl( v024) absorb( b2  v024)
eststo fg11

esttab  fg11 fg1 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex of first child) tex

reghdfe fg i.p05 strend if rural==1 & bord==1 & mtempo==1 & treat!=., cl(v024) absorb(   v024 )
eststo fg2

esttab  fg2 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex of first child of Post variable) tex

**** treat not different -old, updated on 31st Aug 2019 see above 

reghdfe lps v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 bpl s236 strend  if  rural==1 & b2>=2000 & b2 <=2005 & bord==1 ,  cl( v024) absorb( b2  )
eststo lpsdiff

*title(`"Test of balance by Treatment"')
coefplot (lpsdiff,  drop(strend)), levels( 95) vertical yline(0) xlabel(,angle(90)) msymbol(S) coeflabels(v133="Mother's education" v138 = "no of women in hh" v151= "sex of hh head" v152="age of hh head" s190rs="wealth index" v119="elec" v120="radio" v121="tv" v122="refri" v123="cycle" v124="scooter" v125="truck" s236="ultrasound use" bpl="bpl") 


***self reported ultrasond by state
reghdfe s236 treat##i.b2 strend if rural==1 & b2 <2006 & b2>1990, cl(v024) absorb(v024 b2 bord)
eststo ust
esttab ust,varwidth(25)
*title(`" Test of differential coefficients for Self Reported Ultrasound Usage by LPS/HPS"')
coefplot (ust, keep(*#* ) drop(strend)), levels(95) vertical yline(0) xlabel(,angle(90)) msymbol(S)  coeflabels(1.treat#1990.b2="1990" 1.treat#1991.b2="1991" 1.treat#1992.b2="1992" 1.treat#1993.b2="1993" 1.treat#1994.b2="1994" 1.treat#1995.b2="1995" 1.treat#1996.b2="1996"1.treat#1997.b2="1997" 1.treat#1998.b2="1998" 1.treat#1999.b2="1999" 1.treat#2000.b2="2000" 1.treat#2001.b2="2001" 1.treat#2002.b2="2002" 1.treat#2003.b2="2003" 1.treat#2004.b2="2004" 1.treat#2005.b2="2005" 1.treat#2006.b2="2006")

* Impact on sex selection
//Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups in all India and rural India
*First with cohorts of 10 - 15 years compared to 5-10 years
* Second with cohorts of 10 - 15 years compared to 0-5 years
* Third with 2000-2005, 2005>
***** Both estimations together

** state cl
reghdfe child_sex treat##i.p05 strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo r1
test _b[1.treat#1.p05]=_b[1.treat#2.p05]
*F(  1,    34) =    5.82     Prob > F =    0.0214

reghdfe child_sex treat##post strend  if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
est store Rural

*bord>1, bord>2
reghdfe child_sex treat##i.p05 strend  if  rural==1 & mtempo==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
eststo r11
reghdfe child_sex treat##post strend  if  rural==1 & mtempo==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
eststo Rural1

reghdfe child_sex treat##i.p05 strend  if  rural==1 & mtempo==1& bord>2,  cl( v024) absorb(UID b2 bord v024)
eststo r12
reghdfe child_sex treat##post strend  if  rural==1 & mtempo==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
eststo Rural2

esttab  r1 Rural r11 Rural1 r12 Rural2, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


**birth spacing state cl

reghdfe birth_space treat##i.p05##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b1
reghdfe birth_space treat##post##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b3

esttab  b1  b3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex

**birth spacing state cl-kritika

reghdfe b12 treat##i.p05##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b1k

reghdfe b12 treat##post##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b3k

esttab  b1k  b3k, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex







**Robustness
*state cl
reghdfe child_sex treat##i.b2   if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo robs

*esttab   robs, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robutness) tex

* Ftest
*matrix list e(b) return coeff
 test _b[1.treat#2001.b2]=_b[1.treat#2002.b2]=_b[1.treat#2003.b2]=_b[1.treat#2004.b2]=_b[1.treat#2005.b2]=0
 
 
*triple diff
** state cl
reghdfe child_sex treat##i.p05##fg strend  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo r1f
test _b[1.treat#1.p05#1.fg]=_b[1.treat#2.p05#1.fg]
*F(  1,    34) =    6.64      Prob > F =    0.0145

reghdfe child_sex treat##post##fg strend  if rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
est store Ruralf
esttab  r1f Ruralf , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex



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
reghdfe dead7 treat##i.p05##child_sex strend if rural==1 & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo iq1
reghdfe dead7 treat##post##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo iq3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##i.p05##child_sex strend if rural==1 & mtempo==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo jq1
reghdfe dead28 treat##post##child_sex strend if rural==1  & mtempo==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo jq3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##i.p05##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo kq1
reghdfe dead1 treat##post##child_sex strend if rural==1   & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo kq3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##i.p05##child_sex strend if rural==1  & mtempo==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo nq1
reghdfe dead3 treat##post##child_sex strend if rural==1   & mtempo==1 , cl(v024) absorb(  bord b2 UID  v024)
eststo nq3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo mq1
reghdfe dead5 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID  v024)
eststo mq3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex




*state cl bord >1

* 7 days
reghdfe dead7 treat##i.p05##child_sex strend if rural==1 & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo i1
reghdfe dead7 treat##post##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo i3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##i.p05##child_sex strend if rural==1 & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo j1
reghdfe dead28 treat##post##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo j3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo k1
reghdfe dead1 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo k3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo n1
reghdfe dead3 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID  v024)
eststo n3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID v024 )
eststo m1
reghdfe dead5 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(  bord b2 UID  v024)
eststo m3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex

esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex
esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex
esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex
esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex
esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex



** state cl bord>2

reghdfe dead7 treat##i.p05##child_sex strend if rural==1 & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ii1
reghdfe dead7 treat##post##child_sex strend if rural==1  & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ii3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##i.p05##child_sex strend if rural==1 & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ji1
reghdfe dead28 treat##post##child_sex strend if rural==1  & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ji3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ki1
reghdfe dead1 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ki3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo ni1
reghdfe dead3 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID  v024)
eststo ni3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##i.p05##child_sex strend if rural==1  & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID v024 )
eststo mi1
reghdfe dead5 treat##post##child_sex strend if rural==1   & mtempo==1 & bord>2, cl(v024) absorb(  bord b2 UID  v024)
eststo mi3

esttab  ii1  ii3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex
esttab  ji1  ji3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex
esttab  ki1  ki3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex
esttab  ni1  ni3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex
esttab  mi1  mi3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex



***all mortality Latek

esttab  iq1  iq3  i1  i3 ii1  ii3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex
esttab  jq1  jq3 j1  j3 ji1  ji3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex
esttab  kq1  kq3 k1  k3  ki1  ki3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex
esttab  nq1  nq3  n1  n3 ni1  ni3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex
esttab  mq1  mq3 m1  m3 mi1  mi3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex








/***fertility: no of kids born to the mother in each time bracket

gen r=1
bys UID: egen q=sum(r) if b2>2005 & b2<=2010
bys UID: egen q1=sum(r) if b2>2010 
bys UID: egen q2=sum(r) if b2>=2000 & b2<=2005

bys UID: gen fe=q if mtempo==1
replace fe=q1 if fe==. & mtempo==1
replace fe=q2 if fe==. & mtempo==1

* fe is the number of kids born in 3 time brackets 2000-2005, 2006-2010, 2011-2015
reghdfe fe treat##i.p05 strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
estso fe
esttab  fe , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Number of children born) tex


* sibs is the number of siblings every child has
bys UID: gen sibs= fe-r if mtempo==1
reghdfe sibs treat##i.p05##child_sex strend  if  rural==1 & mtempo==1 ,  cl( v024) absorb(UID b2 bord v024)
estso sibs
esttab  sibs , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Number of siblings) tex


*/


*** pre jsy mortality that worked

*****
reghdfe dead5 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre5
reghdfe dead3 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre3
reghdfe dead1 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre1
reghdfe dead28 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre28
reghdfe dead7 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre7



reghdfe dead5 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre5
test _b[1.treat#2001.b2#1.child_sex]=_b[1.treat#2002.b2#1.child_sex]=_b[1.treat#2003.b2#1.child_sex]=_b[1.treat#2004.b2#1.child_sex]=_b[1.treat#2005.b2#1.child_sex]=0
* F(  5,    34) =    1.63            Prob > F =    0.1774

local coefinter 1.treat#2001.b2#1.child_sex 1.treat#2002.b2#1.child_sex 1.treat#2003.b2#1.child_sex 1.treat#2004.b2#1.child_sex 1.treat#2005.b2#1.child_sex 1.treat#2005.b2#1.child_sex
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.child_sex="2001" 1.treat#2002.b2#1.child_sex="2002" 1.treat#2003.b2#1.child_sex="2003" 1.treat#2004.b2#1.child_sex="2004" 1.treat#2005.b2#1.child_sex="2005"1.treat#2006.b2#1.child_sex="2006")title(`"Under 5 infant Mortality Pretrends"')

reghdfe dead3 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre3
test _b[1.treat#2001.b2#1.child_sex]=_b[1.treat#2002.b2#1.child_sex]=_b[1.treat#2003.b2#1.child_sex]=_b[1.treat#2004.b2#1.child_sex]=_b[1.treat#2005.b2#1.child_sex]=0
*F(  5,    34) =    1.99 Prob > F =    0.1045
local coefinter 1.treat#2001.b2#1.child_sex 1.treat#2002.b2#1.child_sex 1.treat#2003.b2#1.child_sex 1.treat#2004.b2#1.child_sex 1.treat#2005.b2#1.child_sex 1.treat#2005.b2#1.child_sex
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.child_sex="2001" 1.treat#2002.b2#1.child_sex="2002" 1.treat#2003.b2#1.child_sex="2003" 1.treat#2004.b2#1.child_sex="2004" 1.treat#2005.b2#1.child_sex="2005"1.treat#2006.b2#1.child_sex="2006") title(`"Under 3 infant Mortality Pretrends"')

reghdfe dead1 treat##i.b2##child_sex strend if rural==1  & mtempo==1 & b2<=2006, cl(v024) absorb(  bord b2 UID v024 )
eststo pre1
local coefinter 1.treat#2001.b2#1.child_sex 1.treat#2002.b2#1.child_sex 1.treat#2003.b2#1.child_sex 1.treat#2004.b2#1.child_sex 1.treat#2005.b2#1.child_sex 1.treat#2005.b2#1.child_sex
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.child_sex="2001" 1.treat#2002.b2#1.child_sex="2002" 1.treat#2003.b2#1.child_sex="2003" 1.treat#2004.b2#1.child_sex="2004" 1.treat#2005.b2#1.child_sex="2005"1.treat#2006.b2#1.child_sex="2006") title(`"Under 1 infant Mortality Pretrends"')


*coefplot (pre3, label(U3M) keep(`coefinter') drop(strend))(pre5, label(U5M) keep(`coefinter') drop(strend)), vertical yline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2000.b2#1.child_sex="2000" 1.treat#2001.b2#1.child_sex="2001" 1.treat#2002#1.child_sex="2002" 1.treat#2003.b2#1.child_sex="2003" 1.treat#2004.b2#1.child_sex="2004" 1.treat#2005.b2#1.child_sex="2005"1.treat#2006.b2#1.child_sex="2006")



**this works non differentila pre-trends 
reghdfe dead5 treat##i.b2##child_sex strend if rural==1  & b2>=1999 & b2<=2005, cl(v024) absorb(  bord b2 UID v024 )
eststo pre5
reghdfe dead3 treat##i.b2##child_sex strend if rural==1  & b2>=1999 & b2<=2005, cl(v024) absorb(  bord b2 UID v024 )
eststo pre3
reghdfe dead1 treat##i.b2##child_sex strend if rural==1  & b2>=1999 & b2<=2005, cl(v024) absorb(  bord b2 UID v024 )
eststo pre1
reghdfe dead28 treat##i.b2##child_sex strend if rural==1  & b2>=1999 & b2<=2005, cl(v024) absorb(  bord b2 UID v024 )
eststo pre28
reghdfe dead7 treat##i.b2##child_sex strend if rural==1  & b2>=1999 & b2<=2005, cl(v024) absorb(  bord b2 UID v024 )
eststo pre7






****************************************************


reghdfe child_sex treat##post##sv270rs rural==1  & mtempo==1 & bord==1, cl(v024) absorb(  bord b2  v024 )

