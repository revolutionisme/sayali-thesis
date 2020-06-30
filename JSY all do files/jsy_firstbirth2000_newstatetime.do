*******************************************************************************
* The Impact of a Conditional Cash Transfer Program on Household's Fertility
* Decisions in India
* Sayli Javadekar and Kritika Saxena
* 11 Dec 2018
* state cl

clear*
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


bys UID :gen post05 =1 if b2 >2005 & b2<=2010 
replace post05 =0 if b2>=2000 & b2<=2005

gen p5=1 if b2>2010 & b2<=2015
replace p5=0 if b2>=2000 & b2<=2005

bys UID :gen post =1 if b2 >2005 & b2<=2015
replace post =0 if b2>=2000 & b2<=2005



/*families with first birth after 2000*/

bys UID :gen tempo=1 if b2>=2000 & bord==1
replace tempo=0 if tempo==.
bys UID :egen mtempo=max(tempo) 

bys UID :gen p05 =1 if b2 >2005 & b2<=2010 
replace p05=2 if b2>2010 & b2<=2015
replace p05 =0 if b2>=2000 & b2<=2005

gen state_yob= (v024*10000)+ b2
bys v024 b2: gen dupst=cond(_N==1,0,_n)

bys UID :gen p05_ =1 if b2 >=2005 & b2<=2010 
replace p05_=2 if b2>2010 & b2<=2015
replace p05_ =0 if b2>=2000 & b2<=2005

save "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",replace



use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear
set more off

drop post 
bys UID :gen post =1 if b2 >2005 & b2<=2015
replace post =0 if b2>=2000 & b2<=2005
save "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",replace

log using "C:\Users\ssj18\Documents\DHS\state_time_trend.log",replace
**did

reg child_sex treat##i.p05   if  rural==1 & mtempo==1,  cl( state_yob) 
eststo g1

areg child_sex treat##i.p05  if  rural==1 & mtempo==1,  cl( state_yob) absorb(v024 )


*reghdfe child_sex treat##i.p05  if  rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
eststo g2

areg child_sex treat##i.p05 i.bord i.b2  if  rural==1 & mtempo==1,  cl( state_yob) absorb(v024 )
eststo g3

areg child_sex treat##i.p05 i.v024##c.b2 i.bord  if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )

*reghdfe child_sex treat##i.p05 i.v024#c.b2  if  rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
eststo g4

areg child_sex treat##i.p05 i.v024##c.b2 i.bord  if  rural==1 & mtempo==1,  cl( v024) absorb(UID )
eststo g5

*reghdfe child_sex treat##post i.v024#c.b2  if rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
*est store Rural

**triple

reg child_sex treat##i.p05##fg   if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) 
eststo r1

areg child_sex treat##i.p05##fg   if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(v024 )
eststo r2

areg child_sex treat##i.p05##fg i.bord i.b2  if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(v024 )
eststo r3

areg child_sex treat##i.p05##fg  i.bord i.b2 if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(UID )
eststo r4

areg child_sex treat##i.p05##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(UID )
eststo r5


***#####****
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID bord b2 )
eststo r6

areg child_sex treat##i.p05##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID )
eststo r7




******* triple diff
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID bord b2 )
eststo r6

*st -fe
egen st_year = group(v024 b2)
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo stfe_trip

* st -trend
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID i.v024#c.b2 b2 bord )
eststo stfe_trip_trial

areg child_sex treat##i.p05##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID  )
eststo sttr_trip

*____

reghdfe child_sex treat##i.post##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID bord b2 )
eststo r6_

*st -fe
reghdfe child_sex treat##i.post##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo stfe_trip_

* st -trend
reghdfe child_sex treat##i.post##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID i.v024#c.b2 b2 bord )
eststo stfe_trip_trial_

areg child_sex treat##i.post##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID  )
eststo sttr_trip_

*******


*reghdfe child_sex treat##i.p05##fg i.v024#c.b2  if  rural==1 & bord>=2 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)

*reghdfe child_sex treat##post##fg i.v024#c.b2  if rural==1 & bord>=2 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
*est store Ruralf


**robustness

areg child_sex treat##i.b2 i.v024 i.b2 i.bord if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )
eststo robs

*esttab robs, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robutness) tex

* Ftest
*matrix list e(b) return coeff
 test _b[1.treat#2001.b2]=_b[1.treat#2002.b2]=_b[1.treat#2003.b2]=_b[1.treat#2004.b2]=_b[1.treat#2005.b2]=0
 
**
areg child_sex treat##i.b2##fg i.v024##c.b2  i.bord if  rural==1 & mtempo==1 & bord>=2,  cl( state_yob) absorb(UID )
eststo robsf

*esttab   robsf, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robutness) tex
 
 
 
