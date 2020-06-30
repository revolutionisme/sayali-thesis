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
bysort caseid  : gen birth_space = b2[_n+1]-b2


*** Log file
log using "C:\Users\ssj18\Documents\DHS\28oct2018_bord_fe_state_cl.log", replace

set more off



* Regression 2(state cl): Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups in all India and rural India
*First with cohorts of 10 - 15 years compared to 5-10 years
* Second with cohorts of 10 - 15 years compared to 0-5 years
* Third with 2000-2005, 2005>

  reghdfe child_sex treat##post05 strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
  est store Rural_5_9
  reghdfe child_sex treat##p5 strend  if rural==1,  cl( v024) absorb(UID b2 bord v024)
  est store Rural_0_5
  reghdfe child_sex treat##post strend  if rural==1,  cl( v024) absorb(UID b2 bord v024)
  est store Rural
//for Latex
esttab  Rural_5_9 Rural_0_5 Rural , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex

* Regression 2 (mother cl): Comparing JSY treatment (uppercaste rich in LPS) and control (uppercaste rich in HPS) groups in all India and rural India
*First with cohorts of 10 - 15 years compared to 5-10 years
* Second with cohorts of 10 - 15 years compared to 0-5 years
* Third with 2000-2005, 2005>

  reghdfe child_sex treat##post05 strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
  est store Rural_5_9m
  reghdfe child_sex treat##p5 strend  if rural==1,  cl( UID) absorb(UID b2 bord v024)
  est store Rural_0_5m
  reghdfe child_sex treat##post strend  if rural==1,  cl( UID) absorb(UID b2 bord v024)
  est store Ruralm
//for Latex
esttab  Rural_5_9m Rural_0_5m Ruralm , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


***** Both estimations together

bys UID :gen p05 =1 if b2 >2005 & b2<=2010 
replace p05=2 if b2>2010 & b2<=2015
replace p05 =0 if b2>=2000 & b2<=2005


** state cl
reghdfe child_sex treat##i.p05 strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo r1
reghdfe child_sex treat##post strend  if rural==1,  cl( v024) absorb(UID b2 bord v024)
est store Rural
esttab  r1 Rural , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex

** mother cl
reghdfe child_sex treat##i.p05 strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo r2
reghdfe child_sex treat##post strend  if rural==1,  cl( UID) absorb(UID b2 bord v024)
est store Ruralm
esttab  r2 Ruralm , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex

***** falsification not working!

bys UID :gen f05 =2 if b2 >=2000 & b2<2005
replace f05=1 if b2>1995 & b2<2000
replace f05 =0 if b2>1990 & b2<=1995

bys UID :gen ff05 =2 if b2 >=2000 & b2<2005
replace ff05=0 if b2>1995 & b2<2000

bys UID :gen fff05 =2 if b2 >=1995 & b2<2000
replace fff05=0 if b2>1990 & b2<=1995


** state cl
reghdfe child_sex treat##i.f05##fg strend  if  rural==1 & bord>=2,  cl( v024) absorb(UID b2 bord v024)
eststo f1
esttab  f1 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Placebo:Impact on sex selective abortions) tex

** mother cl
reghdfe child_sex treat##i.f05 strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo f2
esttab  f2 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Placebo:Impact on sex selective abortions) tex

 log close

*******
 
 


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
reghdfe dead7 treat##post05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo i1
reghdfe dead7 treat##p5##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo i2
reghdfe dead7 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo i3
esttab  i1 i2 i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##post05##child_sex strend if rural==1 , cl(v024) absorb(  bord b2 UID v024 )
eststo j1
reghdfe dead28 treat##p5##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo j2
reghdfe dead28 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo j3
esttab  j1 j2 j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##post05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo k1
reghdfe dead1 treat##p5##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo k2
reghdfe dead1 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo k3
esttab  k1 k2 k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##post05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo n1
reghdfe dead3 treat##p5##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo n2
reghdfe dead3 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo n3
esttab  n1 n2 n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##post05##child_sex strend if rural==1  , cl(v024) absorb(  bord b2 UID v024 )
eststo m1
reghdfe dead5 treat##p5##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID v024 )
eststo m2
reghdfe dead5 treat##post##child_sex strend if rural==1   , cl(v024) absorb(  bord b2 UID  v024)
eststo m3
esttab  m1 m2 m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex

*mother cl

