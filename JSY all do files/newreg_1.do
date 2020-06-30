*use "D:\DLHS\mer_hh_birth.dta"
*use "G:\DLHS\mer_hh_birth.dta"
use "C:\Users\ssj18\Documents\DHS\mer_hh_birth.dta"
gen str6 v001id = string(v001,"%06.0f")
gen str2 v002id = string(v002,"%02.0f")
gen str2 v003id = string(v003,"%02.0f")

gen one = "1"
*egen UIDBO = concat(one stateid distid psuid hhid hhsplitid personid boid)
egen UID  = concat(one v001id v002id v003id)
duplicates tag UID bord , gen(dup1)
destring UID, replace
format %20.0g UID

order UID v010 bord-b16

gen lps=1 if v024==4 | v024==5 | v024==7 | v024==14  | v024==15   | v024==19 | v024==26 | v024==29 | v024==33 | v024==34 
replace lps=0 if lps==.

gen bpl=1 if sh58==1 /*yes*/
replace bpl=2 if sh58==8
replace bpl=0 if missing(bpl)/*no*/

gen child_sex=1 if b4==2 /*fem*/
replace child_sex=0 if child_sex==.

gen fert_max=1 if v605==2 /*desire no more children*/
gen nomorechil=v605
replace fert_max=1 if nomorechil==6
replace fert_max=0 if missing(fert_max)

gen fg_=1 if bord==1 & child_sex==1/*first child is a girl*/
replace fg_=0 if bord==1 & child_sex==0
bys UID :egen fg=max(fg_)



*different types of post

*1
bys UID :gen post =1 if b2 >2005 
replace post =1 if b2==2005 & b1>4
replace post =0 if post==.

bys UID: gen p=1 if b2 >2005
replace p =0 if b2<2005
*2
gen post1=1 if bord==1 & b2>2005
bys UID :egen post11=max(post1)
replace post11=0 if missing(post11)

*3
bys UID :gen post03 =1 if b2 >2005 
replace post03 =0 if post03==.


bys UID: egen youn=max(bord) /*youngest child*/
gen temp=bord if bord==youn

gen f_2=1  if (temp!=. & b2<=2005) /*youngest child born before 2005*/
bys UID :egen f_2temp=max(f_2)/*fams with the youngest child born before 2005*/

bys UID: gen temp1=1 if f_2temp!=. & bord==1 & b2>=1994 /*in fams with youngest kid born before 2005 was the oldes child born after 1994*/
bys UID: egen mtemp1=max(temp1) /*all kids born between 1994-2004*/
gen post2=0 if mtemp1==1
replace post2=1 if post11==1




***post3 0-6



order UID v010 bord child_sex fg b2 post post11 post2 youn f_2 f_2temp temp1 mtemp1



gen post3=0 if f_2temp==1
replace post3=1 if missing(post3)

gen fam=1 if bord==1 & b2>1994
bys UID:egen fam_max =max(fam)

gen scst=1 if sh36==1 | sh36==2
gen obc =1 if sh36==3
gen upcaste=1 if sh36==4

replace scst=0 if missing(scst)
replace obc=0 if missing(obc)
replace upcaste=0 if missing(upcaste)

gen uc_obc=1 if upcaste==1 | obc==1
replace uc_obc=0 if missing(uc_obc)

gen rural =1 if v025==2
replace rural =0 if missing(rural)

gen mom_edu=v133
gen mom_age=v012

gen child_age=2016-b2

gen dead =1 if b5==0
replace dead=0 if missing(dead)


gen lpsp=1 if lps==1 & bpl==1
replace lpsp=0 if lps==0 & bpl==1


gen lpsnp=1 if lps==1 & bpl==0
replace lpsnp=0 if lps==0 & bpl==0




gen fg_post=fg*post
gen fgp=fg*p
gen fg_post11=fg*post11
gen fg_post2=fg*post2
gen fg_post3=fg*post3


gen hindu=1 if v130==1
replace hindu=0 if missing(hindu)

gen musl=1 if v130==2
replace musl=0 if missing(musl)

gen tot_chil=v201

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
/*
gen Sib2=sibb2
gen Sib3=sibb3
gen Sib4=sibb4*/

replace sibb2=. if sibb2==0
replace sibb3=. if sibb3==0
replace sibb4=. if sibb4==0


gen boy=1 if child_sex==0
replace boy=0 if child_sex==1

rename hv244 land
rename v123 bicycle
rename v122 refrigerator 
rename v121 tv
rename s190r wealth_index
rename  v715 dad_edu
rename v730 dad_age
rename v705 dad_occ

