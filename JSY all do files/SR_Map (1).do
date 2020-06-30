********************************************************************************
* Producing Spatial Maps for India
********************************************************************************

use "C:\Users\ssj18\Documents\DHS\data_to_be_used_for_st_regs.dta"

* Generating Sex ratios for maps

* Generating sex ratios by state
bys v024: egen prop_g_s= mean(child_sex) if child_age<=1
gen prop_b_s = 1-prop_g_s if child_age<=1
gen sr_s= (prop_b_s/prop_g_s)*100
keep v024 sr_s
collapse (max) sr_s, by(v024)
save "C:\Users\ssj18\Documents\DHS\gadm36_IND_shp\SR_State.dta",replace
clear

* Generating sex ratios by districts
bys sdistri: egen prop_g_d= mean(child_sex) if child_age<=1
gen prop_b_d = 1-prop_g_d if child_age<=1
gen sr_d= (prop_b_d/prop_g_d)*100
keep v024 sdistri sr_d
collapse (max) sr_d, by(sdistri v024)
decode sdistri, gen(sd)
sort v024 sd
gen center= _n
save "C:\Users\ssj18\Documents\DHS\gadm36_IND_shp\SR_District.dta",replace
clear



* Generating sex ratios for DLHS3
* Generating sex ratios by state
use "/Volumes/Kritika WD Passport/Data/DHS-India/2005-2006/Birth Recode/IABR52FL.dta"
gen child_sex=1 if b4==2 /*fem*/
replace child_sex=0 if child_sex==.
gen child_age=v007-b2

bys v024: egen prop_g_s= mean(child_sex) if child_age<=5
gen prop_b_s = 1-prop_g_s if child_age<=5
gen sr_s= (prop_b_s/prop_g_s)*100
keep v024 sr_s
collapse (max) sr_s, by(v024)
sort v024
gen center=. //need to code states by hand based on codes in the map file
save "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp/SR_State05.dta"
clear


//Mapping with STATA
capture log close
		cd "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp" /*Setting Diretory*/
		log using "maps.log", replace
		
		cap ssc install scmap   /*Install it if you dont have one*/
		cap ssc install shp2dta 
		
		/*Creates the STAT files from shapefiles- They are already created in the FOLDER*/
		cd "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp"	
		shp2dta using gadm36_IND_0.shp, database(INDdb_0) coordinates(INDcoord_0)  gencentroids(stub)  genid(center)
		shp2dta using gadm36_IND_1.shp, database(INDdb_1) coordinates(INDcoord_1)  gencentroids(stub)  genid(center)
		shp2dta using gadm36_IND_2.shp, database(INDdb_2) coordinates(INDcoord_2)  gencentroids(stub)  genid(center)
		shp2dta using gadm36_IND_3.shp, database(INDdb_3) coordinates(INDcoord_3)  gencentroids(stub)  genid(center)
		clear
		
		
		use "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp/INDdb_1.dta"
clonevar v024= center
merge 1:1 v024 using  "SR_State.dta"

		
		spmap sr_s using "INDcoord_1" , id(center) ///
		title ( "Sex Ratio of Children Between 0-5 years" ) subtitle("2015-16") ///
		fcolor(Blues)
		graph export "map_state.png", as(png) replace
		
		
**********************
* For DLHS 3
cd "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp"
use "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp/INDdb_1.dta"
merge 1:1 center using  "SR_State05.dta"
keep if _m==3

spmap sr_s using "INDcoord_1" , id(center) ///
		title ( "Sex Ratio of Children Between 0-5 years" ) subtitle("2005-06") ///
		fcolor(Blues)
		graph export "map_state05.png", as(png) replace
		
		save "/Volumes/Kritika WD Passport/Data/Stata_Maps-master/India files/gadm36_IND_shp/INDdb_1_for map.dta"
		
		

