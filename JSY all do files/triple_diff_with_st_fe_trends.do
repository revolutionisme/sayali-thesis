use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear


***** this is the updated do file 29th AUg 2019


log using "C:\Users\ssj18\Documents\DHS\new_results_with_st_fe_tr.log",replace
egen st_year = group(v024 b2)

***descriptive stats
gen medu=v133
gen hin=1 if v130==1
gen musl=1 if v130==2
gen chr=1 if v130==3
gen sik=1 if v130==4
gen bud=1 if v130==5
gen jai=1 if v130==6
gen oth=1 if v130>6
gen sc=1 if s116==1
gen st=1 if s116==2
gen obc=1 if s116==3
gen uc=1 if s116>=4

foreach var of varlist hin- uc {

replace `var'=0 if `var'==. 
}

gen agefb=v212
gen mage=v012

gen shh=1 if v151==1
replace shh=0 if shh==.

gen ahh= v152

gen ult_any=s220b
gen ult=s236

gen eli=v138

gen tchil=v201

*rich to poor
gen w1=1 if s190rs==5
gen w2=1 if s190rs==4
gen w3=1 if s190rs==3
gen w4=1 if s190rs==2
gen w5=1 if s190rs==1

**assets
gen elc=1 if v119==1
gen rad=1 if v120==1
gen tv=1 if v121==1
gen refri=1 if v122==1
gen byc=1 if v123==1
gen mot=1 if v124==1
gen car=1 if v125==1

foreach var of varlist w* elc-car {

replace `var'=0 if `var'==. 
}


**time varying
bys UID: egen gir=sum(child_sex) if b2<=2005
bys UID: gen chil_temp=bord if b2<=2005
bys UID: egen tchil05=max(bord) if b2<=2005

eststo summtt: estpost ttest tchil05 gir ult ///
medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult if ///
mtempo==1 & bord==1 & rural==1  & b2<=2005, by(treat)

esttab , noobs cells("b(star fmt(4)) se(fmt(4))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Diff." "Std. Error" )




eststo summstatslps: estpost sum tchil05 gir ult ///
medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult if ///
 bord==1 & rural==1  & (b2<=2005 | b2>=1995) & treat==1

matrix meanf1=e(mean)
matrix list meanf1

eststo summstatshps: estpost sum tchil05 gir ult ///
medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult if ///
 bord==1 & rural==1 & treat==0 & (b2<=2005 | b2>=1995)

matrix meanf0=e(mean)
matrix list meanf0

eststo summtt: estpost ttest tchil05 gir ult ///
medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult if ///
bord==1 & rural==1  & (b2<=2005 | b2>=1995), by(treat)

estadd matrix meanf1
estadd matrix meanf0

esttab , cells("meanf1 meanf0 b(star) se ") star(* 0.1 ** .05 *** 0.01) ///
collabels("Mean(LPS)" "Mean(HPS)" "Diff." "Std. Error" ) mtitles title("Balance Test") tex

***child_sex



eststo summstatslps: estpost sum child_sex if ///
 bord==1 & rural==1  & (b2<=2005 | b2>=1995) & treat==1

matrix meanf1=e(mean)
matrix list meanf1

eststo summstatshps: estpost sum child_sex if ///
 bord==1 & rural==1 & treat==0 & (b2<=2005 | b2>=1995)

matrix meanf0=e(mean)
matrix list meanf0

eststo summtt: estpost ttest child_sex if ///
bord==1 & rural==1  & (b2<=2005 | b2>=1995), by(treat)

estadd matrix meanf1
estadd matrix meanf0

esttab , cells("meanf1 meanf0 b(star) se ") star(* 0.1 ** .05 *** 0.01) ///
collabels("Mean(LPS)" "Mean(HPS)" "Diff." "Std. Error" ) mtitles title("Balance Test") tex


*esttab summstatslps summstatshps ttest, replace b(%10.4f)se cells("mean sd")   ///
*star(* 0.10 ** 0.05 *** 0.01) mtitles long title("Balance Test")
*esttab summstatslps summstatshps ttest, replace b(%10.4f)se cells("mean sd")  ///
*star(* 0.10 ** 0.05 *** 0.01) mtitles long title("Balance Test") tex


