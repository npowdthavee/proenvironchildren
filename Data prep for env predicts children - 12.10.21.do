***US change in environment dataprep****

*cd "C:\Users\Econ\Dropbox\Understanding Society\data"
clear
clear matrix
clear mata

cap cd "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/data"

*****use Wave 10 individual responses datafile*****

set maxvar 10000

use ukhls_wj/j_indresp.dta


****to create wave variable and remove wave prefixes from all variables for wave 10****

gen wave="j"
rename j_* *

save UKHLS_future_child.dta, replace
clear

****to create wave variable and remove wave prefixes from all variables for all other waves****


foreach x in i h g f e d c b a {
use ukhls_w`x'/`x'_indresp.dta
gen wave="`x'"
rename `x'_* *
save `x'_indresp.dta, replace
clear
}

*****to create panel data-set**********

use UKHLS_future_child.dta

foreach x in i h g f e d c b a {
use UKHLS_future_child.dta
append using `x'_indresp.dta
save UKHLS_future_child.dta, replace

}

********check for duplicates and drop them******

duplicates report pidp wave

duplicates drop pidp wave, force

save UKHLS_future_child.dta, replace

*****change wave letters to numbers****

gen wave_num=.

replace wave_num=10 if wave=="j"
replace wave_num=9 if wave=="i"
replace wave_num=8 if wave=="h"
replace wave_num=7 if wave=="g"
replace wave_num=6 if wave=="f"
replace wave_num=5 if wave=="e"
replace wave_num=4 if wave=="d"
replace wave_num=3 if wave=="c"
replace wave_num=2 if wave=="b"
replace wave_num=1 if wave=="a"
 
drop wave
rename wave_num wave 

**generate having child(ren) over the age of 16
gen childo16_nonres = 0 
replace childo16_nonres = 1 if ohch16==3
lab var childo16_nonres "Have child over 16 living elsewhere"

***reduce the data to make the file more manageable -- can add more variables to save if required

keep pidp wave hidp env* scen* scopec*  nch* age*  childo16_nonres* gor_dv indinus_lw  ///
sex marstat scsf1 scghq* hiqual_dv vote* eumem futrl lchmor lchmorn nnatch futrk finfut scwemwba ncrr12 sclfsato intdaty_dv ivcoop

save UKHLS_future_child.dta, replace

clear

**Generate household data 
use  ukhls_wj/j_hhresp.dta

****to create wave variable and remove wave prefixes from all variables for wave 10****

gen wave="j"
rename j_* *

save us_hhresp.dta, replace
clear


****to create wave variable and remove wave prefixes from all variables for all other waves****

foreach x in i h g f e d c b a {
use ukhls_w`x'/`x'_hhresp.dta
gen wave="`x'"
rename `x'_* *
save `x'_hhresp.dta, replace
clear
} 

*****to create panel data-set**********

use us_hhresp.dta, clear