*areg child_sex treat##i.b2 if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )
*predict fit,xb 
 
 
areg child_sex treat##i.b2##fg if  rural==1 & mtempo==1 & bord>=2,  cl( state_yob) absorb(UID )

areg child_sex treat##i.b2##fg if  rural==1 & mtempo==1 & bord>=2,  cl( v024) absorb(UID )

areg child_sex treat##i.b2##fg i.v024#c.b2 if  rural==1 & mtempo==1 & bord>=2,  cl( state_yob) absorb(UID )
eststo rob_triplest
log close 

areg child_sex treat##i.p05##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord v012 v152 v212 v605 v621 v116 if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(sdistri)
areg child_sex treat##i.p05##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(v021 )







reg child_sex treat##i.p05##fg  if  rural==1 & bord>1 & mtempo==1,  cl( state_yob)

reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(v024 b2)


areg child_sex treat##i.p05##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord v012 v212 v605 v116 if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(v021)

areg child_sex treat##i.post##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord v012 v212 v605 v116 if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(v021)


areg child_sex treat##i.p05##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord v012 v212 v605 v116 if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(UID)

areg child_sex treat##i.post##fg  v133  i.sh36 i.v130 i.v119 i.v120 i.v121 i.v122 i.v123 i.v124 i.v125 v137 v138 i.v150 i.v151 v152 i.v024##c.b2 i.b2 i.bord v012 v212 v605 v116 if  rural==1 & bord>1 & mtempo==1,  cl( state_yob) absorb(UID)








*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************
*****************************************************************************************************************








log using "C:\Users\ssj18\Documents\DHS\state_time_trend_new05.log",replace
**did

areg child_sex treat##i.p05_  i.bord  if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )

*reghdfe child_sex treat##i.p05  if  rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
eststo r1


areg child_sex treat##i.p05_ i.v024##c.b2 i.bord  if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )

*reghdfe child_sex treat##i.p05 i.v024#c.b2  if  rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
eststo r1wst


*reghdfe child_sex treat##post i.v024#c.b2  if rural==1 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
*est store Rural

**triple

areg child_sex treat##i.p05_##fg  i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(UID )
eststo r1f


areg child_sex treat##i.p05_##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( state_yob) absorb(UID )
eststo r1fst


*reghdfe child_sex treat##i.p05_##fg i.v024#c.b2  if  rural==1 & bord>=2 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)

*reghdfe child_sex treat##post##fg i.v024#c.b2  if rural==1 & bord>=2 & mtempo==1,  cl( v024#b2) absorb(UID b2 bord v024)
*est store Ruralf


**robustness

areg child_sex treat##i.b2 i.v024 i.b2 i.bord if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )
eststo robs

*esttab robs, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robutness) tex

* Ftest
*matrix list e(b) return coeff
 test _b[1.treat#2001.b2]=_b[1.treat#2002.b2]=_b[1.treat#2003.b2]=_b[1.treat#2004.b2]=_b[1.treat#2005.b2]=0
 
**
areg child_sex treat##i.b2##fg i.v024##c.b2  i.bord if  rural==1 & mtempo==1 & bord>2,  cl( state_yob) absorb(UID )
eststo robsf

*esttab   robsf, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robutness) tex
 
 
 
areg child_sex treat##i.b2 if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )
predict fit1,xb 
 
 
areg child_sex treat##i.b2##fg if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )

areg child_sex treat##i.b2##fg if  rural==1 & mtempo==1,  cl( v024) absorb(UID )

areg child_sex treat##i.b2##fg i.v024#c.b2 if  rural==1 & mtempo==1,  cl( state_yob) absorb(UID )
eststo rob_triplest
log close 





******************************************************Mortality******************************************************************

* In this section we estimate the impact of the program on mortality of the children, given by perinatal (7days)
* neonatal (28 days), infant (1 year) and under 5 (5 years) mortality.

*********************************************************************************************************************************


use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear
set more off

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

log using "C:\Users\ssj18\Documents\DHS\state_time_trend_MORTALITY.log",replace



*state cl 

* 7 days
areg dead7 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 , cl(state_yob) absorb( UID  )
eststo iq1
 areg dead7 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 ,  cl(state_yob) absorb( UID  )
eststo iq3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1 & mtempo==1  , cl(state_yob) absorb( UID  )
eststo jq1
 areg dead28 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1  , cl(state_yob) absorb( UID  )