* 7 days
reghdfe dead7 treat##post05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo i1m
reghdfe dead7 treat##p5##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo i2m
reghdfe dead7 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo i3m
esttab  i1m i2m i3m  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
reghdfe dead28 treat##post05##child_sex strend if rural==1 , cl(UID) absorb(  bord b2 UID v024 )
eststo j1m
reghdfe dead28 treat##p5##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo j2m
reghdfe dead28 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo j3m
esttab  j1m j2m j3m  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
reghdfe dead1 treat##post05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo k1
reghdfe dead1 treat##p5##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo k2
reghdfe dead1 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo k3
esttab  k1 k2 k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
reghdfe dead3 treat##post05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo n1m
reghdfe dead3 treat##p5##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo n2m
reghdfe dead3 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo n3m
esttab  n1m n2m n3m , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
reghdfe dead5 treat##post05##child_sex strend if rural==1  , cl(UID) absorb(  bord b2 UID v024 )
eststo m1m
reghdfe dead5 treat##p5##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID v024 )
eststo m2m
reghdfe dead5 treat##post##child_sex strend if rural==1   , cl(UID) absorb(  bord b2 UID  v024)
eststo m3m
esttab  m1m m2m m3m , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex

**birth spacing mother cl

reghdfe birth_space treat##post05##child_sex strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo b1m

reghdfe birth_space treat##p5##child_sex strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo b2m

reghdfe birth_space treat##post##child_sex strend  if  rural==1,  cl( UID) absorb(UID b2 bord v024)
eststo b3m

esttab  b1m b2m b3m, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex



*************************BIrth Spacing
sort caseid bord
bysort caseid  : gen birth_space = b2[_n+1]-b2


reghdfe birth_space treat##post05##child_sex strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo b1

reghdfe birth_space treat##p5##child_sex strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo b2

reghdfe birth_space treat##post##child_sex strend  if  rural==1,  cl( v024) absorb(UID b2 bord v024)
eststo b3

esttab  b1 b2 b3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex


*************************Fertility
bys caseid: egen mbord=max(bord)
gen temp=1 if bord==1 & b2>2005 /*first child after 2005*/
gen temp1=1 if bord==mbord & b2<=2005 /*last child before 2005*/


replace temp=0 if missing(temp)
replace temp1=0 if missing(temp1)

bys caseid : egen mtemp=max(temp)/*fams with first kid after 2005*/
bys caseid : egen mtemp1=max(temp1)

gen temp1_=1 if mtemp1==1 & bord==1 & b2>=2000
replace temp1_=0 if missing(temp1_)

gen t_=1 if mtemp==1 & bord==mbord & b2<=2010
bys caseid : egen mt_=max(t_)

bys caseid : egen mtemp1_=max(temp1_) /*fams with first kid after 2000 & last kid before 2005*/


gen after=1 if mt_==1
replace after=0 if mtemp1_==1
bys caseid  :  gen dup = cond(_N==1,0,_n)


reghdfe v201 treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=., cl(sdistri) absorb (v024 b2)
eststo fer1

reghdfe v201 treat##after strend  if rural==1 & dup<=1 & after!=., cl(sdistri) absorb (v024 b2)
eststo fer3

esttab  fer3 fer1 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Fertility 2000-2010) tex

*last child
reghdfe child_sex treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=. & bord==mbord, cl(sdistri) absorb (v024)

reghdfe v201 treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=., cl(sdistri) absorb (v024 b2 sdistri)

reghdfe child_sex treat##after strend  if rural==1 & mbord==bord, cl(sdistri) absorb (v024 b2 v021)

reghdfe child_sex treat##post strend  if rural==1 & mbord==bord, cl(sdistri) absorb (v024 b2 v021)
*********************************

reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000 & b2<=2010 & rural==1,  cl( sdistri) absorb(UID b2 bord )

reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000 & b2<=2010 & rural==1,  cl( v024) absorb(UID b2 bord )
reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000  & rural==1,  cl( v024) absorb(UID b2 bord )
reghdfe child_sex treat##p5##i.newbord strend  if   rural==1,  cl( v024) absorb(UID b2 bord )
reghdfe child_sex treat##post_05##i.newbord strend  if  rural==1,  cl( v024) absorb(UID b2 bord )


reghdfe child_sex treat##post05##i.bord strend  if  b2>=2000 & b2<=2010 & rural==1,  cl( UID) absorb(UID b2 bord )


reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000 & b2<=2010 & rural==1,  cl( v024) absorb(UID b2  )
reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000  & rural==1,  cl( v024) absorb(UID b2  )
reghdfe child_sex treat##p5##i.newbord strend  if   rural==1,  cl( v024) absorb(UID b2  )
reghdfe child_sex treat##post_05##i.newbord strend  if  rural==1,  cl( v024) absorb(UID b2  )






reghdfe child_sex treat##post05##i.newbord strend  if  b2>=2000 & b2<=2010 & rural==1 & newbord!=.,  cl( v024) absorb(UID b2  )