foreach x in i h g f e d c b a {
use us_hhresp.dta
append using `x'_hhresp.dta
save us_hhresp.dta, replace
}

gen wave_num=.

replace wave_num=10 if wave=="j"
replace wave_num=9 if wave=="i"
replace wave_num=8 if wave=="h"
replace wave_num=7 if wave=="g"
replace wave_num=6 if wave=="f"
replace wave_num=5 if wave=="e"
replace wave_num=4 if wave=="d"
replace wave_num=3 if wave=="c"
replace wave_num=2 if wave=="b"
replace wave_num=1 if wave=="a"

drop wave
rename wave_num wave 

**generate equivalent household income
replace fihhmngrs_dv = 1 if  fihhmngrs_dv<=0

gen k1 = fihhmngrs_dv*12
gen k2 = (1+0.5*(nadoecd_dv-1))
gen k3 = 0.3*(nchoecd_dv)

**gen annual CPI to use as denominator
gen cpi = 0.727 if intdatey==2000
replace cpi = 0.736 if intdatey==2001
replace cpi = 0.745 if intdatey==2002
replace cpi = 0.755 if intdatey==2003
replace cpi = 0.765 if intdatey==2004
replace cpi = 0.781 if intdatey==2005
replace cpi = 0.799 if intdatey==2006
replace cpi = 0.818 if intdatey==2007
replace cpi = 0.847 if intdatey==2008
replace cpi = 0.866 if intdatey==2009
replace cpi = 0.894 if intdatey==2010
replace cpi = 0.934 if intdatey==2011
replace cpi = 0.960 if intdatey==2012
replace cpi = 0.985 if intdatey==2013
replace cpi = 1 if intdatey==2014
replace cpi = 1 if intdatey==2015
replace cpi = 1.007 if intdatey==2016
replace cpi = 1.034 if intdatey==2017
replace cpi = 1.059 if intdatey==2018
replace cpi = 1.078 if intdatey==2019
replace cpi = 1.088 if intdatey==2020

gen equivhhincome = (k1)/(k2+k3)
gen real_equivhhincome = equivhhincome/cpi
gen lghhincome_pc = log(fihhmngrs_dv/hhsize)
gen lgequivhhincome = log(equivhhincome)
gen lgreal_equivhhincome = log(real_equivhhincome)


**Adding all household variables, including children at different ages

keep hidp wave equivhhincome real_equiv lghhincome_pc lgreal lgequiv nch02 nch34 nch511 nch1215 
sort hidp
save us_hhresp.dta, replace

*Generate stable variables, e.g., school and race variables
use  ukhls_wx/xwavedat.dta, clear
keep pidp birthy scend feend generation lmar1y paedqf racel_dv ukborn
sort pidp
save schooling.dta, replace

**Merge all data
use UKHLS_future_child.dta, clear
sort pidp wave
save UKHLS_future_child.dta, replace 

use  schooling.dta, clear
sort pidp  
save schooling.dta, replace 

use UKHLS_future_child.dta, clear
sort pidp 
merge pidp using schooling.dta
drop _m
sort hidp
merge hidp using us_hhresp.dta
drop _m

duplicates drop pidp wave, force

save UKHLS_future_child.dta, replace 


**Clean data

**gen school leaving age
replace scend = . if scend<0

**Clean nchild variables
replace nch02 = . if nch02<0
replace nch34 = . if nch34<0
replace nch511 = . if nch511<0
replace nch1215 = . if nch1215<0


*******to create education variables **********
gen degree=0
replace degree=1 if hiqual_dv==1 |hiqual_dv==2
gen A_level=0
replace A_level=1 if hiqual_dv==3 
gen GCSE=0
replace GCSE=1 if hiqual_dv==4
gen other_qual=0
replace other_qual=1 if hiqual_dv==5
gen no_qual=0
replace no_qual=1 if hiqual_dv==9

****to create age dummies*******
drop if agegr10_dv<0
tab agegr10_dv, generate(d10_age)
drop d10_age1
drop if age_dv<0
tab age_dv, generate(d_age)
drop d_age1

********to create region dummies*******
drop if gor_dv<0
tab gor_dv, generate(d_region)
drop d_region1

*****gen female variable ***
gen female = 0 if sex==1
replace female = 1 if sex==2
lab def female 0 "Male" 1 "Female"
lab val female female

*********to create marital status variable*******
replace marstat = 99 if marstat<0

***clear health variable*******
replace scsf1 = 99 if scsf1<0

**Clean life satisfaction
replace scwemwba = 99 if scwemwba<0

**Likelyhood to have children

gen donotwantch = 0 if lchmor~=.
replace donotwantch = 1 if lchmor==3

replace agegr5_dv=. if agegr5_dv<0

replace scopecl30=. if scopecl30<0
replace scopecl30 = 0 if scopecl30==2

***drop all non-valid values*****

foreach x in envhabit1 envhabit2 envhabit3 envhabit4 envhabit5 envhabit6 envhabit7 envhabit8 envhabit9 envhabit10 envhabit11{
replace `x'=. if `x'<0
replace `x'=. if `x'==6
}

