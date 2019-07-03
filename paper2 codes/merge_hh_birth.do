*cd "C:\Users\ssj18\Documents\DLHS"
*cd "D:\DLHS"
cd "C:\Users\ssj18\Documents\DHS"
use birth,clear
gen hv001=v001
gen hv002=v002
merge m:1 hv001 hv002 using hh, gen(_merge1)

save fullmerge,replace
keep if _merge1==3
save mer_hh_birth,replace

tab b4 if b7>=6 & b7<=84


*this is step one