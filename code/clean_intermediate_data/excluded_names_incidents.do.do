use "../../data/intermediate/duplicate_incidents.dta", clear
keep incidentnum id name
isid incidentnum id
tempfile file1
save `file1'

use  "../../data/intermediate/duplicate_name_containments_cleaned.dta", clear
keep incidentnum id*
expand 7
sort incidentnum id01
gen id = .
forvalues i = 1/7 {
    bys incidentnum: replace id = id0`i' if _n == `i'
}
keep incidentnum id
drop if mi(id)
tempfile file2
save `file2'

use "../../data/intermediate/duplicate_names_matchit_cleaned.dta", clear
keep incidentnum id0*
expand 8
sort incidentnum id01
gen id = .
forvalues i = 1/8 {
    bys incidentnum: replace id = id0`i' if _n == `i'
}
keep incidentnum id
drop if mi(id)
duplicates drop
tempfile file3
save `file3'

use "../../data/intermediate/duplicate_incidents.dta", clear
merge 1:1 incidentnum id using `file2', assert(match master) 
ren _m _m1
merge 1:1 incidentnum id using `file3', assert(match master)
ren _merge _m2

preserve
keep if _m1 != 3 & _m2 != 3

local prefixes age sex race address apt city state inv data_source 
foreach var in `prefixes' {
    local maxnum = 0
    
    ds `var'*
    local varlist_derived "`r(varlist)'"
    foreach v of varlist `varlist_derived' {
        local num = substr("`v'", length("`var'") + 1, .)
        
        if regexm("`num'", "^[0-9]+$") {
            if real("`num'") > `maxnum' {
                local maxnum_`var' = real("`num'")
            }
        }
    }
}

foreach var in `prefixes' {
    forvalues i = 1 /`maxnum_`var'' {
        forvalues j = 2/`maxnum_`var'' {
            if `i' <`j' {
            cap replace `var'`j' = "" if `var'`j' == `var'`i'
            }
        }
    }
}

foreach var in `prefixes' {
    forvalues i = 1 /`maxnum_`var'' {
        forvalues j = 2/`maxnum_`var'' {
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
save "../../data/intermediate/unresolved_duplicate_incident_persons.dta"

restore 