foreach x of varlist medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult {

ttest `x' if rural==1 & mtempo==1 & bord==1 & b2 <=2005,by(treat)
}



ttest medu if rural==1 & mtempo==1 & bord==1 & b2 <=2005,by(treat)

ttest medu mage agefb shh ahh hin musl chr sik bud jai oth sc st obc uc fg w* elc rad tv refri byc mot car ult if rural==1 & mtempo==1 & bord==1 & b2 <=2005,by(treat)

ttest gir tchil05 if rural==1 & mtempo==1 & bord==1 ,by(treat)




set more off

***** diff in diff
reghdfe child_sex treat##i.p05   if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo reg1
reghdfe child_sex treat##i.post   if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo reg1_


esttab reg1 reg1_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Difference in Difference ) tex

**st fe
reghdfe child_sex treat##i.p05   if rural==1 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo reg2

***strend
reghdfe child_sex treat##i.p05   if rural==1 & mtempo==1,  cl( v024) absorb(UID i.v024#c.b2 b2 bord )
eststo reg3

****____post
reghdfe child_sex treat##i.post   if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo reg1_

**st fe
reghdfe child_sex treat##i.post   if rural==1 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo reg2_

***strend
reghdfe child_sex treat##i.post   if rural==1 & mtempo==1,  cl( v024) absorb(UID i.v024#c.b2 b2 bord )
eststo reg3_


***final diff in diff
reghdfe child_sex treat##i.p05   if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo reg1
reghdfe child_sex treat##i.post   if rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo reg1_
esttab reg1 reg1_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Difference in Difference ) tex

****


******* triple diff
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID bord b2 )
eststo r6

*st -fe
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo stfe_trip

* st -trend
reghdfe child_sex treat##i.p05##fg  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID i.v024#c.b2 b2 bord )
eststo stfe_trip_trial

areg child_sex treat##i.p05##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID  )
eststo sttr_trip

areg child_sex treat##i.p05##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( st_year) absorb(UID  )
eststo sttr_trip_cl



****************************____post

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

areg child_sex treat##i.post##fg i.v024##c.b2 i.bord if  rural==1 & bord>=2 & mtempo==1,  cl( st_year) absorb(UID  )
eststo sttr_trip_p_cl





log close


**************************************ROBUSTNESS CHECK************************************************


*robust triple diff
areg child_sex treat##i.b2##fg i.bord  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID )
eststo rob_tr
* Ftest
*matrix list e(b) return coeff
 test _b[1.treat#2001.b2#1.fg]=_b[1.treat#2002.b2#1.fg]=_b[1.treat#2003.b2#1.fg]=_b[1.treat#2004.b2#1.fg]=_b[1.treat#2005.b2#1.fg]=0
*       F(  4,    34) =    1.74
*       Prob > F =    0.1631

*esttab rob_tr, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robustness Check) tex
local coefinter 1.treat#2001.b2#1.fg 1.treat#2002.b2#1.fg 1.treat#2003.b2#1.fg 1.treat#2004.b2#1.fg 1.treat#2005.b2#1.fg 1.treat#2006.b2#1.fg 1.treat#2007.b2#1.fg 1.treat#2008.b2#1.fg 1.treat#2009.b2#1.fg 1.treat#2010.b2#1.fg 1.treat#2011.b2#1.fg 1.treat#2012.b2#1.fg 1.treat#2013.b2#1.fg 1.treat#2014.b2#1.fg 1.treat#2015.b2#1.fg
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.fg="2001" 1.treat#2002.b2#1.fg="2002" 1.treat#2003.b2#1.fg="2003" 1.treat#2004.b2#1.fg="2004" 1.treat#2005.b2#1.fg="2005"1.treat#2006.b2#1.fg="2006" 1.treat#2007.b2#1.fg="2007" 1.treat#2008.b2#1.fg="2008" 1.treat#2009.b2#1.fg="2009" 1.treat#2010.b2#1.fg="2010" 1.treat#2011.b2#1.fg="2011" 1.treat#2012.b2#1.fg="2012" 1.treat#2013.b2#1.fg="2013" 1.treat#2014.b2#1.fg="2014" 1.treat#2015.b2#1.fg="2015") xtitle(Likelihood of girl birth) ytitle(Treat*Year*First_girl) graphregion(fcolor(white))


*robust diff in diff
reghdfe child_sex treat##i.b2  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo rob_did
*esttab rob_tr, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robustness Check) tex
local coefinte 1.treat#2001.b2 1.treat#2002.b2 1.treat#2003.b2 1.treat#2004.b2  1.treat#2005.b2  1.treat#2006.b2 1.treat#2007.b2 1.treat#2008.b2  1.treat#2009.b2  1.treat#2010.b2  1.treat#2011.b2  1.treat#2012.b2 1.treat#2013.b2  1.treat#2014.b2  1.treat#2015.b2
coefplot, keep(`coefinte')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2="2001" 1.treat#2002.b2="2002" 1.treat#2003.b2 ="2003" 1.treat#2004.b2 ="2004" 1.treat#2005.b2 ="2005"1.treat#2006.b2 ="2006" 1.treat#2007.b2 ="2007" 1.treat#2008.b2 ="2008" 1.treat#2009.b2 ="2009" 1.treat#2010.b2 ="2010" 1.treat#2011.b2 ="2011" 1.treat#2012.b2 ="2012" 1.treat#2013.b2 ="2013" 1.treat#2014.b2 ="2014" 1.treat#2015.b2 ="2015") xtitle(Likelihood of girl birth) ytitle(Treat*Year) graphregion(fcolor(white))

******************************************************************


areg child_sex treat##i.b2##fg i.bord  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID )

*esttab rob_tr, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robustness Check) tex
local coefinter 1.treat#2001.b2#1.fg 1.treat#2002.b2#1.fg 1.treat#2003.b2#1.fg 1.treat#2004.b2#1.fg 1.treat#2005.b2#1.fg 1.treat#2006.b2#1.fg 1.treat#2007.b2#1.fg 1.treat#2008.b2#1.fg 1.treat#2009.b2#1.fg 1.treat#2010.b2#1.fg 1.treat#2011.b2#1.fg 1.treat#2012.b2#1.fg 1.treat#2013.b2#1.fg 1.treat#2014.b2#1.fg 1.treat#2015.b2#1.fg
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.fg="2001" 1.treat#2002.b2#1.fg="2002" 1.treat#2003.b2#1.fg="2003" 1.treat#2004.b2#1.fg="2004" 1.treat#2005.b2#1.fg="2005"1.treat#2006.b2#1.fg="2006" 1.treat#2007.b2#1.fg="2007" 1.treat#2008.b2#1.fg="2008" 1.treat#2009.b2#1.fg="2009" 1.treat#2010.b2#1.fg="2010" 1.treat#2011.b2#1.fg="2011" 1.treat#2012.b2#1.fg="2012" 1.treat#2013.b2#1.fg="2013" 1.treat#2014.b2#1.fg="2014" 1.treat#2015.b2#1.fg="2015") xtitle(Likelihood of girl birth) ytitle(Treat*Year*First_girl) graphregion(fcolor(white))