save "C:\Users\ssj18\Documents\DHS\use_data",replace
/*
bys bord fg:tab b2 child_sex if rural==1  & lps==1  
*bys bord fg:tab b2 child_sex if rural==1  & lps==1 


gen year=b2
gen newstatecode=v024 
merge m:m newstatecode year using "D:/DLHS/rain_lps",gen(m) force
gen np2=rain*post2

reghdfe child_sex rain post2 np2 scst upcaste mom_edu mom_age s190r dead if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024)

reghdfe child_sex fg##post2  scst upcaste mom_edu mom_age dead if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )
eststo r1

esttab using "D:/DLHS/r1.tex", label title(Regression table\label{tab1})


reghdfe child_sex fg##post2  scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )
reghdfe child_sex sibb2##post2 sibb3##post2 sibb4##post2  scst upcaste mom_edu mom_age bpl dead  if  rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )
reghdfe child_sex sibb2##post2 sibb3##post2 sibb4##post2  scst upcaste mom_edu mom_age bpl dead if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )
eststo r2
esttab r2 using "D:/DLHS/r2.tex", label title(Regression table\label{tab2})


reghdfe child_sex post2##lps mom_edu mom_age  dead i.bord if bord>=2 & rural==1 & bpl==0 & upcaste==1 ,  cl(UID) absorb(b2 v024  )


reghdfe child_sex post2##lps##fg mom_edu mom_age  dead  if bord>=2 & rural==1 & bpl==0 & upcaste==1 ,  cl(UID) absorb(b2 v024 bord )
eststo r3
esttab r3 using "D:/DLHS/r3.tex", label title(Regression table\label{tab3})


reghdfe child_sex post2##lps##fg mom_edu mom_age  dead  if bord>=2 & rural==1 & bpl==1 & upcaste==0 ,  cl(UID) absorb(b2 v024 bord )

reghdfe child_sex post2##bord##fg  scst upcaste mom_edu mom_age s190r dead if  rural==1  & lps==1 ,  cl(UID) absorb(b2 v024  )


gen jsy=1 if s453a==1
replace jsy=0 if s453a==0

gen del=m15
gen pub=1 if del>=21 & del<=27
replace pub=0 if missing(pub)

gen pub_jsy=1 if pub==1 & jsy==1
replace pub_jsy=0 if missing(pub_jsy)

bys sdistri: egen tot_pub=sum(pub)
bys sdistri: egen tot_pub_jsy=sum(pub_jsy)
bys sdistri: gen cov_jsy=tot_pub_jsy/tot_pub



order UID bord sdistri tot_pub cov_jsy s453a v010 child_sex sibb2 sibb3 sibb4  sib2comp sib3comp sib4comp fg sg tg frg fifg gg gb bb


gen jsy_post2=cov_jsy*post2


reghdfe child_sex cov_jsy post2 jsy_post2 scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )

reghdfe child_sex jsy##post2 scst upcaste mom_edu mom_age bpl dead  if temp!=. & rural==1  & lps==1 ,  cl(UID) absorb(b2 v024 bord )

reghdfe child_sex post2##bord  scst upcaste mom_edu mom_age s190r dead if  rural==1  & lps==1 ,  cl(UID) absorb(b2 v024  )

*balance test

ttest mom_edu  if rural==1  & lps==1 & post2!=., by(fg)
ttest mom_age  if rural==1  & lps==1 & post2!=., by(fg)
ttest dad_age  if rural==1  & lps==1 & post2!=., by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==1 & post2!=., by(fg)
ttest bpl  if rural==1  & lps==1 & post2!=., by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==1 & post2!=., by(fg)
ttest scst  if rural==1  & lps==1 & post2!=., by(fg)
ttest hindu  if rural==1  & lps==1 & post2!=., by(fg)
ttest musl  if rural==1  & lps==1 & post2!=., by(fg)
ttest hv244  if rural==1  & lps==1 & post2!=., by(fg)/*balanced*/
ttest v123  if rural==1  & lps==1 & post2!=., by(fg)
ttest v121  if rural==1  & lps==1 & post2!=., by(fg)






gen fg_p2=post2*fg

******22.04.2018
reghdfe child_sex fg##post2  scst upcaste mom_edu mom_age bpl dead i.bord i.b2##v024 v715 v730 if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb( sdistri b2 )

reg child_sex fg##post2   if bord>=2 & rural==1  & lps==1 ,  cl(UID)
reg child_sex fg##post2  scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 ,  cl(UID)
reghdfe child_sex fg##post2  scst upcaste mom_edu mom_age bpl dead i.bord v715 v730 if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb(  sdistri b2 )
reghdfe child_sex fg##post2  scst upcaste mom_edu mom_age bpl dead i.bord i.b2##v024 v715 v730 if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb( sdistri b2 )

