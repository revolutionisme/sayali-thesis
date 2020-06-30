use "C:\Users\ssj18\Documents\DHS\merge_hh_birth.dta",clear
keep v024 sdistri 

decode(v024), gen(st)
decode(sdistri), gen(sdist)

bys v024 sdistri: gen dup=cond(_N==1,0,_n)
drop if dup>1

replace st=upper(st)
replace sdist=upper(sdist)

encode(st), gen(State)
encode(sdist), gen(District)

gen dist_dhs=District
drop dup
save "C:\Users\ssj18\Documents\DHS\st_dist_dhs.dta" 




**** now check the do file in dropbox/JSY...
*****C:\Users\ssj18\Dropbox\JSY paper update\Rain\merge_dhs_rain
***** finally we get rain_use



