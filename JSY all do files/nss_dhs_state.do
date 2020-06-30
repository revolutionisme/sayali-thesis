gen v024=.
replace 	v024=	2	if	state==	4
replace 	v024=	3	if	state==	5
replace 	v024=	4	if	state==	6
replace 	v024=	5	if	state==	7
replace 	v024=	6	if	state==	8
replace 	v024=	7	if	state==	9
replace 	v024=	8	if	state==	10
replace 	v024=	9	if	state==	11
replace 	v024=	10	if	state==	13
replace 	v024=	11	if	state==	14
replace 	v024=	12	if	state==	15
replace 	v024=	13	if	state==	16
replace 	v024=	14	if	state==	17
replace 	v024=	15	if	state==	18
replace 	v024=	16	if	state==	19
replace 	v024=	17	if	state==	20
replace 	v024=	18	if	state==	21
replace 	v024=	19	if	state==	22
replace 	v024=	20	if	state==	23
replace 	v024=	21	if	state==	24
replace 	v024=	22	if	state==	25
replace 	v024=	23	if	state==	26
replace 	v024=	24	if	state==	27
replace 	v024=	25	if	state==	12
replace 	v024=	26	if	state==	28
replace 	v024=	27	if	state==	29
replace 	v024=	28	if	state==	30
replace 	v024=	29	if	state==	31
replace 	v024=	30	if	state==	32
replace 	v024=	31	if	state==	33
replace 	v024=	32	if	state==	34
replace 	v024=	33	if	state==	35
replace 	v024=	35	if	state==	37
replace 	v024=	36	if	state==	4
replace 	v024=	34	if	state==	36

save "C:\Users\ssj18\Documents\DHS\state_nss_mpce_1112.dta",replace
