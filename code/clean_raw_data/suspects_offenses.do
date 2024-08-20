// purpose: create a long list of all offenses

clear
set more off
set excelxlsxlargefile on
include "../programs/clean_person_chars.do"
include "../programs/standardise_ids.do"

*-------------------------------------*
* JULY 2018 - cleaned
*-------------------------------------*
//a
use "../../data/intermediate/july_2018_incidents.dta", clear
ren *, lower
fix_incident_number
drop if servyr == "885"
destring edate date1, replace
gen susp_date = edate
replace susp_date = date1 if susp_date == .
format susp_date %td
keep servyr incidentnum servnumid offincident ucr_offense suspaddress zipcode susp_date division pcclass
gen off_data = "July2018"
tempfile july2018
save `july2018', replace

*-------------------------------------*
* MAY 2019 
*-------------------------------------*

// 2007-2014 offenses
import delimited "../../data/raw/Off2007thru2010.csv", encoding(ISO-8859-1) clear
keep servyr incidentnum servnumid cfs_number offincident ucr_offense address apt zipcode edate date1 division
tempfile pre2010
save `pre2010'

// 2011-2014 offenses
import delimited "../../data/raw/Off2011thru05312014.csv", encoding(ISO-8859-1) clear
keep servyr incidentnum servnumid cfs_number offincident ucr_offense address apt zipcode edate date1 division
tostring zipcode, replace
append using `pre2010'
tostring servyr, replace
// clean up incident number
fix_incident_number
gen off_data = "May2019"
isid incidentnum servnumid 
tempfile offenses_may2019_pre2014
save `offenses_may2019_pre2014', replace

// 2014-2019 offenses
import delimited "../../data/raw/Off06012014_thru_04032019.csv", encoding(ISO-8859-1) clear
tostring servyr, replace
fix_incident_number
fix_servnum_number
isid incidentnum servnumid 
keep servyr incidentnum servnumid cfs_number offincident ucr_offense address apt zipcode edate date1 division
//merge 1:1 incidentnum servnumid  using `incidents', update gen(merge1)
//label var merge1 "merging incidents and offenses"
gen off_data = "May2019" 
append using `offenses_may2019_pre2014'

rename address off_address
rename zipcode off_zipcode
rename apt off_apt

tempfile may2019
save `may2019', replace

*-------------------------------------*
* NOV 2019
*-------------------------------------*
import delimited "../../data/raw/Crimes.csv", clear
keep servyr incidentnum servnumid offincident ucr_offense address apt zipcode edate date1 division
tostring servyr, replace
fix_incident_number
fix_servnum_number
isid incidentnum servnumid
gen off_data = "Nov2019"

rename address off_address
rename zipcode off_zipcode
rename apt off_apt

tempfile nov2019_crimes
save `nov2019_crimes', replace


*-------------------------------------*
* APPEND
*-------------------------------------*
/* use `july2018', clear
joinby incidentnum using `may2019', unmatched(both) update replace 
ren _m _m_may
joinby incidentnum using `nov2019_crimes', unmatched(both) update replace
ren _merge _m_nov

/* preserve */
duplicates drop
//keep if !mi(servnumid)
bys incidentnum servnumid: gen occurrences = _N
run "~/Desktop/arrests-local/DallasArrests/Suspects/offense_relabel.do"
/* foreach var of varlist servyr address apt zipcode edate date1 division {
    rename `var' offense_`var'
} */

rename address off_address
rename zipcode off_zipcode
rename apt off_apt

drop off_apt off_zipcode occurrences  _m* apt address zipcode
save "/Users/vaidehiparameswaran/Documents/Github/arrests/DallasArrests/data/offenses_data.dta"
 */

use `july2018', clear
append using `may2019'
append using `nov2019_crimes'
duplicates drop
run "../programs/offense_relabel.do"
drop nocode ucr_offense suspaddress off_apt off_zipcode off_address 
merge m:1 offense using "../../data/raw/offensetype.dta", keep(1 3) nogen
duplicates drop
foreach v of varlist offense-other_m {
	rename `v' susp_`v'
}
gen susp_mfshare50=susp_felony==1 | susp_misdemeanor==1
replace susp_misdemeanor=0 if susp_felony==1

gen highest_offense = ""
replace highest_offense = "violent felony" if susp_violent_f == 1
replace highest_offense = "non-violent felony" if susp_nonviolent_f == 1 & susp_violent_f == 0
replace highest_offense = "violent misdemeanor" if susp_violent_m == 1 & susp_violent_f == 0
replace highest_offense = "nonviolent misdemeanor" if susp_violent_m == 0 & susp_misdemeanor == 1 & mi(highest_offense)
replace highest_offense = "not coded" if susp_mfshare50 == 0

replace cfs_number = "" if cfs_number == "NULL"
gen cfs_number_missing = (cfs_number == "")
sort incidentnum cfs_number_missing

bys incidentnum offincident: gen multiple = _N
gsort incidentnum offincident cfs_number_missing
bys incidentnum offincident: replace cfs_number = cfs_number[1] if mi(cfs_number) & multiple > 1
drop multiple
duplicates drop incidentnum offincident, force
collapse (max) susp_felony susp_mis* susp_mf* susp_F* susp_M* susp_q susp_p susp_other susp_v* susp_non* (first) offincident cfs_number, by(incidentnum)
save "../../data/intermediate/offenses_data_suspects.dta"