**Reverse variables to make higher values = better environmental behaviour 
 
revrs envhabit2, replace 
revrs envhabit4, replace 
revrs envhabit5, replace 
revrs envhabit6, replace 
revrs envhabit7, replace 
revrs envhabit8, replace 
revrs envhabit9, replace 
revrs envhabit10, replace 
revrs envhabit11, replace 

***drop all non-valid values*****

foreach x in scenv_ftst scenv_crlf scenv_grn scenv_bccc scenv_pmep scenv_meds scenv_crex scenv_nowo scenv_fitl scenv_canc scenv_tlat{
replace `x'=. if `x'<0
}

**Reverse variables to make higher values = better concerns for the environmental  

 revrs scenv_bccc, replace
 revrs scenv_pmep, replace
 revrs scenv_meds, replace

*1) Environmental habits
factor envhabit1 envhabit2 envhabit3 envhabit4 envhabit5 envhabit6 envhabit7 envhabit8 envhabit9 envhabit10 envhabit11  
*screeplot, yline(1) 
predict pd1 pd2 pd3

*2) Attitudes towards pro-envirnmental behaviours
factor scenv_fitl scenv_ftst scenv_crlf scenv_pmep 
predict pb1 pb2 pb3

*3) Climate change literacy
factor  scenv_grn scenv_bccc scenv_meds scenv_crex scenv_nowo  scenv_canc scenv_tlat scopecl30 
*screeplot, yline(1)  
predict pc1 pc2  

*********to create child variable*******
replace nchunder16=. if nchunder16<0
gen chunder16=.
replace chunder16=0 if nchunder16==0 
replace chunder16=1 if nchunder16>0 & nchunder16~=. 

replace sclfsato=. if sclfsato<0
replace scghq2_dv=. if scghq2_dv<0

sort pidp wave
by pidp: gen chunder16_t1 = chunder16[_n+1] if wave[_n+1]-wave==1
by pidp: gen chunder16_t2 = chunder16[_n+2] if wave[_n+2]-wave==2
by pidp: gen chunder16_t3 = chunder16[_n+3] if wave[_n+3]-wave==3
by pidp: gen chunder16_t4 = chunder16[_n+4] if wave[_n+4]-wave==4
by pidp: gen chunder16_t5 = chunder16[_n+5] if wave[_n+5]-wave==5
by pidp: gen chunder16_t6 = chunder16[_n+6] if wave[_n+6]-wave==6

by pidp: gen nchunder16_t1 = nchunder16[_n+1] if wave[_n+1]-wave==1
by pidp: gen nchunder16_t2 = nchunder16[_n+2] if wave[_n+2]-wave==2
by pidp: gen nchunder16_t3 = nchunder16[_n+3] if wave[_n+3]-wave==3
by pidp: gen nchunder16_t4 = nchunder16[_n+4] if wave[_n+4]-wave==4
by pidp: gen nchunder16_t5 = nchunder16[_n+5] if wave[_n+5]-wave==5
by pidp: gen nchunder16_t6 = nchunder16[_n+6] if wave[_n+6]-wave==6

by pidp: gen donotwantch_t1 = donotwantch[_n+1] if wave[_n+1]-wave==1 

**Use alternative children variable
replace nnatch=. if nnatch<0
gen cnnatch=0 if nnatch==0
replace cnnatch=1 if nnatch>0 & nnatch~=.

sort pidp wave
by pidp: gen cnnatch_t1 = cnnatch[_n+1] if wave[_n+1]-wave==1
by pidp: gen cnnatch_t2 = cnnatch[_n+2] if wave[_n+2]-wave==2
by pidp: gen cnnatch_t3 = cnnatch[_n+3] if wave[_n+3]-wave==3
by pidp: gen cnnatch_t4 = cnnatch[_n+4] if wave[_n+4]-wave==4
by pidp: gen cnnatch_t5 = cnnatch[_n+5] if wave[_n+5]-wave==5
by pidp: gen cnnatch_t6 = cnnatch[_n+6] if wave[_n+6]-wave==6