absdid child_sex if rural==1 & lps==1 & bord>=2 & post2!=., tvar(fg_p2) xvar(   i.b2 i.v024) sle
reghdfe child_sex fg##i.b2  scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 & post2!=. & b2>=1998,  cl(UID) absorb(b2 v024 bord )
******PARALLEL TRENDS
reghdfe child_sex fg##i.b2  scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 & post2!=. & b2>2000,  cl(UID) absorb(b2 v024 bord )
reghdfe child_sex fg##i.b2  scst upcaste mom_edu mom_age bpl dead  if bord>=2 & rural==1  & lps==1 & post2!=. & b2>=1998,  cl(UID) absorb(b2 v024 bord )







****24.04
*balance test** use this!!
*LPS
rename hv244 land
rename v123 bicycle
rename v122 refrigerator 
rename v121 tv
rename s190r wealth_index
rename  v715 dad_edu
rename v730 dad_age
rename v705 dad_occ

bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==1 & dup<=1, by(fg)
ttest mom_age  if rural==1  & lps==1 & dup<=1, by(fg)
ttest dad_age  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest bpl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest land  if rural==1  & lps==1 & dup<=1, by(fg)
ttest bicycle  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest tv  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest refrigerator  if rural==1  & lps==1 & dup<=1, by(fg)/*balanced*/
ttest child_sex  if rural==1  & lps==1 & bord>=2, by(fg)/*balanced*/


tab bord fg if rural==1  & lps==1 ,sum (child_sex)

*parallel trends

bys bord fg:tab b2 child_sex if rural==1  & lps==1  

*****
reghdfe child_sex post##lps   hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 & bpl==0,  cl(UID) absorb(bord b2 v024 )
eststo step1
esttab step1 using "D:\DLHS\latex out\step1.tex", title(Regression table\label{tab Step1}) replace /*signi*/
ttest mom_edu  if rural==1 & upcaste==1 & bpl==0  & dup<=1, by(lps)
ttest mom_age  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)
ttest dad_age  if rural==1 & upcaste==1 & bpl==0  & dup<=1, by(lps)/*balanced*/
ttest dad_edu  if rural==1 & upcaste==1 & bpl==0  & dup<=1, by(lps)/*balanced*/
ttest bpl  if rural==1 & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest upcaste  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest scst  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest hindu  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest musl  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest land  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)
ttest bicycle  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest tv  if rural==1  & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest refrigerator  if rural==1 & upcaste==1 & bpl==0 & dup<=1, by(lps)/*balanced*/
ttest child_sex  if rural==1  & upcaste==1 & bpl==0 & bord>=2, by(lps)/*balanced*/



*table1
reghdfe child_sex fg##post  scst upcaste mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=99 & b2<=2011,  cl(UID) absorb(b2 v024 bord )
eststo r1
esttab r1 using "D:\DLHS\latex out\r1.tex", title(Regression table\label{tab1})replace

*table2
reghdfe child_sex fg##post  scst upcaste mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=99 & b2<=2011,  cl(UID) absorb(b2##v024 b2 v024 bord )
eststo r2
esttab r2 using "D:\DLHS\latex out\r2.tex", title(Regression table\label{tab2})replace

*/
*tab3a
reg child_sex fg##post  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) 
eststo r3a
*esttab r3a using "D:\DLHS\latex out\r3a.tex", title(Regression table\label{tab3}) replace

*tab3b
reghdfe child_sex fg##post  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb( b2 v024 bord )
eststo r3b
*esttab r3b using "D:\DLHS\latex out\r3b.tex", title(Regression table\label{tab3}) replace

*tab3c
reghdfe child_sex fg##post  scst upcaste mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2##v024)
eststo r3c
*esttab r3c using "D:\DLHS\latex out\r3c.tex", title(Regression table\label{tab3}) replace


/*tab3
reghdfe child_sex fg##post  scst upcaste mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(b2##v024 b2 v024 bord )
eststo r3
esttab r3 using "D:\DLHS\latex out\r3.tex", title(Regression table\label{tab3}) replace

*tab4
reghdfe child_sex fg##post  scst upcaste mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(bord b2 v024 )
eststo r4
esttab r4 using "D:\DLHS\latex out\r4.tex", title(Regression table\label{tab4}) replace

*tab5
reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age   land if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(b2##v024 b2 v024 )
eststo r5
esttab r5 using "D:\DLHS\latex out\r5.tex", title(Regression table\label{tab5}) replace
*/


