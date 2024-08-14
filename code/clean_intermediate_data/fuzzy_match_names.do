use "../../data/intermediate/duplicate_incident_notcontainments.dta", clear

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

save "../data/matchit_results.dta"

use "/Users/vaidehiparameswaran/Documents/Github/arrests/DallasArrests/data/matchit_results.dta", clear


drop if similscore == 1
order id id1 name name1
bys incidentnum: gen tag = (id[_n] == id1[_n-1] & id[_n-1] == id1[_n])
drop if tag 
drop tag

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
//keep if incidentnum == "051836-2011"

cap program drop identify_transitive 
program define identify_transitive 
    group_twoway name1 name, gen(unique_id)
end 
runby identify_transitive, by(incidentnum)

ren name1 name_max
ren id1 id_max
bys incidentnum unique_id : gen x = _N

cap program drop reshape
program define reshape 
    local N = _N

    forvalues i = 2/`N' {
        gen name`i' = ""
        gen id`i' = .
        gen name_`i' = ""
        gen id_`i' = .
    }

    forvalues i = 2 / `N' {
    replace name`i' = name[`i']  if _n == 1 & mi(name`i')
    replace id`i' = id[`i']  if _n == 1 & mi(id`i')
    }
    forvalues i = 2 / `N' {
    replace name_`i' = name_max[`i']  if _n == 1 & mi(name_`i')
    replace id_`i' = id_max[`i']  if _n == 1 & mi(id_`i')
    }

    keep if _n == 1
end 

preserve 
keep if x > 1
runby reshape, by(incidentnum unique_id)
tempfile reshaped
save `reshaped', replace
restore

drop if x > 1
drop x
append using `reshaped'

ren name main_name
ren id main_id

local varlist
foreach var of varlist name_* {
    local varlist `varlist' `var'
}
local counter 20
foreach var of local varlist {
    rename `var' name`counter'
    local counter = `counter' + 1
}
local varlist
foreach var of varlist id_* {
    local varlist `varlist' `var'
}
local counter 20
foreach var of local varlist {
    rename `var' id`counter'
    local counter = `counter' + 1
}

/* forvalues i = 1/37 {
    local z = `i' + 1
    forvalues j = `z' /38 {
    if `i' != !`j' {
    replace name`j' = "" if name`j' == `var'`i'
    }
}
} */


tempfile 