sort pidp wave
by pidp: gen nnatch_t1 = nnatch[_n+1] if wave[_n+1]-wave==1
by pidp: gen nnatch_t2 = nnatch[_n+2] if wave[_n+2]-wave==2
by pidp: gen nnatch_t3 = nnatch[_n+3] if wave[_n+3]-wave==3
by pidp: gen nnatch_t4 = nnatch[_n+4] if wave[_n+4]-wave==4
by pidp: gen nnatch_t5 = nnatch[_n+5] if wave[_n+5]-wave==5
by pidp: gen nnatch_t6 = nnatch[_n+6] if wave[_n+6]-wave==6

**Standardised pd1 and pc1
egen std_pd1 = std(pd1)
egen std_pc1 = std(pc1)
egen std_pb1 = std(pb1)

egen std_pd2 = std(pd2)
egen std_pc2 = std(pc2)
egen std_pb2 = std(pb2)


label var std_pd1 "Pro-environmental behaviours/habits"
label var std_pb1 "Beliefs about own green lifestyle"
label var std_pc1 "Climate change literacy"
lab var degree "Highest education: First degree"
lab var A_level "Highest education: A-level"
lab var GCSE "Highest education: GCSE"
lab var other_qual "Highest education: Other qualifications"
lab var lgreal_equivhhincome "Log of equivalent household income"

**No children prior to Wave 4
sort pidp
by pidp: egen sum_nnatch = sum(nnatch) if wave<4
by pidp: egen maxsum_nnatch = max(sum_nnatch)

**Clean interview cooperation variable*******
replace ivcoop = 99 if ivcoop<0

**Gen sample by gender and age*
gen age_wave4 = age_dv if wave==4
sort pidp
by pidp:egen mage_wave4 = max(age_wave4)

gen gender_age_w4 = 1 if female == 1 & mage_wave4<=40
replace gender_age_w4 = 1 if female==0 & mage_wave4<=55 & gender_age_w4==.

**Gen cardinal index
gen sum_envhabit = envhabit1+envhabit2+envhabit3+envhabit4+envhabit5+envhabit6+envhabit7+envhabit8+envhabit9+envhabit10+envhabit11
gen sum_envatt = scenv_fitl + scenv_ftst + scenv_crlf + scenv_pmep
gen sum_climatechg = scenv_grn + scenv_bccc + scenv_meds + scenv_crex + scenv_nowo + scenv_canc + scenv_tlat + scopecl30

**Gen standardised cardinal index 
egen std_sum_envhabit = std(sum_envh) 
egen std_sum_envatt = std(sum_envatt)
egen std_sum_enclim = std(sum_clim)
 
save UKHLS_future_child.dta, replace

use UKHLS_future_child.dta, clear

**Revision

**Polychoric factor analysis
*Environmental habits 
polychoric  envhabit1 envhabit2 envhabit3 envhabit4 envhabit5 envhabit6 envhabit7 envhabit8 envhabit9 envhabit10 envhabit11 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)

esttab matrix(r) using poly1.csv, replace label cells(fmt(%9.4f))

factormat r, n($N) factors(3)

esttab using factor1.csv, replace ///
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t)  Psi[Uniqueness]") ///
nogap noobs nonumber nomtitle


screeplot, yline(1)  
predict fd1 fd2 fd3

*Attitudes towards pro-envirnmental behaviours
polychoric  scenv_fitl scenv_ftst scenv_crlf scenv_pmep 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)

esttab matrix(r) using poly2.csv, replace label cells(fmt(%9.4f))

factormat r, n($N) factors(3)

esttab using factor2.csv, replace ///
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t)  Psi[Uniqueness]") ///
nogap noobs nonumber nomtitle

screeplot, yline(1)  
predict fb1 fb2 fb3 

*Climate change literacy
polychoric  scenv_grn scenv_bccc scenv_meds scenv_crex scenv_nowo  scenv_canc scenv_tlat scopecl30 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)

