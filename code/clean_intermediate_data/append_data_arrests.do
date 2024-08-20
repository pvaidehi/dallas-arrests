// purpose: create a long list of all arrestees across datasets

// set environment
clear
set more off
set excelxlsxlargefile on
include "../programs/clean_person_chars.do"
include "../programs/standardise_ids.do"

// import data
use "../../data/intermediate/2000_present_arrests.dta", clear
append using "../../data/intermediate/police_arrests_persons.dta"
append using "../../data/intermediate/july_2018_arrests.dta"
append using "../../data/intermediate/nov_arrest_persons.csv"
replace arrestnumber = arbknum if mi(arrestnumber) & ~mi(arbknum)
replace arrestloctn = address if mi(arrestloctn) & ~mi(address)
replace arresteename = name if mi(arresteename) & ~mi(name)
replace arresteeage = age if mi(arresteeage) & ~mi(age)
replace arrestdate = arbkdate if mi(arrestdate) & ~mi(arbkdate)
replace hladdress = haddress if mi(hladdress) & ~mi(haddress)
replace hlapt = hapt if mi(hlapt) & ~mi(hapt)
replace hlcity = hcity if mi(hlcity) & ~mi(hcity)
replace hlstate = hstate if mi(hlstate) & ~mi(hstate)
replace ageatarresttime = ageatarresttime if mi(ageatarresttime) & ~mi(ageatarresttime)    

drop name age arbkdate
keep incidentnum arrestyr servyr arrestnum arresteename  sex race hladdress hlapt hlcity hlstate arresteeage ageatarrest arrestdate personid ethnic
duplicates drop
gen inv = "Arrested"
ren arresteename name
ren hladdress address
ren hlcity city
ren hlstate state
ren hlapt apt
clean_all

bys incidentnum name: gen mult_entries = _N
bys arrestnumber name: gen mult_entries2 = _N

//fix_incident_number
local varlist age sex race address apt city state inv data_source
