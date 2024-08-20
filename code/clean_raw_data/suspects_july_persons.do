// Purpose: Read in and append July 2018 suspects data

clear
set more off
set excelxlsxlargefile on
include "../programs/standardise_ids.do"
include ../programs/clean_person_chars.do

local filename "../../data/intermediate/july_2018_incidents.dta"
local filename2 "../../data/intermediate/july_2018_suspects.dta"

// Create an initial file into which we save everything
set obs 1
gen empty = .
save "`filename'", replace
clear 

// Import and append years 2014-2018
forval y = 2014/2018 {
    forval p = 1/2 {
        import excel "../../data/raw/D013554%23.xlsx", sheet("`y' Part `p'") firstrow,
        gen part = `p'

        if `y' == 2014 {
            format IncidentNum %15.0g
            tostring IncidentNum, usedisplayformat replace force
        }

        // Switch some variables to string
        foreach var of varlist _all {
            capture tostring `var', replace force
            capture replace `var' = trim(`var')
            capture replace `var' = stritrim(`var')
        }

        // Rename variables as needed
        capture rename SuspCode Involvement
        capture rename Address SuspAddress
        capture rename City SuspCity
        capture rename State SuspState

        if inlist(`y', 2017, 2018) | (`y' == 2014 & `p' == 1) {
            capture rename V IncidentAddress
        }
        else if inlist(`y', 2015, 2016) {
            capture rename W IncidentAddress
            cap drop U
        }
        else if `y' == 2014 & `p' == 2 {
            capture rename X IncidentAddress
        }

        // Drop redundant variables
        if inrange(`y', 2015, 2018) {
            assert N == IncidentNum
            drop N
        }
        if inrange(`y', 2015, 2018) | (`y' == 2014 & `p' == 1) {
            assert ServYr == O
            drop O
            cap drop U
        }
        else if `y' == 2014 & `p' == 2 {
            assert ServYr == P
            drop P
        }
        if inrange(`y', 2017, 2018) {
            drop T
        }

        append using "`filename'", force
        save "`filename'", replace
        clear
    }
}

// Import and append years 2010-2013
forval y = 2010/2013 {
    import excel "../../data/raw/D010008%23.xlsx", sheet("`y'") firstrow

    // Switch some variables to string
    foreach var of varlist _all {
        capture tostring `var', replace force
        capture replace `var' = trim(`var')
        capture replace `var' = stritrim(`var')
    }

    // Rename variables as needed
    capture rename Address IncidentAddress
    capture rename City SuspCity
    capture rename State SuspState
    capture rename SuspCode Involvement
    capture rename N ServNumID

    append using "`filename'", force
    save "`filename'", replace
    clear
}

// Clean and format variables
use "`filename'", clear
rename *, lower
drop if servyr == "885"
duplicates drop

// Clean up incident number
fix_incident_number

// Clean date variable
sort date1 name
destring edate date1, replace
gen susp_date = edate
replace susp_date = date1 if susp_date == .
format susp_date %td

// Clean up string variables
foreach v of varlist _all {
    capture replace `v' = trim(`v')
}

// Generate flags for misdemeanor and felony
gen susp_misdemeanor_raw = (strpos(pcclass, "M") != 0 | strpos(pcclass, "N") != 0) if !mi(pcclass)
gen susp_felony_raw = (strpos(pcclass, "F") != 0) if !mi(pcclass)

keep incidentnum servnumid sex race suspaddress suspcity suspstate age persontype name susp_date involvement servyr zipcode

// Rename variables for clarity
rename suspaddress address
rename suspcity city
rename suspstate state

// Save the cleaned data
clean_all
keep if !mi(name)
gen data_source = "july2018"
save "`filename2'", replace