areg child_sex treat##i.b2##fg i.bord  if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID )

*esttab rob_tr, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robustness Check) tex
local coefinter 1.treat#2001.b2#1.fg 1.treat#2002.b2#1.fg 1.treat#2003.b2#1.fg 1.treat#2004.b2#1.fg 1.treat#2005.b2#1.fg 
coefplot, keep(`coefinter')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2#1.fg="2001" 1.treat#2002.b2#1.fg="2002" 1.treat#2003.b2#1.fg="2003" 1.treat#2004.b2#1.fg="2004" 1.treat#2005.b2#1.fg="2005") xtitle(Likelihood of girl birth) ytitle(Treat*Year*First_girl) graphregion(fcolor(white))





reghdfe child_sex treat##i.b2  if  rural==1 & mtempo==1,  cl( v024) absorb(UID b2 bord v024)
eststo rob_did
*esttab rob_tr, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Robustness Check) tex
local coefinte 1.treat#2001.b2 1.treat#2002.b2 1.treat#2003.b2 1.treat#2004.b2  1.treat#2005.b2  
coefplot, keep(`coefinte')  xline(0) xlabel(,angle(90)) msymbol(S) coeflabels( 1.treat#2001.b2="2001" 1.treat#2002.b2="2002" 1.treat#2003.b2 ="2003" 1.treat#2004.b2 ="2004" 1.treat#2005.b2 ="2005" ) xtitle(Likelihood of girl birth) ytitle(Treat*Year) graphregion(fcolor(white))

**************************


















****

****inheritence law
gen iht=.
replace iht =1 if v024==17 | v024==2 | v024 ==16 | v024==20 | v024==31
replace iht=0 if iht==.
replace iht=1 if b2>=2005




reghdfe child_sex treat##i.p05##fg iht if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo inhe1

reghdfe child_sex treat##i.post##fg iht if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID st_year b2 bord )
eststo inhe1_

***these results included
reghdfe child_sex treat##i.post##fg iht if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID b2 i.v024#c.b2 bord )
eststo inhe3

reghdfe child_sex treat##i.p05##fg iht if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID b2 i.v024#c.b2 bord )
eststo inhe3_

******
reghdfe child_sex treat##i.p05##fg iht if  rural==1 & bord>=2 & mtempo==1,  cl( v024) absorb(UID b2 bord )
eststo inhe2



esttab r6 r6_ stfe_trip stfe_trip_ stfe_trip_trial stfe_trip_trial_ inhe1 inhe1_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex

*****triple diff latek output

esttab r6_ stfe_trip_ stfe_trip_trial_ inhe1_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


esttab r6  stfe_trip  stfe_trip_trial  inhe1 , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on sex selective abortions) tex


**** mortality

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



*****bord>2
reghdfe dead5 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d5g_
reghdfe dead5 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d5b_

reghdfe dead3 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d3g_
reghdfe dead3 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d3b_