reghdfe child_sex treat##post05##i.bord strend  if  b2>=2000 & b2<=2010 & bord==mbord & rural==1 ,  cl( v024) absorb(v024 b2  )



reghdfe child_sex s453a strend  if  b2>=2000  & bord==mbord & rural==1 ,  cl( v024) absorb(v024 b2  )



reghdfe newvar1 treat##post05##child_sex strend  if bord>=2 & b2>=2000 & b2<=2010 & rural==1,  cl( v024) absorb(UID b2 )


reghdfe birth_space treat##post05##child_sex strend  if bord>=2 & b2>=2000 & b2<=2010 & rural==1,  cl( v024) absorb(UID b2 bord )

reghdfe birth_space treat##p5##child_sex strend  if  bord>=2  & rural==1,  cl( v024) absorb(UID b2 bord )


reghdfe birth_space treat##post05##child_sex strend  if bord>=2 & b2>=2000 & b2<=2010 & rural==1,  cl( v024) absorb(UID b2  )

reghdfe birth_space treat##p5##child_sex strend  if  bord>=2  & rural==1,  cl( v024) absorb(UID b2  )






reghdfe newvar1 treat##post05##child_sex strend  if b2>=2000 & rural==1,  cl( v024) absorb(UID b2 bord)


reghdfe child_sex treat##post05 strend  if  b2>=2000 & b2<=2010 & last2!=. & rural==1 ,  cl( v024) absorb(UID  b2 bord )


reghdfe child_sex treat##post05##i.l2 strend  if  b2>=2000 & b2<=2010 & last2!=. & rural==1 ,  cl( v024) absorb(UID  b2 bord )


reghdfe child_sex treat##post05 v133 s190rs i.sh36 v138 v212 i.v130 strend  if  b2>=2000 & b2<=2010 & l2==1 & rural==1 ,  cl( v024) absorb(  b2 bord )




********************





gen temp=1 if bord==1 & b2>2005
gen temp1=1 if bord==mbord & b2<=2005 




replace temp=0 if missing(temp)
replace temp1=0 if missing(temp1)


bys caseid : egen mtemp=max(temp)/*fams with first kid after 2005*/
bys caseid : egen mtemp1=max(temp1)

gen temp1_=1 if mtemp1==1 & bord==1 & b2>=2000

replace temp1_=0 if missing(temp1_)

bys caseid : egen mtemp1_=max(temp1_) /*fams with first kid after 2000 & last kid before 2005*/


gen after=1 if mtemp1==1
replace after=0 if mtemp1_==1
bys caseid  :  gen dup = cond(_N==1,0,_n)

reghdfe v201 treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=., cl(sdistri) absorb (v024)
eststo fer1
reghdfe v201 treat##after strend  if rural==1 & dup<=1 & after!=., cl(v024) absorb (v021)
eststo fer2

*last child
reghdfe child_sex treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=. & bord==mbord, cl(sdistri) absorb (v024)

reghdfe v201 treat##after strend v133 s190rs i.sh36 v138 v212 i.v130 if rural==1 & dup<=1 & after!=., cl(sdistri) absorb (v024 b2 sdistri)


***

gen a1=1 if b2>2005 & b2<=2010
replace a1=0 if b2>=2000 & b2<=2005

gen a2=1 if b2>2010 
replace a2=0 if b2>=2000 & b2<=2010

gen ta1=treat*a1
gen ta2=treat*a2

reghdfe child_sex treat ta1 ta2 a1 strend  if  rural==1 ,  cl( v024) absorb(UID b2 bord v024)


***********


reghdfe child_sex treat##post05 strend  if  rural==1 & b2>=1995,  cl( v024) absorb(UID b2 bord v024)

reghdfe child_sex treat##i.b2 strend  if  rural==1 & b2>=1995,  cl( v024) absorb(UID b2 bord )

reghdfe child_sex treat##post05 strend  if  rural==1 & b2>=1995 & bord>=2,  cl( v024) absorb(UID b2 bord v024)


*************

//MAPS


gen pub=1 if m15>=21 & m15<=27 & rural==1
*bys sdistri b2 : gen sp= sum(pub)
bys v024 b2 : gen stp= sum(pub) if rural==1
bys v024 b2 : egen mstp= max(stp) if rural==1


bys v024 b2 : gen stjsy= sum(s453a) if rural==1
bys v024 b2 : egen mstjsy= max(stjsy) if rural==1
bys v024 b2: gen dupst=cond(_N==1,0,_n) if rural==1

bys v024 b2 : gen jsy_prop= mstjsy*100/mstp if rural==1

br lps v024 b2 mstp mstjsy jsy_prop dupst if dupst<=1 & b2>=2010




//


