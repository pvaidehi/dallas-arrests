
// check containment within 2+ copies
use "../../data/intermediate/duplicate_incidents.dta", clear
keep if mult_entries >= 2
summ mult_entries
local max = r(max)
gen length =  strlen(name)
sort incidentnum name (length)  id 
keep incidentnum name id  
forvalues i = 1 / `max' {
   bys incidentnum: gen contain`i'= (strpos(name[_n], name[_n-`i']) > 0) if _n > `i'
}
egen contain = rowtotal(contain*)
bys incidentnum: egen total_contain = total(contain)
keep if total_contain > 0


cap program drop identify_pairs
program define identify_pairs
gen pair_id = .
local pair_counter = 1
forvalues i = 1/`=_N' {
    local name1 = name[`i']
    forvalues j = 1/`=_N' {
        if `i' != `j' {
            local name2 = name[`j']
            if strpos("`name2'", "`name1'") | strpos("`name1'", "`name2'") {
                if pair_id[`i'] == . & pair_id[`j'] == . {
                    replace pair_id = `pair_counter' if _n == `i'
                    replace pair_id = `pair_counter' if _n == `j'
                    local pair_counter = `pair_counter' + 1

                }
                else if pair_id[`i'] == . {
                    replace pair_id = pair_id[`j'] if _n == `i'
                }
                else if pair_id[`j'] == . {
                    replace pair_id = pair_id[`i'] if _n == `j'
                }
            }
            if !strpos("`name2'", "`name1'") & !strpos("`name1'", "`name2'") {
                replace pair_id = 0 if pair_id[`i'] == . & pair_id[`j'] == . & _n == `i'
            }
        }
    }
}
end
runby identify_pairs, by(incidentnum)
drop if pair_id == . | pair_id == 0
bys incidentnum pair_id: gen total = _N
tempfile names_contained_3
save `names_contained_3'


//keep if incidentnum == "000681-2010" | 000244-2018


use "../../data/intermediate/duplicate_incidents.dta", clear
merge 1:1 incidentnum id using `names_contained_3', assert(match master)
keep if _merge == 3
drop contain1-contain65 _m
bys incidentnum pair_id: gen unique_id = _n
sort incidentnum pair_id (unique_id)
summ unique_id
local max = r(max)
local varlist age sex race address apt city state inv data_source

/* program define a 
foreach var in `varlist' {
    local maxnum = 0
    
    ds `var'*
    local varlist_derived "`r(varlist)'"
    foreach v of varlist `varlist_derived' {
        local num = substr("`v'", length("`var'") + 1, .)
        
        if regexm("`num'", "^[0-9]+$") {
            if real("`num'") > `maxnum' {
                local maxnum = real("`num'")
            }
        }
    }
    local max_index = `max' *  _N
    forvalues i = `=`maxnum' + 1' /  `max_index'{
        gen `var'`i' = ""
    }
    forvalues j = 1/_N {
        forvalues k = 2/_N {
        local i = 
        replace `var'`i' = `var'j[k] if _N >= `j' & _n == 1
    }
    }
}
end  */
/* runby a, by(incidentnum pair_id) */

save "../../data/intermediate/duplicate_name_containments.dta", replace
use "../../data/intermediate/duplicate_name_containments.dta", replace
drop total_contain contain total mult_entries 
tostring unique_id, replace
replace unique_id = "0" + unique_id
ds  incidentnum pair_id unique_id servyr, not

local varlist "`r(varlist)'"
reshape wide `varlist' , i(incidentnum pair_id) j(unique_id) string

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


/* 

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

// replace to missing if same value exists in previous variable
local varlist age sex race address apt city state inv data_source
foreach var in `varlist' {
    forvalues i = 1 /`max' {
        forvalues j = 2/`max' {
            if `i' <`j' {
            replace `var'`j' = "" if `var'`j' == `var'`i'
            }
        }
    }
}
 */











/* ren age13 age11
gen apt4 = apt5
ren city8 city7
foreach var in `varlist' {
    local maxnum = 0
    
    ds `var'*
    local varlist_derived "`r(varlist)'"
    foreach v of varlist `varlist_derived' {
        local num = substr("`v'", length("`var'") + 1, .)
        
        if regexm("`num'", "^[0-9]+$") {
            if real("`num'") > `maxnum' {
                local maxnum = real("`num'")
            }
        }
    }
    forvalues i = 2 /  `=`maxnum' ' {
        forvalues j =  3 / `=`maxnum' ' {
            replace `var'`i' = `var'`j' if mi(`var'`i') & !mi(`var'`j')
            replace `var'`j' = "" if mi(`var'`i') & !mi(`var'`j')
        }
    }
} */





/* drop  _m total_contain mult_entries 
local varlist age sex race address apt city state inv data_source

foreach var in `varlist' {
    local maxnum = 0
    
    ds `var'*
    local varlist_derived "`r(varlist)'"
    foreach v of varlist `varlist_derived' {
        local num = substr("`v'", length("`var'") + 1, .)
        
        if regexm("`num'", "^[0-9]+$") {
            if real("`num'") > `maxnum' {
                local maxnum = real("`num'")
            }
        }
    }
    
    forvalues i = `=`maxnum' + 1' / `=`maxnum' + 20' {
        gen `var'`i' = ""
        bys incidentnum pair_id (contain): replace `var'`i' = `var'1[`i'] if _N >= `i' & _n == 1

    }
}

sort incidentnum name (contain) 
forvalues i = 2 / `max' {
    gen name`i' = ""
} */


/* ds contain*
local varlist_derived "`r(varlist)'"
local maxnum = 0
foreach v of varlist `varlist_derived' {
    local num = substr("`v'", length("contain") + 1, .)
    
    if regexm("`num'", "^[0-9]+$") {
        if real("`num'") > `maxnum' {
            local maxnum = real("`num'")
        }
    }
} */
/* forvalues i = 2 / `=`maxnum' + 1' {
    qui summ contain
    local max_contain = r(max)
    local j = `i'-1
    replace name`i' = name[`i' - 1]   if contain`j' == 1 & contain == `max_contain'
} */
/* bys incidentnum: keep if _n == 1  */




save "../../data/intermediate/duplicate_name_containments.dta", replace
use "../../data/intermediate/duplicate_name_containments.dta", clear



local prefixes age race sex address city state zipcode data_source  id name inv servnumid

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


local prefixes age sex race address apt city state inv data_source

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