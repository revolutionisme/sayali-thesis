
clear*
set more off

log using "C:\Users\ssj18\Documents\DHS\dhs_rain.txt",replace
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

order UID v024 sdistri b2 bord 
/*families with first birth after 2000*/

bys UID :gen tempo=1 if b2>=2000 & bord==1
replace tempo=0 if tempo==.
bys UID :egen mtempo=max(tempo) 

bys UID :gen p05 =1 if b2 >2005 & b2<=2010 
replace p05=2 if b2>2010 & b2<=2015
replace p05 =0 if b2>=2000 & b2<=2005

*keep  UID v024 sdistri b2 bord mtempo
drop if mtempo==0

gen dist_dhs=sdistri
sort dist_dhs b2

egen UID_m  = concat(dist_dhs b2)
destring UID_m, replace


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
/*under5
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


*birth spacing
sort caseid bord
bysort caseid  : gen birth_space = b2[_n+1]-b2


** descriptive stats
sum fg v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 child_sex  if  rural==1 & mtempo==1 & bord==1 & treat==1

*decode(sdistri), gen(distr)
*replace distr=upper(distr)
*encode(distr), gen(dist_dhs)
*format %35.0g dist_dhs


*keep UID v024 sdistri dist_dhs b2 bord child_sex treat post p05 lps rural v133 v130 sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 mtempo b6 b11 b12
*/
drop if mtempo==0
order UID v024 sdistri b2 bord child_sex
sort UID

merge m:m v024 using "C:\Users\ssj18\Documents\DHS\state_nss_mpce_1112.dta",gen(m2)
keep if m2==3

gen mpcer=mpcemmrprural

xi: areg child_sex c.mpcer##treat strend  bord v024,cl(v024) absorb(b2 )

*benefit is how many times mpcer or the share of the benefir in the mpcer
gen share=1400/mpcer if lps==1 & rural==1
replace share=1000/mpcer if lps==0 & rural==1



xi: areg child_sex c.share##treat##post strend v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 i.bord i.v024 strend if mtempo==1 & rural==1 ,cl(v024) absorb(b2 )
eststo reg

xi: areg child_sex sv270r##treat##post strend v133 i.v130 i.sh36 v138 v151 v152  s190rs v119 v120 v121 v122 v123 v124 v125 i.bord i.v024 strend if mtempo==1 & rural==1 ,cl(v024) absorb(b2 )
eststo regwealth


xi: areg child_sex sv270r##treat##post strend i.bord i.b2 strend if mtempo==1 & rural==1 ,cl(v024) absorb(UID )
eststo regw
	
esttab regw ,  replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact by wealth indices) varwidth(55) tex

	
*** excluding the people registered as poor and poorest in the wealth index	
gen tp=1 if lps==1 & sc_st==0 & sv270r!=1 & sv270r!=2 & bpl==0
replace tp=0 if lps==0 & sc_st==0 & sv270r!=1 & sv270r!=2 & bpl==0


reghdfe child_sex tp##post strend   if mtempo==1 & rural==1 ,cl(v024) absorb(UID bord b2)
eststo regtp

reghdfe child_sex tp##post##fg strend   if mtempo==1 & rural==1 ,cl(v024) absorb(UID bord b2)
eststo regtpfg


areg child_sex treat##i.b2##fg strend  i.b2 i.bord if mtempo==1 & rural==1 ,cl(v024) absorb(UID )

 
/*


reghdfe child_sex c.share##treat##post strend  if mtempo==1 & rural==1 ,cl(v024) absorb(b2 UID bord)



reghdfe child_sex c.share##fg##treat strend  if mtempo==1 & rural==1 & post==1 & bord>1,cl(v024) absorb(b2 UID bord)

*/