esttab matrix(r) using poly3.csv, replace label cells(fmt(%9.4f))

factormat r, n($N) factors(3)

esttab using factor3.csv, replace ///
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t)  Psi[Uniqueness]") ///
nogap noobs nonumber nomtitle

screeplot, yline(1)  
predict fc1 fc2 fc3 
  
**Preparing for stcox -- time-invariant environmental variables
gen fc1_w4 = fc1 if wave==4 
gen fc2_w4 = fc2 if wave==4 
gen fc3_w4 = fc3 if wave==4 
gen fb1_w4 = fb1 if wave==4 
gen fb2_w4 = fb2 if wave==4 
gen fd1_w4 = fd1 if wave==4 
gen fd2_w4 = fd2 if wave==4 
gen fd3_w4 = fd3 if wave==4  

sort pidp
by pidp: egen mfc1 = max(fc1_w4)
by pidp: egen mfc2 = max(fc2_w4)
by pidp: egen mfc3 = max(fc3_w4)
by pidp: egen mfb1 = max(fb1_w4)
by pidp: egen mfb2 = max(fb2_w4)
by pidp: egen mfd1 = max(fd1_w4)
by pidp: egen mfd2 = max(fd2_w4)
by pidp: egen mfd3 = max(fd3_w4)

sort pidp
by pidp: egen meanfc1 = mean(fc1)
by pidp: egen meanfc2 = mean(fc2)
by pidp: egen meanfc3 = mean(fc3)
by pidp: egen meanfb1 = mean(fb1)
by pidp: egen meanfb2 = mean(fb2)
by pidp: egen meanfd1 = mean(fd1)
by pidp: egen meanfd2 = mean(fd2)
by pidp: egen meanfd3 = mean(fd3)

 
**Standardise factor variables
egen std_fc1 = std(fc1)
egen std_fc2 = std(fc2)
egen std_fc3 = std(fc3)
egen std_fb1 = std(fb1)
egen std_fb2 = std(fb2)
egen std_fd1 = std(fd1)
egen std_fd2 = std(fd2)
egen std_fd3 = std(fd3) 

egen std_mfc1 = std(mfc1)
egen std_mfc2 = std(mfc2)
egen std_mfc3 = std(mfc3)
egen std_mfb1 = std(mfb1)
egen std_mfb2 = std(mfb2)
egen std_mfd1 = std(mfd1)
egen std_mfd2 = std(mfd2)
egen std_mfd3 = std(mfd3) 

egen std_meanfc1 = std(meanfc1)
egen std_meanfc2 = std(meanfc2)
egen std_meanfc3 = std(meanfc3)
egen std_meanfb1 = std(meanfb1)
egen std_meanfb2 = std(meanfb2)
egen std_meanfd1 = std(meanfd1)
egen std_meanfd2 = std(meanfd2)
egen std_meanfd3 = std(meanfd3) 

**Rotate factor analysis
*Environmental habits 
polychoric  envhabit1 envhabit2 envhabit3 envhabit4 envhabit5 envhabit6 envhabit7 envhabit8 envhabit9 envhabit10 envhabit11 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) factors(3)
rotate
predict rfd1 rfd2 rfd3

*Attitudes towards pro-envirnmental behaviours
polychoric  scenv_fitl scenv_ftst scenv_crlf scenv_pmep 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) factors(3)
rotate
predict rfb1 rfb2 rfb3 

*Climate change literacy
polychoric  scenv_grn scenv_bccc scenv_meds scenv_crex scenv_nowo  scenv_canc scenv_tlat scopecl30 
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)
factormat r, n($N) factors(3)
rotate  
predict rfc1 rfc2 rfc3 

egen std_rfc1 = std(rfc1)
egen std_rfc2 = std(rfc2)
egen std_rfc3 = std(rfc3)
egen std_rfb1 = std(rfb1)
egen std_rfb2 = std(rfb2)
egen std_rfd1 = std(rfd1)
egen std_rfd2 = std(rfd2)
egen std_rfd3 = std(rfd3) 