*tab6 *** the main one!!
reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb( b2 v024 b2##v024  bord)
eststo r6
*esttab r6 using "D:\DLHS\latex out\r6.tex", title(Regression table\label{tab6}) replace

esttab r3a r3b r3c r6 using "C:\Users\ssj18\Documents\DHS\output.tex", title(Regression table) replace


********


reg child_sex lps##post  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 | obc==1 | bpl==0,  cl(UID) 
eststo r3a
*esttab r3a using "D:\DLHS\latex out\r3a.tex", title(Regression table\label{tab3}) replace

*tab3b
reghdfe child_sex lps##post  if bord>=2 & rural==1   & b2>=1995 & upcaste==1 | obc==1 | bpl==0,  cl(UID) absorb( b2 v024 bord )
eststo r3b
*esttab r3b using "D:\DLHS\latex out\r3b.tex", title(Regression table\label{tab3}) replace

*tab3c
reghdfe child_sex lps##post  mom_edu mom_age bpl hindu musl land if bord>=2 & rural==1  & b2>=1995 & upcaste==1 | obc==1 | bpl==0,  cl(UID) absorb(v024 b2)
eststo r3c
*esttab r3c using "D:\DLHS\latex out\r3c.tex", title(Regression table\label{tab3}) replace



*tab6 *** the main one!!
reghdfe child_sex lps##post hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 | obc==1 | bpl==0,  cl(UID) absorb( b2 v024  bord)
eststo r6
*esttab r6 using "D:\DLHS\latex out\r6.tex", title(Regression table\label{tab6}) replace

esttab r3a r3b r3c r6 using "C:\Users\ssj18\Documents\DHS\output_lps.tex", title(Regression table) replace






*formal testing


reghdfe child_sex fg##b2  scst upcaste mom_edu mom_age hindu musl land if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(  b2 v024)
test _b[1.fg#1996.b2 ]=_b[1.fg#1997.b2]=_b[1.fg#1998.b2]=_b[1.fg#1999.b2]=_b[1.fg#2000.b2]=_b[1.fg#2001.b2]=_b[1.fg#2002.b2]=_b[1.fg#2003.b2]=_b[1.fg#2004.b2]=0
eststo rob1
esttab rob1 using "D:\DLHS\latex out\rob1.tex", title(Regression table\label{tab7}) replace 
*Ftest joint significance
* F(  9,167334) =    1.51
 *           Prob > F =    0.1365
*tot fertility
reghdfe tot_chil fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if dup<=1 & rural==1  & lps==1 & b2>=95,  cl(UID) absorb( b2 v024 b2##v024 )

*Conditioned on sibling composition

reghdfe child_sex sibb2##post  scst upcaste hindu musl mom_edu mom_age land  if bord==2 & tot_chil==2 & rural==1  & lps==1 & b2>=1995 & sibb2!=.,  cl(UID) absorb( b2 v024 b2##v024 )
eststo sib2
esttab sib2 using "D:\DLHS\latex out\sib2.tex", title(Regression table\label{tab8}) replace 

reghdfe child_sex sibb3##post  scst upcaste hindu musl mom_edu mom_age land  if bord>=2 & tot_chil==3 & rural==1  & lps==1 & b2>=1995 & sibb3!=.,  cl(UID) absorb( b2 v024 b2##v024 )
eststo sib3
esttab sib3 using "D:\DLHS\latex out\sib3.tex", title(Regression table\label{tab9}) replace 

reghdfe child_sex sibb4##post  scst upcaste hindu musl mom_edu mom_age land  if bord>=2 & tot_chil==4 & rural==1  & lps==1 & b2>=1995 & sibb4!=.,  cl(UID) absorb( b2 v024 b2##v024 )
eststo sib4
esttab sib4 using "D:\DLHS\latex out\sib4.tex", title(Regression table\label{tab10}) replace 

esttab sibcomp using "D:\DLHS\latex out\sibcomp.tex", title(Regression table\label) replace


*By caste
reghdfe child_sex fg##post##scst hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo scst
esttab scst using "D:\DLHS\latex out\scst.tex", title(Regression table\label{tab8}) replace 

reghdfe child_sex fg##post##upcaste hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo upc
esttab upc using "D:\DLHS\latex out\upc.tex", title(Regression table\label{tab8}) replace 

reghdfe child_sex fg##post##hindu mom_edu mom_age land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo hin
esttab hin using "D:\DLHS\latex out\hin.tex", title(Regression table\label{tab8}) replace 

reghdfe child_sex fg##post##musl mom_edu mom_age land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo musl
esttab musl using "D:\DLHS\latex out\musl.tex", title(Regression table\label{tab8}) replace 

esttab scst upc hin musl using "D:\DLHS\latex out\caste.tex", title(Regression table\label) replace 


*tab7 *** 
reghdfe child_sex fg##post##lps   hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & b2>=1995 & upcaste==1 & bpl==0,  cl(UID) absorb(b2 v024  )
eststo triple
esttab triple using "D:\DLHS\latex out\triple.tex", title(Regression table\label{tab7}) replace /*not signi*/




*HPS
bys UID: gen dup=cond(_N==1,0,_n)
ttest mom_edu  if rural==1  & lps==0 & dup<=1, by(fg)
ttest mom_age  if rural==1  & lps==0 & dup<=1, by(fg)
ttest dad_age  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest dad_edu  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest bpl  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest upcaste  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest scst  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest hindu  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest musl  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest hv244  if rural==1  & lps==0 & dup<=1, by(fg)
ttest v123  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest v121  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/
ttest v122  if rural==1  & lps==0 & dup<=1, by(fg)/*balanced*/


reghdfe child_sex fg##post hindu musl mom_edu mom_age land  if bord>=2 & rural==1  & lps==0 & b2>=1995 & scst==0 & bpl==0,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo hpsuc
esttab hpsuc using "D:\DLHS\latex out\hpsuc.tex", title(Regression table\label{tab8}) replace 

reghdfe child_sex fg##post hindu musl mom_edu mom_age land upcaste scst bpl if bord>=2 & rural==1  & lps==0 & b2>=1995 ,  cl(UID) absorb(bord b2 v024 b2##v024 )
eststo hpsr
esttab hpsr using "D:\DLHS\latex out\hpsr.tex", title(Regression table\label{tab8}) replace 


reghdfe child_sex fg##b2  scst upcaste mom_edu mom_age hindu musl land if bord>=2 & rural==1  & lps==0 & b2>=1995,  cl(UID) absorb(  v024)
test _b[1.fg#1996.b2 ]=_b[1.fg#1997.b2]=_b[1.fg#1998.b2]=_b[1.fg#1999.b2]=_b[1.fg#2000.b2]=_b[1.fg#2001.b2]=_b[1.fg#2002.b2]=_b[1.fg#2003.b2]=_b[1.fg#2004.b2]=0





***************************************************
* 20th Sept 2018
***************************************************
reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb( b2 v024 b2##v024 bord )


reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & lps==1 ,  cl(UID) absorb( b2 v024 b2##v024 bord )

reghdfe child_sex fg##post  scst upcaste hindu musl mom_edu mom_age bpl land  if bord>=2 & rural==1  & lps==1 & b2>= ,  cl(UID) absorb( b2 v024 b2##v024 bord )


reghdfe child_sex fg##b2  scst upcaste mom_edu mom_age hindu musl land if bord>=2 & rural==1  & lps==0 & b2>=1995,  cl(UID) absorb(  v024)



sort v000 v001 v002 caseid bord
rename bord bord_unique
gen bord=bord_unique
order bord_unique, after(bord)
by v000 v001 v002 caseid: replace bord=bord[_n-1] if b0!=0 & b0[_n-1]!=0 & b0[_n-1]==b0-1




************************************************************

*************************************************************

* Falsification tests
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

bys UID :gen post07 =1 if b2 >2007 
replace post07 =0 if post07==.

bys UID :gen post08 =1 if b2 >2008 
replace post08 =0 if post08==.

bys UID :gen post09 =1 if b2 >2009 
replace post09 =0 if post09==.

bys UID :gen post10 =1 if b2 >2010 
replace post10 =0 if post10==.


qui reghdfe child_sex fg##post00  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M00
qui reghdfe child_sex fg##post01  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M01
qui reghdfe child_sex fg##post02  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M02
qui reghdfe child_sex fg##post03  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M03
qui reghdfe child_sex fg##post04  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M04
esttab M00 M01 M02 M03 M04 , replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions: Identification through First Girls)
              

qui reghdfe child_sex fg##post07  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M07
qui reghdfe child_sex fg##post08  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M08
qui reghdfe child_sex fg##post09  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M09
qui reghdfe child_sex fg##post10  lowcaste mom_edu mom_age bpl religion land strend if bord>=2 & rural==1  & lps==1 & b2>=1995,  cl(UID) absorb(v024 b2 )
est store M10
esttab M07 M08 M09 M10 , replace b(%10.4f)se scalars(N  r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions: Identification through First Girls)


