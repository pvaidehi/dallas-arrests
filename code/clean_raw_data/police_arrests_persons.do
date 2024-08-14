*-------------------------------------*
* POLICE ARRESTS 
*-------------------------------------*
include "../programs/standardise_ids.do"
include ../programs/clean_person_chars.do


insheet using "../../data/raw/Police_Arrests_7_19_19.csv", clear
fix_arrest_number
foreach var of varlist _all {
     tostring `var', replace force
     replace `var' = trim(`var')
     replace `var' = stritrim(`var')
     rename `var', lower
}
isid incidentnum arrestnumber 
tempfile 7_19_19
save `7_19_19', replace

insheet using "../../data/raw/Police_Arrests_3_22_20.csv", clear
fix_arrest_number
foreach var of varlist _all {
     tostring `var', replace force
     replace `var' = trim(`var')
     replace `var' = stritrim(`var')
     rename `var', lower
}
foreach var of varlist _all {
     replace `var' = "" if `var' == "."
}
isid incidentnum arrestnumber 
//merge 1:1 incidentnum arrestnumber using `7_19_19', nogen
append using `7_19_19'
duplicates drop
duplicates drop incidentnum arrestnumber arresteename age ethnic race sex ageatarre hzip hcity hstate hapt haddress, force

save "../../data/intermediate/police_arrests_persons.dta", replace

/* insheet using "../../data/raw/Police_Arrest_Charges_7_19_19.csv", clear
fix_arrest_number
foreach var of varlist _all {
     tostring `var', replace force
     replace `var' = trim(`var')
     replace `var' = stritrim(`var')
     rename `var', lower
}
tempfile charges_7_19_19
save `charges_7_19_19', replace

insheet using "../../data/raw/Police_Arrest_Charges_3_22_20.csv", clear
fix_arrest_number
foreach var of varlist _all {
     tostring `var', replace force
     replace `var' = trim(`var')
     replace `var' = stritrim(`var')
     rename `var', lower
}
append using `charges_7_19_19'
rename ucrword ucr_word
keep arrestnumber archgnumid ucroffense pclass chargedesc ucrarrestchg ucr_word
duplicates drop
tempfile arrests
save `arrests', replace

use `arrests', clear
joinby arrestnumber using `3_22_20', unmatched(both)  update
rename incidentnum incidentnum_arrest
save "../../data/intermediate/police_arrests.dta", replace
 */
