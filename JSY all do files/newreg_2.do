clear*
use "C:\Users\ssj18\Documents\DHS\mer_hh_birth.dta"
gen str6 v001id = string(v001,"%06.0f")
gen str2 v002id = string(v002,"%02.0f")
gen str2 v003id = string(v003,"%02.0f")
gen one = "1"
egen UID  = concat(one v001id v002id v003id)
duplicates tag UID bord , gen(dup1)
destring UID, replace
format %20.0g UID
order UID v010 bord-b16
rename v021 PSUID
gen tot_chil=v201

*generate LPS
gen lps=1 if v024==4 | v024==5 | v024==7 | v024==14  | v024==15   | v024==19 | v024==26 | v024==29 | v024==33 | v024==34 
replace lps=0 if lps==.

*generate BPL
gen bpl=1 if sh58==1 /*yes*/
replace bpl=2 if sh58==8
replace bpl=0 if missing(bpl)/*no*/

*child_sex
gen child_sex=1 if b4==2 /*fem*/
replace child_sex=0 if child_sex==.

**
gen fert_max=1 if v605==2 /*desire no more children*/
gen nomorechil=v605
replace fert_max=1 if nomorechil==6
replace fert_max=0 if missing(fert_max)

**
gen fg_=1 if bord==1 & child_sex==1/*first child is a girl*/
replace fg_=0 if bord==1 & child_sex==0
bys UID :egen fg=max(fg_)

** POSTS

bys UID :gen post00 =1 if b2 >2000 
replace post00 =0 if post00==.

bys UID :gen post01 =1 if b2 >2001 
replace post01 =0 if post01==.

bys UID :gen post02 =1 if b2 >2002 
replace post02 =0 if post02==.

bys UID :gen post03 =1 if b2 >2003 
replace post03 =0 if post03==.

bys UID :gen post04 =1 if b2 >2004 
replace post04 =0 if post04==.

bys UID :gen post05 =1 if b2 >2005 
replace post05 =0 if post05==.

bys UID :gen post06 =1 if b2 >2006 
replace post06 =0 if post06==.

bys UID :gen post07 =1 if b2 >2007 
replace post07 =0 if post07==.

bys UID :gen post08 =1 if b2 >2008 
replace post08 =0 if post08==.

bys UID :gen post09 =1 if b2 >2009 
replace post09 =0 if post09==.

bys UID :gen post10 =1 if b2 >2010 
replace post10 =0 if post10==.


** First child was born after 1994
gen fam=1 if bord==1 & b2>1994
bys UID:egen fam_max =max(fam)

**caste
gen scst=1 if sh36==1 | sh36==2
gen obc =1 if sh36==3
gen upcaste=1 if sh36==4

replace scst=0 if missing(scst)
replace obc=0 if missing(obc)
replace upcaste=0 if missing(upcaste)

gen sc=1 if sh36==1
gen st=1 if sh36==2
gen uc_obc=1 if sh36==3 | sh36==4
replace sc==0 if sc==.
replace st==0 if st==.
replace uc_obc==0 if uc_obc==.


**rural, moth's age, edu and child's age
gen rural =1 if v025==2
replace rural =0 if missing(rural)

gen mom_edu=v133
gen mom_age=v012

gen child_age=v007-b2

**lps non poor
gen lpsnp=1 if lps==1 & bpl==0
replace lpsnp=0 if lps==0 & bpl==0

* religion
gen hindu=1 if v130==1
replace hindu=0 if missing(hindu)

gen musl=1 if v130==2
replace musl=0 if missing(musl)


** needed for balance tests

rename hv244 land
rename v123 bicycle
rename v122 refrigerator 
rename v121 tv
rename s190r wealth_index
rename  v715 dad_edu
rename v730 dad_age
rename v705 dad_occ

** twins
sort v000 v001 v002 caseid bord
rename bord bord_unique
gen bord=bord_unique
order bord_unique, after(bord)
by v000 v001 v002 caseid: replace bord=bord[_n-1] if b0!=0 & b0[_n-1]!=0 & b0[_n-1]==b0-1



** lpsnp/hpsnp, although lps/hps could be endogneous.

reghdfe child_sex post05##lps  hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 & bpl==0,  cl(PSUID) absorb(bord b2 v024 )

*** within lps

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & lps==1,  cl(PSUID) absorb(bord b2 v024 )

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & b2>=1990 & rural==1  & lps==1,  cl(PSUID) absorb(bord b2 v024 )


reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land i.bord if bord>=2 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb( b2 v024 )
reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & upcaste==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )



reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & lps==1,  cl(PSUID) absorb(bord b2 v024 )


reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=3 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )



reghdfe child_sex i.b2##fg  hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1990 & lps==1,  cl(PSUID) absorb(bord v024 )

reghdfe child_sex i.b2##fg scst upcaste hindu musl mom_edu mom_age land i.bord if bord>=2 & rural==1  & lps==1,  cl(PSUID) absorb(v024 )
reghdfe child_sex i.b2##fg scst upcaste hindu musl mom_edu mom_age if bord>=2 & rural==1  & lps==1,  cl(PSUID) absorb(v024 bord )

reghdfe child_sex i.b2##fg  hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1990 & lps==1 & upcaste==1,  cl(PSUID) absorb(bord v024 )

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & (upcaste==1|obc==1)  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )
reghdfe child_sex post05##fg hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & scst==1 & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )








***significant as of 20/09/2018

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & upcaste==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )

reghdfe child_sex post05##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & upcaste==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )


reghdfe child_sex post05##lps  hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 & bpl==0,  cl(PSUID) absorb(bord v024 )

****************************************************** Upper caste + OBC post05*fg hold
reghdfe child_sex post05##fg hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & uc_obc==1 & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )



