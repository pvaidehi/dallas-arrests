use "../../data/intermediate/duplicate_incident_notcontainments.dta", clear
ssc install matchit
ssc install freqindex
keep incidentnum name id
bys incidentnum: gen unique_id = incidentnum if _n == 1
egen group_id = group(incidentnum)
summ group_id
local incidents = r(max)

timer clear 1  
timer on 1    
quietly{
forvalues i = 1/`incidents' {
    preserve
    keep if group_id == `i'
    keep incidentnum name id
    local incum = incidentnum[1] 
    tempfile matchit`i'
    save `matchit`i''
    matchit id name using `matchit`i'', idu(id) txtu(name)  override
    gen incidentnum = "`incum'"
    save `matchit`i'', replace
    restore 
}
}
timer off 1 
use `matchit1', clear
forvalues i = 2/`incidents' {
    di `i'
    append using `matchit`i''
}

save "../data/intermediate/suspects_matchit_results.dta"

use "../../data/intermediate/suspects_matchit_results.dta", clear


drop if similscore == 1
order id id1 name name1
bys incidentnum: gen tag = (id[_n] == id1[_n-1] & id[_n-1] == id1[_n])
drop if tag 
drop tag

// deal with duplicate pairs of names
gen same_pairs = .

cap program drop pairs
program pairs
  local N = _N
        forvalues i = 1/`N' {
        forvalues j = 1/`N' {
            if `i' != `j' & `j' > `i' {
                if id[`i'] == id1[`j'] & id1[`i'] == id[`j'] {
                    replace same_pairs = 1 in `j'
                }
            }
        }
    }
end 
runby pairs, by(incidentnum)
replace same_pairs = 0 if same_pairs == .
drop if same_pairs == 1
drop same_pairs

keep if similscore > 0.75 
drop similscore

// identify same names by transitivity
cap program drop identify_transitive 
program define identify_transitive 
    group_twoway name1 name, gen(unique_id)
end 
runby identify_transitive, by(incidentnum)

ren name1 name_max
ren id1 id_max
bys incidentnum unique_id : gen x = _N

tempfile abc
save `abc', replace

use `abc', clear
cap program drop reshape_get_ids
program define reshape_get_ids 
    local N = _N

    forvalues i = 2/`N' {
        gen id`i' = .
        gen id_`i' = .
    }

    forvalues i = 2 / `N' {
    replace id`i' = id[`i']  if _n == 1 & mi(id`i')
    }
    forvalues i = 2 / `N' {
    replace id_`i' = id_max[`i']  if _n == 1 & mi(id_`i')
    }

    keep if _n == 1
end 

preserve 
keep if x > 1
runby reshape_get_ids, by(incidentnum unique_id)
tempfile reshaped
save `reshaped', replace
restore

use `abc', clear
drop if x > 1
drop x
append using `reshaped'

ren id main_id
ds id*
local vars = r(varlist)
local num = 1
foreach var of local vars {
    rename `var' id_match`num'
    local num = `num' + 1
}
drop name* x
order incidentnum main_id unique_id id_match*
reshape long id_match, i(incidentnum main_id) j(match_num) 
drop if mi(id_match)
ren main_id id
save "../../data/intermediate/suspects_matchit_ids.dta", replace


use "../../data/intermediate/duplicate_incidents.dta", clear
merge 1:m incidentnum id using  "../../data/intermediate/suspects_matchit_ids.dta", assert(master match) nogen
bys incidentnum: egen matched = total(id_match)

preserve 
keep if matched == 0
drop matched
tempfile unresolved_duplicates
save `unresolved_duplicates', replace
restore

keep if matched > 0
drop match_num unique_id
order incidentnum name id id_match 
drop if mi(id_match) & id == 1 
drop if id == id_match
duplicates drop


sort incidentnum id name
cap program drop group_names
program group_names
    local N = _N
    egen group_id = group(id) if !mi(id_match)
    forvalues i = 1/`N' {
        replace group_id = group_id[`i'] if id == id_match[`i']
    }
end
runby group_names, by(incidentnum)
order incidentnum name id id_match group_id

preserve 
keep if mi(group_id)
tempfile dup_incidents_uniq_persons
save `dup_incidents_uniq_persons', replace
restore 

drop if mi(group_id)
bys incidentnum group_id (name): gen unique_id = _n
sort incidentnum group_id (unique_id)
summ unique_id
local max = r(max)
//ren name name1
tostring unique_id, replace
replace unique_id = "0" + unique_id
ds incidentnum unique_id servyr group_id, not


preserve 
local varlist "`r(varlist)'"
reshape wide `varlist' , i(incidentnum group_id) j(unique_id) string

foreach var of varlist _all {
    count if mi(`var')
    if `r(N)' == _N {
        drop `var' 
    }
}
foreach v of varlist * {
    foreach w of varlist * {
        capture assert `v'==`w'
        if _rc==0 & "`v'"!="`w'" drop `w'
    }
}
foreach prefix in `prefixes' {
    ds `prefix'*, has(type string)
    local vars `r(varlist)'

    local numvars : word count `vars'
    forval j = 1/`=`numvars' - 1' {
        local var1 : word `j' of `vars'
        local var2 : word `=`j' + 1' of `vars'
        
        gen byte flag = (`var1' == `var2')
        replace `var2' = "" if flag
        drop flag
    }
}

foreach var of varlist _all {
    count if mi(`var')
    if `r(N)' == _N {
        drop `var' 
    }
}
local prefixes name age sex race address apt city state inv data_source

// Loop through each prefix and rename the variables
foreach prefix in `prefixes' {
    local i = 1
    foreach var of varlist `prefix'* {
        rename `var' `prefix'`i'
        local i = `i' + 1
    }
}

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
            replace `var'`j' = "" if `var'`j' == `var'`i'
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
save "../../data/intermediate/duplicate_names_matchit_cleaned.dta", replace


//STEWART,KASE - check in matchit results
