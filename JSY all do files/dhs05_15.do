


use "C:\Users\ssj18\Documents\DHS\birth.DTA" ,clear
gen hv001=v001
gen hv002=v002
merge m:1 hv001 hv002 using hh, gen(_merge1)

save fullmerge,replace
keep if _merge1==3
append using "C:\Users\ssj18\Documents\DHS\IABR42DT\data05_06.dta"

save "C:\Users\ssj18\Documents\DHS\IABR42DT\data5_15.dta",replace



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

 //v007gives year of interview
*gen child_age2 = 2016-b2
 replace child_age =v007-b2 if child_age==.
gen dead =1 if b5==0
replace dead=0 if missing(dead)

gen fg_=1 if bord==1 & child_sex==1/*first child is a girl*/
replace fg_=0 if bord==1 & child_sex==0
bys UID :egen fg=max(fg_)


gen bpl=s66
replace bpl=sh58 if bpl==.



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



bys caseid: gen dup = cond(_N==1,0,_n)
order caseid dup
