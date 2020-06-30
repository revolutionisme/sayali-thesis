clear*
cd "C:\Users\ssj18\Documents\DHS"

use "C:\Users\ssj18\Documents\DHS\DHS2 92-93\IAIQ21DT\IAIQ21FL"
tab q416_1 /*place of de last birth*/

gen home_del=1 if q416_1 <=13 /*last birth only*/
replace home_del=0 if q416_1 ==21 | q416_1 ==22 | q416_1 ==23 | q416_1 ==31 | q416_1 ==41
order state psu district tehsil type town local home_del case_id

keep state psu district tehsil type town local home_del case_id weight iweight
drop if home_del==.

gen tot=1

bys state: gen tot_s=sum(tot)
bys state: egen ts=max(tot_s)
drop tot_s

bys state: gen tot_hd=sum(home_del)
bys state: egen hds=max(tot_hd)
drop tot_hd

*hds : no of home dels in each state. ts: total no of deliveries in each state

bys state: gen homdel_r=hds/ts

tab homdel_r[aweight=weight]

keep weight state homdel_r

bys state:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup


tab homdel_r[fweight=weight]

save homedel,replace





import excel "C:\Users\ssj18\Documents\DHS\DHS2 92-93\home del rate.xlsx", sheet("Sheet1") firstrow allstring

drop F-K



destring,replace

drop if HomeDelrate==.


logit lps HomeDelrate,r
