

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
/*
bys UID :gen temp1=1 if b2>=1990 & bord==1
replace temp1=0 if temp1==.
bys UID :egen mtemp1=max(temp1) 

bys UID :gen k1 =1 if b2 >1990 & b2<=1990+5
replace k1 =0 if b2>=1990-5 & b2<=1990


reghdfe child_sex treat##k1 strend  if  rural==1 & mtemp1==1,  cl( v024) absorb(UID b2 bord v024)
eststo t

coefplot t
*/

forval i = 1990/2000 {

bys UID :gen temp`i'=1 if b2>=`i' & bord==1
replace temp`i'=0 if temp`i'==.
bys UID :egen mtemp`i'=max(temp`i') 

bys UID :gen k`i' =1 if b2 >`i' & b2<=`i'+5
replace k`i' =0 if b2>=`i'-5 & b2<=`i'


}

forval i = 2001/2004 {

bys UID :gen temp`i'=1 if b2>=`i' & bord==1
replace temp`i'=0 if temp`i'==.
bys UID :egen mtemp`i'=max(temp`i') 

bys UID :gen k`i' =1 if b2 >`i' & b2<=2005
replace k`i' =0 if b2>=`i'-5 & b2<=`i'


}


forval i = 1990/2004 {
quietly reghdfe child_sex treat##k`i'   if  rural==1 & mtemp`i'==1,  cl( v024) absorb(UID b2 bord v024)
eststo o`i'
}


coefplot (o1990,  keep(*#* ) )(o1991,  keep(*#* ) )(o1992, ciopts(pstyle(p3)))(o1993,  ciopts(pstyle(p3)) ) (o1994,  ciopts(pstyle(p3)) ) (o1995,  ciopts(pstyle(p3)) keep(*#* ) )(o1996, ciopts(pstyle(p3)) ) (o1997,  ciopts(pstyle(p3)) keep(*#* )) (o1998,  ciopts(pstyle(p3)) ) (o1999,  ciopts(pstyle(p3)) )(o2000, ciopts(pstyle(p3))) (o2001, keep(*#* )) (o2002, keep(*#* ) ) (o2003,  keep(*#* ) ) (o2004, keep(*#* ) ), vertical yline(0) xlabel(,angle(90)) msymbol(S) offset(.1) coeflabels(1.treat#1.k1990="1990" 1.treat#1.k1991="1991" 1.treat#1.k1992="1992" 1.treat#1.k1993="1993" 1.treat#1.k1994=" 1994" 1.treat#1.k1995=" 1995" 1.treat#1.k1996=" 1996"1.treat#1.k1997=" 1997" 1.treat#1.k1998=" 1998" 1.treat#1.k1999=" 1999" 1.treat#1.k2000=" 2000" 1.treat#1.k2001=" 2001" 1.treat#1.k2002="2002" 1.treat#1.k2003="2003" 1.treat#1.k2004="2004") xtitle(Treat*Assumed_Program_year) ytitle(Likelihood of girl birth) graphregion(fcolor(white))

*coefplot (o1990,  keep(*#* ) )(o1991,  keep(*#* ) )(o1992, ciopts(pstyle(p3)))(o1993,  ciopts(pstyle(p3)) ) (o1994,  ciopts(pstyle(p3)) ) (o1995,  ciopts(pstyle(p3)) keep(*#* ) )(o1996, ciopts(pstyle(p3)) ) (o1997,  ciopts(pstyle(p3)) keep(*#* )) (o1998,  ciopts(pstyle(p3)) ) (o1999,  ciopts(pstyle(p3)) )(o2000, ciopts(pstyle(p3))) (o2001, keep(*#* )) (o2002, keep(*#* ) ) (o2003,  keep(*#* ) ) (o2004, keep(*#* ) ), vertical yline(0) xlabel(,angle(90)) msymbol(S) offset(.1) coeflabels(1.treat#1.k1990="1990" 1.treat#1.k1991="1991" 1.treat#1.k1992="1992" 1.treat#1.k1993="1993" 1.treat#1.k1994=" 1994" 1.treat#1.k1995=" 1995" 1.treat#1.k1996=" 1996"1.treat#1.k1997=" 1997" 1.treat#1.k1998=" 1998" 1.treat#1.k1999=" 1999" 1.treat#1.k2000=" 2000" 1.treat#1.k2001=" 2001" 1.treat#1.k2002="2002" 1.treat#1.k2003="2003" 1.treat#1.k2004="2004") xtitle(LPS*Assumed_Program_year) ytitle(Likelihood of girl birth)
graph export "C:\Users\ssj18\Documents\DHS\falsi_graph_updated.png"
 

coefplot (o1990,  keep(*#* ) drop(strend))(o1991,  keep(*#* ) drop(strend))(o1992,  ciopts(pstyle(p3)) drop (strend ))(o1993,  ciopts(pstyle(p3)) drop (strend )) (o1994,  ciopts(pstyle(p3)) drop (strend )) (o1995,  ciopts(pstyle(p3)) keep(*#* ) drop(strend))(o1996,  ciopts(pstyle(p3)) drop (strend )) (o1997,  ciopts(pstyle(p3)) keep(*#* ) drop(strend)) (o1998,  ciopts(pstyle(p3)) drop (strend )) (o1999,  ciopts(pstyle(p3)) drop (strend ))(o2000,  ciopts(pstyle(p3)) drop (strend )), vertical yline(0) xlabel(,angle(90)) msymbol(S) offset(.1) coeflabels(1.treat#1.k1990="treat90" 1.treat#1.k1991="treat91" 1.treat#1.k1992="treat92" 1.treat#1.k1993="treat93" 1.treat#1.k1994="treat94" 1.treat#1.k1995="treat95" 1.treat#1.k1996="treat96"1.treat#1.k1997="treat97" 1.treat#1.k1998="treat98" 1.treat#1.k1999="treat99" 1.treat#1.k2000="treat00")

****Falsification with FG

forval i = 1990/2004 {
quietly reghdfe child_sex treat##k`i'##fg strend  if  rural==1 & mtemp`i'==1 & bord>1,  cl( v024) absorb(UID b2 bord v024)
eststo of`i'
}


/*
forval i = 1990/2000 {
coefplot o`i',vertical drop(strend)  yline(0)


}
forval i = 1990/2000 {
esttab o`i'

}
coefplot (o1992, label(treat1992) pstyle(p3) offset(-.05) ) (o1993, label(treat1993) pstyle(p3)offset(-.05) ) (o1994, label(treat1994) pstyle(p3)offset(-.05) )(o1994, label(treat1994) pstyle(p3)offset(-.05) )(o1995, label(treat1995) pstyle(p3)offset(-.05) )(o1996, label(treat1996) pstyle(p3)offset(-.05) )(o1997, label(treat1997) pstyle(p3)offset(-.05) )(o1998, label(treat1998) pstyle(p3)offset(-.05) )(o1999, label(treat1999) pstyle(p3)offset(-.05) )(o2000, label(treat2000) pstyle(p3)offset(-.05) ),  drop (strend k1997 k1995)  xline(0) 

coefplot o1992 o1993 o1994 o1995 o1996 o1997 o1998 o1999 o2000,  drop(strend k1997 k1995) 

local coefinter 1.treat#1.k1995 1.treat#1.k1997 

coefplot (o1992, ciopts(pstyle(p3)) ) (o1993,ciopts(pstyle(p3))  ) (o1994, ciopts(pstyle(p3)) ) (o1995, ciopts(pstyle(p3)) keep(`coefinter') ) ,  drop (strend )  xline(0) 
*/


coefplot (o1990,  keep(*#* ) drop(strend)),coeflabels(1.treat#1.k1990="treat90") vertical





***************

gen pnsd = s220b
replace pnsd=0 if missing(pnsd)
sort UID bord b2 
sort v021
bys v021: egen nmom = count(_n) if bord==1


replace nmom=0 if missing(nmom)
sort v021
bys v021: egen nmom1 = max(nmom)
sort UID
bys UID: egen count=count(pnsd) if pnsd>0
replace count=0 if missing(count)
sort UID
bys UID: egen count1 = max(count)
gen psu1 = 1 if count1>0 & bord==1
bys v021: egen psu_use = total(psu1)
drop psu1
gen pnsd_use = (psu_use - count1)/nmom1
bys UID :gen post =1 if b2 >2005 
replace post =0 if b2>=2000 & b2<=2005



replace pnsd_use = 0 if post==0

gen pnsd_use1 = 1-pnsd_use
replace pnsd_use1 =0 if post==0

bys UID :gen tempo=1 if b2>=2000 & bord==1
replace tempo=0 if tempo==.
bys UID :egen mtempo=max(tempo) 

log using "C:\Users\ssj18\Documents\DHS\mech_ultra.txt",replace
reghdfe child_sex treat##c.pnsd_use1##fg strend if rural==1 & mtempo==1 & bord>1, cl(v024) absorb(b2 bord UID)
eststo reg1
esttab reg1
log close