reghdfe dead1 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d1g_
reghdfe dead1 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d1b_

reghdfe dead7 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d7g_
reghdfe dead7 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d7b_

reghdfe dead28 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d28g_
reghdfe dead28 treat##post##child_sex  if rural==1   & mtempo==1 & bord>2 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d28b_



*****bord>1
reghdfe dead5 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d5g
reghdfe dead5 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d5b

reghdfe dead3 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d3g
reghdfe dead3 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d3b

reghdfe dead1 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d1g
reghdfe dead1 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d1b

reghdfe dead7 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d7g
reghdfe dead7 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d7b

reghdfe dead28 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==1, cl(v024) absorb(  st_year b2 bord UID  )
eststo d28g
reghdfe dead28 treat##post##child_sex  if rural==1   & mtempo==1 & bord>1 & fg==0, cl(v024) absorb(  st_year b2 bord UID  )
eststo d28b


esttab d7g d7g_ , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on child mortality 7 days) tex

esttab d28g d28g_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on child mortality 24 days) tex
 
esttab d1g d1g_ , replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on child mortality 1 year) tex

esttab d3g d3g_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on child mortality 3 years) tex

esttab d5g d5g_, replace b(%10.4f)se scalars(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles long title(Impact on child mortality 5 years) tex

****
gen tfg = treat*fg
br UID tfg treat fg



**+++++++++++++++++++++++++++++++++++++++++++++++++***************************

gen tot_chil=v201


graph twoway (line mean_group b2 if treat==1) (line mean_group b2 if treat==0)



sort caseid bord
bysort UID  : gen birth_space = b2[_n+1]-b2

bysort b2 treat: egen mean_group = mean(child_sex) if treat!=. 
replace mean_group=mean_group*100 if treat!=.
twoway (connected mean_group b2 if treat==1 , lcolor(red) lwidth(medthick) lpattern(solid)) ///
	   (connected mean_group b2 if treat==0 , lcolor(blue) lwidth(medthick) lpattern(solid)), ///
	    ytitle(Average y) xtitle(Time) xline(4, lcolor(black)) xline(5, lcolor(black)) xlabel(1(1)8) ///
		legend(on order(1 "Treatment Group" 2 "Control Group")) name(parallel_1, replace) 
		
		
		

		gen trp=treat*post
order UID trp treat post b2 bord child_sex
bys UID: egen mbord=max(bord)
bys UID: gen temp1=sum(trp) if trp!=.
order UID trp temp1 treat post b2 bord mbord child_sex
bys UID: egen mte=max(temp1)
order UID trp temp1 mte treat post b2 bord mbord child_sex
bys UID: gen insm=1 if mte<mbord & mte>0
order UID trp insm treat post b2 bord mbord child_sex





gen control=1 if treat==0
replace control=0 if treat==1
gen trc=control*post
bys UID: gen temp1c=sum(trc) if trc!=.
order UID trp temp1c control post b2 bord mbord child_sex
bys UID: egen mtec=max(temp1c)
bys UID: gen insmc=1 if mtec<mbord & mtec>0


order UID trp trc insm insmc treat control post b2 bord mbord child_sex


gen ins=1 if insm==1
replace ins=1 if insmc==1


reghdfe tot_chil treat##fg if rural==1 & mtempo==1, cl(v024) a(v024)




*****



gen dead4=1 if b6<=304
replace dead4=0 if dead4==.

reghdfe dead4 treat##post##child_sex  if rural==1   & mtempo==1  , cl(v024) absorb(  st_year b2 bord  UID  )



***************************$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*****************************

* sex ratios by year
bys b2: egen prop_go= mean(child_sex)
gen prop_bo = 1-prop_go
gen sr= (prop_bo/prop_go)*100
*line sr b2 if b2>=1990


use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs",clear

* sex ratios by birth order

bys b2: egen prop_g= mean(child_sex) if bord==1
gen prop_b = 1-prop_g if bord==1
gen sr= (prop_b/prop_g)*100 if bord==1
*line sr b2 if b2>=1990 & bord==1

bys b2: egen prop_g3= mean(child_sex) if bord==2
gen prop_b3 = 1-prop_g3 if bord==2
gen sr3= (prop_b3/prop_g3)*100 if bord==2
*line sr3 b2 if b2>=1990 & bord==2

bys b2: egen prop_g4= mean(child_sex) if bord>=3
gen prop_b4 = 1-prop_g4 if bord>=3
gen sr4= (prop_b4/prop_g4)*100 if bord>=3
*line sr4 b2 if b2>=1990 & bord>=3

* final graph
twoway (line sr b2 if b2>=2000 & bord==1) (line sr3 b2 if b2>=2000 & bord==2) (line sr4 b2 if b2>=2000 & bord>=3)  graphregion(color(white))

