**All variables**
polychoric  envhabit1 envhabit2 envhabit3 envhabit4 envhabit5 envhabit6 envhabit7 envhabit8 envhabit9 envhabit10 envhabit11 /*
*/ scenv_fitl scenv_ftst scenv_crlf scenv_pmep scenv_grn scenv_bccc scenv_meds scenv_crex scenv_nowo  scenv_canc scenv_tlat scopecl30
display r(sum_w)
global N = r(sum_w)
matrix r = r(R)

esttab matrix(r) using poly_all.csv, replace label cells(fmt(%9.4f))

factormat r, n($N) factors(3)

esttab using factor_all.csv, replace ///
cells("L[Factor1](t) L[Factor2](t) L[Factor3](t)  Psi[Uniqueness]") ///
nogap noobs nonumber nomtitle


screeplot, yline(1)  
predict all_f1 all_f2 all_f3

egen std_all_f1 = std(all_f1)
egen std_all_f2 = std(all_f2)
egen std_all_f3 = std(all_f3)

save UKHLS_future_child.dta, replace 
 

use UKHLS_future_child.dta, clear

drop if wave<4
*********note: this code generates Word tables*********


************REGRESSION ANALYSIS*******

********************generate dummy variables from categorical variables************

*********drop if categorical variables invalid******

* drop if marstat==99 | scsf1==99 | scwem==99 | ivcoop==99

tab(marstat), gen(marstat_dv)

tab(scsf1), gen(genhealth_dv)

tab(scwem), gen(future_dv)


ren age_dv age
ren gor_dv gor
ren agegr5_dv age5
*tab(age), gen(age_dv)
tab(gor), gen(gor_dv)
*tab(age5), gen(age5_dv)

gen age_sq = age^2/100

**marital status
sort pidp wave
by pidp: gen married_t6 = marstat_dv2[_n+6] if wave[_n+6]-wave==6
by pidp: gen married_t5 = marstat_dv2[_n+5] if wave[_n+5]-wave==5
by pidp: gen married_t4 = marstat_dv2[_n+4] if wave[_n+4]-wave==4
by pidp: gen married_t3 = marstat_dv2[_n+3] if wave[_n+3]-wave==3
by pidp: gen married_t2 = marstat_dv2[_n+2] if wave[_n+2]-wave==2
 
 

**define controls*******************
global controls female degree  lgreal_equivhhincome marstat_dv2 genhealth_dv2 genhealth_dv3 genhealth_dv4 genhealth_dv5 future_dv2 future_dv3 future_dv4 future_dv5 sclfsato scghq2 age age_sq gor_dv*
 
 **Standardise all pro-environmental variables 
  egen std_envhabit1 = std(envhabit1)
  egen std_envhabit2 = std(envhabit2)
  egen std_envhabit3 = std(envhabit3)
  egen std_envhabit4 = std(envhabit4)
  egen std_envhabit5 = std(envhabit5)
  egen std_envhabit6 = std(envhabit6)
  egen std_envhabit7 = std(envhabit7)
  egen std_envhabit8 = std(envhabit8)
  egen std_envhabit9 = std(envhabit9)
  egen std_envhabit10 = std(envhabit10)
  egen std_envhabit11 = std(envhabit11)
  
  egen std_scenv_ftst = std(scenv_ftst)
  egen std_scenv_fitl = std(scenv_fitl)
  egen std_scenv_crlf = std(scenv_crlf)
  egen std_scenv_pmep = std(scenv_pmep)
  
  egen std_scenv_grn = std(scenv_grn)
  egen std_scenv_bccc = std(scenv_bccc)
  egen std_scenv_meds = std(scenv_meds)
  egen std_scenv_crex = std(scenv_crex)
  egen std_scenv_nowo = std(scenv_nowo)
  egen std_scenv_canc = std(scenv_canc)
  egen std_scenv_tlat = std(scenv_tlat)
  egen std_scopecl30 = std(scopecl30)
  

