// purpose: create a long list of all suspects across datasets

// set environment
clear
set more off
set excelxlsxlargefile on
include "../programs/clean_person_chars.do"
include "../programs/standardise_ids.do"

// import data
use "../../data/intermediate/may_2019_suspects.dta", clear
append using "../../data/intermediate/nov_2019_suspects.dta"
append using "../../data/intermediate/police_persons_suspects.dta"
append using "../../data/intermediate/july_2018_suspects.dta"

// preliminary cleaning
assert mi(edate) if !mi(susp_date)
gen date_text = string(susp_date, "%td")
replace edate = date_text if !mi(susp_date)
drop susp_date date_text
ren involvement inv
replace inv = lower(inv)
replace inv = "Arrested" if strpos(inv, "rrest")
assert !(!mi(apt) & !mi(aptnum))
replace apt = aptnum if mi(apt)
drop aptnum
drop if mi(name)

bys incidentnum name: gen mult_entries = _N
local varlist age sex race address apt city state inv data_source

// deal with duplicate incident-name entries
preserve
keep if mult_entries > 1
sort incidentnum name
summ mult_entries
local max = r(max)
local varlist age sex race address apt city state inv data_source

// generate wide format variables
foreach var in `varlist' {
    forvalues i = 1 / `max' {
        gen `var'`i' = ""
    }
}
sort incidentnum name (mult_entries)
foreach var in `varlist' {
    replace `var'1 = `var'
    forvalues i = 2/`max' {
        by incidentnum name (mult_entries): replace `var'`i' = `var'[`i'] if _N >= `i' & _n == 1
    }
}

// drop duplicate incident-persons after collecting info
bys incidentnum name: keep if _n == 1 

// replace to missing if same value exists in previous variable
foreach var in `varlist' {
    forvalues i = 1 /`max' {
        forvalues j = 2/`max' {
            if `i' <`j' {
            replace `var'`j' = "" if `var'`j' == `var'`i'
            }
        }
    }
}

// replace earlier missing with later variables
foreach var in `varlist' {
    forvalues i = 2 /`max' {
        forvalues j = 3/`max' {
            replace `var'`i' = `var'`j' if mi(`var'`i') & !mi(`var'`j')
            replace `var'`j' = "" if mi(`var'`i') & !mi(`var'`j')
        }
    }
}

// drop variables with all missing values
foreach var of varlist _all {
    count if mi(`var')
    if `r(N)' == _N {
        drop `var' 
    }
}

// look for duplicate variables
foreach v of varlist * {
    foreach w of varlist * {
        capture assert `v'==`w'
        if _rc==0 & "`v'"!="`w'" drop `w'
    }
}

// rename first variable 
foreach var in `varlist' {
    ren `var' `var'1
}

// save for appending later
tempfile duplicate_names
save `duplicate_names'
restore

// append duplicates to unique
drop if mult_entries > 1
foreach var in `varlist' {
    ren `var' `var'1
}
append using `duplicate_names'
drop mult_entries
keep if strlen(incidentnum) == 11
gen str11 incidentnum_str11 = substr(incidentnum, 1, 11)
drop incidentnum
rename incidentnum_str11 incidentnum
ren ageatoffense offenseage
drop data_may data_nov data_police date_text
ren age13 age11
ren city8 city7
gen apt4 = apt5
save "../../data/intermediate/incident_persons_final.dta", replace

// save data with unique incident-persons
use "../../data/intermediate/incident_persons_final.dta", clear
fix_incident_number
bys incidentnum : gen mult_entries = _N
keep if mult_entries == 1
save "../../data/intermediate/incident_persons_unique.dta", replace

// save data with duplicate incidents
use "../../data/intermediate/incident_persons_final.dta", clear
fix_incident_number
bys incidentnum : gen mult_entries = _N
bys incidentnum (name): gen id = _n
keep if mult_entries > 1
drop if mi(name)
ren age13 age11
save "../../data/intermediate/duplicate_incidents.dta", replace
