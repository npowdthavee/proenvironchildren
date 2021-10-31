***US change in environment dataprep****

*cd "C:\Users\Econ\Dropbox\Understanding Society\data"
clear

cap cd "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/data"
cap cd "C:\Users\User\Dropbox\Understanding Society\data"
cap cd "C:\Users\Econ\Dropbox\Understanding Society\data" 

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

keep pidp wave hidp env* scen* scopec*  nch* age*  childo16_nonres* gor_dv  ///
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

*****re-nomalise sex variable ***
drop if sex<0
replace sex=sex-1
tab sex, nolabel

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

**factor analysis

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
lab var sex "Female"
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
gen gender_age = 1 if sex==0 & gender_age==1
replace gender_age = 1 if sex==1 & age_dv<=60 & gender_age==.

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

*********pooled data************
xi:global controls  sex degree A_level GCSE other_qual lgreal_equivhhincome i.marstat i.agegr5_dv i.scsf1 i.scwem sclfsato scghq2 i.gor_dv 

**Generate Inverse Mills Ratio: Attrition
  
 sort pidp wave
 gen attrit_w5 = 0 if wave==4
 by pidp: replace attrit_w5 = 1 if wave[_n+1] ~=5 & wave==4
 gen attrit_w6 = 0 if wave==4
 by pidp: replace attrit_w6 = 1 if wave[_n+2] ~=6 & wave==4
 gen attrit_w7 = 0 if wave==4
 by pidp: replace attrit_w7 = 1 if wave[_n+3] ~=7 & wave==4
 gen attrit_w8 = 0 if wave==4
 by pidp: replace attrit_w8 = 1 if wave[_n+4] ~=8 & wave==4
 gen attrit_w9 = 0 if wave==4
 by pidp: replace attrit_w9 = 1 if wave[_n+5] ~=9 & wave==4
 gen attrit_w10 = 0 if wave==4
 by pidp: replace attrit_w10 = 1 if wave[_n+6] ~=10 & wave==4
 
 *probit attrit_w5 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 *predict phat_w5, xb
 *gen mills_w5 = exp(-.5*phat_w5^2)/(sqrt(2*_pi)*normprob(phat_w5))

 *probit attrit_w6 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 *predict phat_w6, xb
 *gen mills_w6 = exp(-.5*phat_w6^2)/(sqrt(2*_pi)*normprob(phat_w6))
 
 *probit attrit_w7 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 *predict phat_w7, xb
 *gen mills_w7 = exp(-.5*phat_w7^2)/(sqrt(2*_pi)*normprob(phat_w7))
 
 *probit attrit_w8 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 *predict phat_w8, xb
 *gen mills_w8 = exp(-.5*phat_w8^2)/(sqrt(2*_pi)*normprob(phat_w8))
 
 *probit attrit_w9 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 *predict phat_w9, xb
 *gen mills_w9 = exp(-.5*phat_w9^2)/(sqrt(2*_pi)*normprob(phat_w9))
 
 probit attrit_w10 std_pd1 std_pb1 std_pc1 $controls i.ivcoop if wave==4   , r 
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/MFXprobit_future_child_mills.xls", replace stat(coef ci) sideway label dec(3)
 predict phat_w10, xb
 gen mills_w10 = exp(-.5*phat_w10^2)/(sqrt(2*_pi)*normprob(phat_w10))
 
 **Main table
 dprobit cnnatch_t6 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/MFXprobit_future_child.xls", replace stat(coef ci) sideway label dec(3)
  
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
  
 **Break down the environmental variables  
  dprobit cnnatch_t6 std_envhabit1 std_envhabit2 std_envhabit3 std_envhabit4 std_envhabit5 std_envhabit6 std_envhabit7 /*
  */ std_envhabit8 std_envhabit9 std_envhabit10 std_envhabit11 /*
  */ std_scenv_ftst std_scenv_fitl std_scenv_crlf std_scenv_pmep std_scenv_grn std_scenv_bccc  std_scenv_meds std_scenv_crex std_scenv_nowo /*
  */std_scenv_canc std_scenv_tlat std_scopecl30 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1 , r 
  
   outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/MFXprobit_future_child_breakdown.xls", replace stat(coef ci) sideway label dec(3)


   **Generate coefplot
   probit cnnatch_t1 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store A
   probit cnnatch_t2 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store B
   probit cnnatch_t3 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store C   
   probit cnnatch_t4 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store D    
   probit cnnatch_t5 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store E    
   probit cnnatch_t6 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
   margins   , dydx(std_pd1 std_pb1 std_pc1) post atmean
   estimates store F
   
   coefplot A, bylabel(Marginal effect on having a child in t+1) || B, bylabel(Marginal effect on having a child in t+2) || C, bylabel(Marginal effect on having a child in t+3) ///
   || D, bylabel(Marginal effect on having a child in t+4) || E, bylabel(Marginal effect on having a child in t+5) || F, bylabel(Marginal effect on having a child in t+6) ||, ///
   keep(std_pd1 std_pb1 std_pc1) xline(0) byopts(compact cols(1))   
        
graph export "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/Coefplot of pro-environmental components_gender_age.png", as(png) name("Graph") replace
 
**Include Inverse Mills Ratio
 
 dprobit cnnatch_t6 std_pd1 std_pb1 std_pc1 $controls mills_w10 if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  , r 
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/MFXprobit_future_child_mills.xls", append stat(coef ci) sideway label dec(3)
 
**Cardinal index 
 dprobit cnnatch_t6 std_sum_envh std_sum_enva std_sum_enc $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  , r 
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/MFXprobit_future_child_cardinal.xls", replace stat(coef ci) sideway label dec(3)
 
  gen nochw4_chw10 = 0 if cnnatch==0 & cnnatch_t6==0 & maxsum_nnatch==0 & gender_age==1
  replace nochw4_chw10 = 1 if cnnatch==0 & cnnatch_t6==1 & maxsum_nnatch==0 & gender_age==1
 
dprobit cnnatch_t6 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r

**Summary statistics 
 xi:asdoc sum std_pd1 std_pb1 std_pc1 sex degree A_level GCSE other_qual lgreal_equivhhincome i.marstat age_dv scsf1 scwem sclfsato scghq2 /*
*/ if e(sample), by(nochw4_chw10) stat(N mean semean) save(/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/mydoc1.doc) replace

**Dependent variable = number of children
 reg  nnatch_t6 std_pd1 std_pb1 std_pc1 $controls if cnnatch==0 & wave==4 & maxsum_nnatch==0 & gender_age==1  ,  r
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/ols_number_of_future_children.xls", replace stat(coef ci) sideway label dec(3)
 
  reg  nnatch_t6 std_pd1 std_pb1 std_pc1 $controls if  wave==4  & gender_age==1  ,  r
 outreg2 using "/Users/nattavudhpowdthavee/Dropbox/Understanding Society/results/ols_number_of_future_children.xls", append stat(coef ci) sideway label dec(3)