eststo jq3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 , cl(state_yob) absorb( UID  )
eststo kq1
 areg dead1 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 , cl(state_yob) absorb( UID  )
eststo kq3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 , cl(state_yob) absorb( UID  )
eststo nq1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 , cl(state_yob) absorb( UID  )
eststo nq3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo mq1
 areg dead5 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo mq3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex




*state cl bord >1

* 7 days
 areg dead7 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo i1
 areg dead7 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo i3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo j1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo j3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo k1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo k3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo n1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(   UID  )
eststo n3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1, cl(state_yob) absorb( UID  )
eststo m1
 areg dead5 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1, cl(v024) absorb(   UID  )
eststo m3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex


** state cl bord>2

 areg dead7 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1 & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ii1
 areg dead7 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ii3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ji1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ji3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ki1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ki3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo ni1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>2, cl(v024) absorb(   UID  )
eststo ni3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo mi1
 areg dead5 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2, cl(state_yob) absorb( UID  )
eststo mi3





log close










******************************************
******* mortality for first girl families only
******************************************


use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear
set more off

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

log using "C:\Users\ssj18\Documents\DHS\state_time_trend_MORTALITY_firstgirl.log",replace






*state cl bord >1

* 7 days
 areg dead7 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo i1
 areg dead7 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo i3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo j1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo j3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo k1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo k3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo n1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(   UID  )
eststo n3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1 & fg==1, cl(state_yob) absorb( UID  )
eststo m1
 areg dead5 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb( UID )
eststo m3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex


** state cl bord>2

 areg dead7 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1 & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ii1
 areg dead7 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ii3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ji1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ji3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ki1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ki3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo ni1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  UID  )
eststo ni3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo mi1
 areg dead5 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(state_yob) absorb( UID  )
eststo mi3





log close






******************************************
******* mortality for first boy families only
******************************************


use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear
set more off

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

log using "C:\Users\ssj18\Documents\DHS\state_time_trend_MORTALITY_firstboy.log",replace






*state cl bord >1

* 7 days
 areg dead7 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1 & fg ==0, cl(state_yob) absorb( UID  )
eststo i1
 areg dead7 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo i3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo j1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo j3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo k1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo k3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo n1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1 &  fg==0, cl(v024) absorb(   UID  )
eststo n3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>1 &  fg==0, cl(state_yob) absorb( UID  )
eststo m1
 areg dead5 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>1 &  fg==0, cl(v024) absorb(  UID  )
eststo m3
*esttab  m1  m3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 5 years) tex


** state cl bord>2

 areg dead7 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1 & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ii1
 areg dead7 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ii3
*esttab  i1  i3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 7 days) tex

* 28 days
 areg dead28 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1 & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ji1
 areg dead28 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ji3
*esttab  j1  j3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 28 days) tex

* 1 year
 areg dead1 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ki1
 areg dead1 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ki3
*esttab  k1  k3  , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 1 year) tex

*Under 3
 areg dead3 treat##i.p05##child_sex  i.v024##c.b2 i.bord if rural==1  & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo ni1
 areg dead3 treat##post##child_sex  i.v024##c.b2 i.bord if rural==1   & mtempo==1 & bord>2 &  fg==0, cl(v024) absorb(   UID  )
eststo ni3
*esttab  n1  n3 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact Mortality under 3 years) tex

*Under 5
 areg dead5 treat##i.p05##child_sex i.v024##c.b2 i.bord  if rural==1  & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo mi1
 areg dead5 treat##post##child_sex i.v024##c.b2 i.bord  if rural==1   & mtempo==1 & bord>2 &  fg==0, cl(state_yob) absorb( UID  )
eststo mi3





log close

*****birth interval

**birth spacing state cl

/*
reghdfe birth_space treat##i.p05##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b1
reghdfe birth_space treat##post##child_sex strend  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo b3

esttab  b1  b3, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex
*/
**birth spacing state cl-kritika
egen st_year = group(v024 b2)


reghdfe b12 treat##post##child_sex   if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024 st_year)
eststo b3k

reghdfe b12 treat##post##child_sex   if  rural==1 & mtempo==1 & fg==1,  cl( v024) absorb(UID b2 bord v024 st_year)
eststo b3kg

reghdfe b12 treat##post##child_sex   if  rural==1 & mtempo==1 & fg==0,  cl( v024) absorb(UID b2 bord v024 st_year)
eststo b3kb


esttab  b3k b3kg b3kb, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on Birth Spacing) tex




