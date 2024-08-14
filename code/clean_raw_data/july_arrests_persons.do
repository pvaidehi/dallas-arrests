// Purpose: Read in and append July 2018 suspects data

clear
set more off
set excelxlsxlargefile on
include "../programs/standardise_ids.do"
include ../programs/clean_person_chars.do

local filename "../../data/intermediate/july_2018_arrests.dta"
// Create an initial file into which we save everything
set obs 1
gen empty = .
save "`filename'", replace
clear 

forval y = 2010/2018 {
    import excel "../../data/raw/D009212%23%23.xlsx", sheet(`y') firstrow,
    foreach var of varlist _all {
        capture tostring `var', replace force
        capture replace `var' = trim(`var')
        capture replace `var' = stritrim(`var')
    }

	append using `filename'
	save `filename', replace
	clear
}

import excel "./../data/raw/D009212%23%23.xlsx", sheet(2014Pt2) first
	
foreach var of varlist _all {
		capture tostring `var', replace force
		capture replace `var' = trim(`var')
		capture replace `var' = stritrim(`var')
}
	
append using `filename'
save `filename', replace

