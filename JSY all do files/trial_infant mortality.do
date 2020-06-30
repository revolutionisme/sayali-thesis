


 reghdfe dead child_sex strend  if bord>=2 & rural==1 & lps==1 & b6==100,  cl( v024) absorb(UID b2 bord )

 
 
   reghdfe yearr treat##p5 child_sex strend  if bord>=2 & rural==1,  cl( v024) absorb(UID b2 bord )
   reghdfe month treat##p5 child_sex strend  if bord>=2 & rural==1,  cl( v024) absorb(UID b2 bord )
   
   
   
   reghdfe v207 treat##p5 child_sex strend  if bord>=2 & rural==1,  cl( v024) absorb(UID b2 bord )
   
   
    reghdfe dead  treat##post05 strend  if  rural==1 ,  cl( v024) absorb(UID b2 bord )

	
	    reghdfe v201 treat strend v107 s116 v130 s190rs if  rural==1 ,  cl( v024) absorb( b2 bord )

*no of children		
reghdfe v201 treat##post05 strend v107 s116 v130 s190rs if  rural==1 & dup<=1 ,  cl( UID) absorb( b2  v024 )
reghdfe v201 treat##p5 strend v107 s116 v130 s190rs if  rural==1 & dup<=1,  cl( UID) absorb( b2  v024 )



reghdfe dead treat##post05 strend if  rural==1  ,  cl( UID) absorb( b2  v024 UID)
reghdfe dead treat##p5 strend  if  rural==1 ,  cl( UID) absorb( b2  v024 UID)


*** how kids died

tab b6 child_sex if lps==1 & b2>2005 & yearr!=.
tab b6 child_sex if lps==0 & b2>2005 & yearr!=.



***** girls don't seem to die in the 'month' or 'day' category. They're dying in the year category
gen day =b6 if b6<=140
gen month =b6 if b6>141 & b6 <=240
gen yearr =b6 if b6>241 & b6 <=338

reghdfe dead treat##post05 strend  if  rural==1 & yearr!=. ,  cl( UID) absorb( b2 UID bord )
reghdfe dead treat##p5 strend v107 s116 v130 s190rs if  rural==1 & dup<=1 & yearr!=.,  cl( UID) absorb( b2 UID bord )