**Balanced panel
tab wave  
sort pidp
by pidp: egen s = count(cnnatch)

*Generate attrition
 gen attrit_w10 = 0 if wave==4
 by pidp: replace attrit_w10 = 1 if wave[_n+6] ~=10 & wave==4
 
 probit attrit_w10 std_fd1 std_fb1 std_fc1 $controls i.ivcoop if wave==4   , r 

  predict phat_w10, xb
 gen mills_w10 = exp(-.5*phat_w10^2)/(sqrt(2*_pi)*normprob(phat_w10))
  

*gen weight wave 10
sort pidp
by pidp: gen indinus_lw_10 = indinus_lw if wave==10
by pidp: egen lwave_10 = max(indinus_lw_10)  
  
**Probit
*Balanced
dprobit cnnatch_t6 std_fd1   $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1,  r 
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls",  replace stat(coef se)  label dec(3)  

dprobit cnnatch_t6 std_fb1  $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r  
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls", append stat(coef se)  label dec(3) 

dprobit cnnatch_t6 std_fc1 $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r  
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls",  append stat(coef se)  label dec(3) 

dprobit cnnatch_t6 std_fd1 std_fb1 std_fc1 $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r  
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls",   append stat(coef se) label dec(3) 


dprobit cnnatch_t6 std_fd1 std_fb1 std_fc1 $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1 & female==0,  r
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls",  append stat(coef se)  label dec(3) 

dprobit cnnatch_t6 std_fd1 std_fb1 std_fc1 $controls  if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1 & female==1  ,  r
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_1.xls",   append stat(coef se)  label dec(3) 



   **Generate coefplot
   probit cnnatch_t1 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store A
   probit cnnatch_t2 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1   ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store B
   probit cnnatch_t3 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1   ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store C   
   probit cnnatch_t4 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store D    
   probit cnnatch_t5 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store E    
   probit cnnatch_t6 std_fd1 std_fb1 std_fc1 $controls if cnnatch==0 & maxsum_nnatch==0 & gender_age_w4==1  ,  r
   margins   , dydx(std_fd1 std_fb1 std_fc1) post atmean
   estimates store F
   
   coefplot A, bylabel(Marginal effect on having a child in t+1) || B, bylabel(Marginal effect on having a child in t+2) || C, bylabel(Marginal effect on having a child in t+3) ///
   || D, bylabel(Marginal effect on having a child in t+4) || E, bylabel(Marginal effect on having a child in t+5) || F, bylabel(Marginal effect on having a child in t+6) ||, ///
   keep(std_fd1 std_fb1 std_fc1) xline(0) byopts(compact cols(1))   
        
graph export "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Coefplot of pro-environmental components_gender_age.png", as(png) name("Graph") replace
 


 
**Hazard ratio - panel data
stset wave, failure(cnnatch==1)
xtset pidp

*Unbalanced panel 
xtstreg  std_meanfd1 std_meanfb1 std_meanfc1 $controls if  maxsum_nnatch==0 & gender_age_w4==1 ,   distribution(weibull)  vce(cl pidp)
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_2.xls",  replace stat(coef se) eform  label dec(3) 

stcurve, failure at(std_meanfd1==-1) at(std_meanfd1==0) at(std_meanfd1==1)

xtstreg  std_meanfd1 std_meanfb1 std_meanfc1 $controls  if  maxsum_nnatch==0 & gender_age_w4==1 & female==0  , distribution(weibull)  vce(cl pidp)
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_2.xls",  append stat(coef se) eform  label dec(3) 

xtstreg  std_meanfd1 std_meanfb1 std_meanfc1 $controls  if  maxsum_nnatch==0 & gender_age_w4==1 & female==1  , distribution(weibull)  vce(cl pidp)
outreg2 using "/Users/nattavudhpowdthavee/Dropbox/childless environment - ecological economics/results/Revised_table_2.xls",  append stat(coef se)  eform  label dec(3) 
 
