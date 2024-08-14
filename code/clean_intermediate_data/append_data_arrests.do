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
