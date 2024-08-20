
use "/Users/vaidehiparameswaran/Documents/Github/arrests/DallasArrests/data/offenses_data.dta", clear
drop nocode ucr_offense
duplicates drop
merge m:1 offense using "../data/offensetype.dta", keep(1 3) nogen
foreach v of varlist offense-other_m {
	rename `v' susp_`v'
}
gen susp_mfshare50=susp_felony==1 | susp_misdemeanor==1


preserve 
collapse (max) susp_felony susp_mis* susp_mf* susp_F* susp_M* susp_vio* susp_pro* susp_q* susp_tr susp_other, by(incidentnum susp_offense)
duplicates tag incidentnum , gen(dup)
bys incidentnum (susp_felony susp_mis): keep if _n == 1
drop dup
tempfile complete
save `complete', replace 
restore 

preserve 
collapse (max) susp_felony susp_mis* susp_mf* susp_F* susp_M* susp_vio* susp_pro* susp_q* susp_tr susp_other, by(incidentnum servnumid susp_offense)
drop if mi(servnumid)
tempfile complete2
save `complete2', replace 
restore 


use "/Users/vaidehiparameswaran/Documents/Github/arrests/DallasArrests/persons_unique.dta", clear
di _N
fix_incident_number
fix_servnum_number


/* preserve
duplicates tag incidentnum servnumid, gen(dup)
keep if dup == 0
merge 1:1  incidentnum servnumid using `complete2'
restore 
 */

merge m:1 incidentnum using `complete'
// joinby incidentnum using `complete', unmatched(both) update 
keep if _merge == 1 | _merge == 3



// names cleaning
clean_names


replace name = upper(name)
split name, p(",") gen(Ncomma)
rename Ncomma1 lastname
rename Ncomma2 firstname
rename Ncomma3 middlename
replace lastname  = trim(lastname)
replace firstname = trim(firstname)
replace middlename = trim(middlename)
drop Ncomma*
split name, p(" ") gen(Ncomma)
replace firstname = trim(Ncomma1) if ~strpos(name, ",")
replace lastname  = trim(subinstr(name, firstname, "", 1)) if ~strpos(name, ",")
drop Ncomma*
replace firstname = trim(firstname)
split firstname, p(" ") gen(temp)
replace firstname = temp1
drop temp*


// gender
gen susp_male = (sex=="Male")
gen susp_female = (sex=="Female")

// race
replace race = proper(race)
gen susp_black = (race == "Black")
gen susp_hispanic = (race == "Hispanic")
gen susp_white = (race == "White") 
gen susp_other = (!susp_black & !susp_hispanic & !susp_white)


gen suspect = 1


tempfile temp_suspects_combine
save `temp_suspects_combine', replace

use "../data/1x_crosswalk_dispatch_incidentnum.dta", clear
fix_incident_number
tempfile crosswalk_dispatch
save `crosswalk_dispatch', replace

use `temp_suspects_combine', clear
ren _m _m_final
merge m:1 incidentnum using `crosswalk_dispatch'
keep if _merge == 1 | _merge == 3

save "~/Desktop/arrests-local/DallasArrests/Suspects/combined.dta"
