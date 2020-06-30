

cd "C:\Users\ssj18\Documents\DHS"
use smoking,clear
tsset state year

gen byte D = (state==3 & year>=1989) | (state==7 & year>=1988)

synth_runner cigsale beer(1984(1)1987) lnincome(1972(1)1987) retprice age15to24, d(D) trends training_propr(`=13/18')
effect_graphs , multi depvar(cigsale)
pval_graphs

forval i=1/39{

qui synth cigsale retprice cigsale(1988) cigsale(1980) cigsale(1975), ///
xperiod(1980(1)1988) trunit(`i') trperiod(1989) keep(synth_`i',replace)
}

forval i=1/39{

use synth_`i', clear

rename _time years

gen tr_effect_`i' = _Y_treated - _Y_synthetic

keep years tr_effect_`i'

drop if missing(years)

save synth_`i', replace
}

use synth_1, clear

forval i=2/39{

qui merge 1:1 years using synth_`i', nogenerate
}



local lp

forval i=1/39 {
   local lp `lp' line tr_effect_`i' years, lcolor(gs12) ||
}
*

* create plot

twoway `lp' || line tr_effect_3 years, ///
lcolor(orange) legend(off) xline(1989, lpattern(dash))





twoway `lp' || line tr_effect_* years, ///
lcolor(orange) legend(off) xline(1989, lpattern(dash))
