*-------------------------------------*
* NOV 2019
*-------------------------------------*

// nov 2019 - 2005-2011
import delimited "../../data/raw/Suspect_2005_2011.csv", clear
duplicates drop
tostring servyr, replace force
destring age, replace force
rename incidentnum ix
format ix %11.0f
tostring ix, gen(ix2) format(%11.0f)
gen incidentnum = substr(ix2,5,.) + "-" + substr(ix2,1,4)
drop ix ix2 
fix_incident_number
clean_all
destring servyr, replace force
keep if !mi(name)

// 2011 is common to 2 datasets
preserve
keep if servyr == 2011
tempfile persons_nov_2011
save `persons_nov_2011', replace
restore 

keep if servyr != 2011
tempfile persons_nov_05_10
save     `persons_nov_05_10'

// nov 2019 - 2011-2014
import delimited "../../data/raw/Suspect_2012_2014.csv", clear
tostring servyr, replace force
destring age, replace force
rename incidentnum ix
format ix %11.0f
tostring ix, gen(ix2) format(%11.0f)
gen incidentnum = substr(ix2,5,.) + "-" + substr(ix2,1,4)
drop ix ix2 
fix_incident_number
clean_all
destring servyr, replace force
keep if !mi(name)

// 2011 is common to 2 datasets
preserve 
keep if servyr == 2011
joinby incidentnum using `persons_nov_2011', unmatched(both) update
drop _m
save `persons_nov_2011', replace
restore

keep if servyr != 2011
append using `persons_nov_05_10'
append using `persons_nov_2011'
keep incidentnum servyr sex race address city state age name edate involvement
duplicates drop

tempfile persons_nov_04_14
save     `persons_nov_04_14', replace

// nov 2019 - 2013-2019
import delimited "../../data/raw/Suspect_2014_2019.csv", clear
fix_incident_number   // about 18 bad IDs 
clean_all
destring servyr, replace force
keep if !mi(name)

preserve
keep if servyr > 2014
tempfile persons_nov_15_19
save `persons_nov_15_19', replace
restore

drop if servyr > 2014
tempfile persons_nov_11_14
save     `persons_nov_11_14'

// append 2004-2010 & 2015-2019
use `persons_nov_04_14', replace
keep if servyr < 2011
append using `persons_nov_15_19'
duplicates drop
tempfile persons_nov_1
save     `persons_nov_1', replace

// deal with 2011-2014 
use `persons_nov_04_14', replace 
drop if servyr < 2011

// append all
append using `persons_nov_11_14'
append using `persons_nov_1'
duplicates drop
keep servyr edate involvement name address city state race sex age incidentnum persontype ageatoffensetime ethnic
gen data_source = "nov2019"
tostring servyr, replace
tostring age, replace
save "../../data/intermediate/nov_2019_suspects.dta", replace
