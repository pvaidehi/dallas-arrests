*-------------------------------------*
* NOV 2019
*-------------------------------------*

insheet using "../../data/raw/ArrestandArrestee_11_2019_RAW.csv", clear
rename *, lower
gen servyr = arrestyr
tostring servyr, replace
fix_incident_number
fix_arrest_number
rename cfs_number dispatchnum
replace dispatchnum = "" if strlen(dispatchnum) != 10
tempfile file1
save `file1', replace

insheet using "../../data/raw/ArrestandArrestee_11_2019_2_RAW.csv", clear
rename *, lower
gen servyr = arrestyr
tostring servyr, replace
fix_incident_number
fix_arrest_number
rename cfs_number dispatchnum
replace dispatchnum = "" if strlen(dispatchnum) != 10
append using `file1'
duplicates drop
duplicates drop incidentnum arrestnumber name age ethnic race sex hlzip hlcity hlstate hladdress, force
isid arrestnumber
tostring arrestyr, replace
tostring transport3, replace
save "../../data/intermediate/nov_arrest_persons.csv", replace