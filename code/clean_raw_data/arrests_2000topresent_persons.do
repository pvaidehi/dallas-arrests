// Purpose: Read in and append July 2018 suspects data

clear
set more off
set excelxlsxlargefile on
include "../programs/standardise_ids.do"
include ../programs/clean_person_chars.do

local filename "../../data/intermediate/2000_present_arrests.dta"
// Create an initial file into which we save everything
set obs 1
gen empty = .
save "`filename'", replace
clear 

forval y = 2000/2011{
	di "Year = `y'"
	import excel "../../data/raw/Arrest_ORR_`y'.xlsx", first
    ren *, lower
	
	foreach var of varlist _all {
        capture tostring `var', replace force
        capture replace `var' = trim(`var')
        capture replace `var' = stritrim(`var')
    }

	append using "`filename'"
	save "`filename'", replace
	clear
}

forval y = 2012/2014{
    import excel "../../data/raw/2012-2014 Data.xlsx", sheet("`y'") first clear	
    ren *, lower
    foreach var of varlist _all {
        capture tostring `var', replace force
        capture replace `var' = trim(`var')
        capture replace `var' = stritrim(`var')
    }
    append using "`filename'"
    save "`filename'", replace
    clear
}

use "`filename'", clear
duplicates drop
rename arrestnum arrestnumber
replace arrestnumber = arbknum if mi(arrestnumber) & ~mi(arbknum)
replace arrestloctn = address if mi(arrestloctn) & ~mi(address)
replace arresteename = name if mi(arresteename) & ~mi(name)
replace arresteeage = age if mi(arresteeage) & ~mi(age)
replace arrestdate = arbkdate if mi(arrestdate) & ~mi(arbkdate)
drop arbknum address name age arbkdate empty
fix_arrest_number
compress
save "`filename'", replace