reghdfe child_sex i.b2##fg hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & uc_obc==1 & b2>=1995 & lps==1,  cl(PSUID) absorb(bord  v024 )

************************************************************************************************




reghdfe child_sex post05##fg hindu musl mom_edu mom_age land  if bord>=2 & rural==1 & uc_obc==0 & b2>=1995 & lps==1,  cl(PSUID) absorb(bord  v024 )





******





reghdfe child_sex post06##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )
reghdfe child_sex post07##fg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )












*************************************************************************

**Sex composition of children


gen sg_=1 if bord==2 & child_sex==1
replace sg_=0 if bord==2 & child_sex==0
bys UID: egen sg=max(sg_)

gen tg_=1 if bord==3 & child_sex==1
replace tg_=0 if bord==3 & child_sex==0
bys UID: egen tg=max(tg_)


gen frg_=1 if bord==4 & child_sex==1
replace frg_=0 if bord==4 & child_sex==0
bys UID: egen frg=max(frg_)


gen fifg_=1 if bord==5 & child_sex==1
replace fifg_=0 if bord==5 & child_sex==0
bys UID: egen fifg=max(fifg_)

order UID bord v010 child_sex  fg sg tg frg fifg


gen gg=3 if fg==1 & sg==1
gen gb=2 if fg==1 & sg==0
gen bb=1 if fg==0 & sg==0

replace gb=0 if gg==3
replace bb=0 if gg==3

replace gb=0 if bb==1
replace gg=0 if bb==1

replace gg=0 if gb==2
replace bb=0 if gb==2

gen sib2=gg+gb+bb
replace sib2=0 if missing(sib2)
bys UID: egen max_sib2=max(sib2)

gen sib3comp=max_sib2 if bord==3 & max_sib2>0 /*gg-3 gb-2 bb-1*/
gen sib2comp=fg+1 if bord==2/*g-2 b-1*/

replace sib3comp=0 if sib2comp!=.
replace sib2comp=0 if sib3comp>=1 
replace sib2comp=. if sib3comp==.



/*
gen sib="gg" if sib3comp==3
replace sib="gb" if sib3comp==2
replace sib="bb" if sib3comp==1
replace sib="g" if sib2comp==2
replace sib="b" if sib2comp==1
encode(sib), gen(sibb)*/

order UID bord v010 child_sex sib2comp sib3comp  fg sg tg frg fifg 
gen sib3="gg" if sib3comp==3
replace sib3="gb" if sib3comp==2
replace sib3="bb" if sib3comp==1
encode(sib3),gen(sibb3)

gen sib_2="g" if sib2comp==2
replace sib_2="b" if sib2comp==1
encode(sib_2),gen(sibb2)
order UID bord v010 child_sex sibb2 sibb3 sib2comp sib3comp  fg sg tg frg fifg 

***

gen ggg=4 if fg==1 & sg==1 & tg==1
gen ggb=3 if fg==1 & sg==1 & tg==0
gen gbb=2 if fg==1 & sg==0 & tg==0
gen bbb=1 if fg==0 & sg==0 & tg==0



replace ggb=0 if ggg==4
replace gbb=0 if ggg==4
replace bbb=0 if ggg==4

replace ggg=0 if ggb==3
replace gbb=0 if ggb==3
replace bbb=0 if ggb==3

replace ggb=0 if gbb==2
replace ggg=0 if gbb==2
replace bbb=0 if gbb==2

replace ggg=0 if bbb==1
replace gbb=0 if bbb==1
replace ggb=0 if bbb==1



gen sib4=ggg+gbb+bbb+ggb
replace sib4=0 if missing(sib4)
bys UID: egen max_sib4=max(sib4)

gen sib4comp=max_sib4 if bord==4 & max_sib4>0

gen sib_4="ggg" if sib4comp==4
replace sib_4="ggb" if sib4comp==3
replace sib_4="gbb" if sib4comp==2
replace sib_4="bbb" if sib4comp==1

encode(sib_4), gen(sibb4)


order UID bord s453a v010 child_sex sibb2 sibb3 sibb4  sib2comp sib3comp sib4comp fg sg tg frg fifg gg gb bb


replace sibb3 =0 if sibb2!=.
replace sibb4 =0 if sibb2!=.

replace sibb2 =0 if sibb3!=. & sibb2 ==.
replace sibb4 =0 if sibb3!=.  & sibb4==.

replace sibb2 =0 if sibb4!=. & sibb2 ==.
replace sibb3 =0 if sibb4!=. & sibb3==.

replace sibb2=. if sibb2==0
replace sibb3=. if sibb3==0
replace sibb4=. if sibb4==0



reghdfe child_sex sibb2##post05  scst upcaste hindu musl mom_edu mom_age land  if bord==2 & tot_chil==2 & rural==1  & lps==1 & b2>=1995 & sibb2>0,  cl(PSUID) absorb( b2 v024 b2##v024 )

reghdfe child_sex sibb3##post05  scst upcaste hindu musl mom_edu mom_age land  if bord>=2 & tot_chil==3 & rural==1  & lps==1 & b2>=1995 & sibb3!=.,  cl(PSUID) absorb( b2 v024 b2##v024 )

reghdfe child_sex sibb4##post05  scst upcaste hindu musl mom_edu mom_age land  if bord>=2 & tot_chil==4 & rural==1  & lps==1 & b2>=1995 & sibb4!=.,  cl(PSUID) absorb( b2 v024 b2##v024 )




reghdfe child_sex post05##fg post05##sg scst obc upcaste hindu musl mom_edu mom_age land  if bord>=3 & rural==1  & b2>=1995 & lps==1,  cl(PSUID) absorb(bord b2 v024 )

