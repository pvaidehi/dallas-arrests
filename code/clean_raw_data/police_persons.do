*-------------------------------------*
* POLICE PERSON 
*-------------------------------------*

// file 1
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_12_28_16.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race address apt city state age ageatoffensetime name edate involvement
isid incidentnum servnumid 
replace servyr = "2015" if servyr == "2105"
clean_all
keep if !mi(name)
tempfile 12_28_16
save 	`12_28_16'

// file 2
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_6_23_17.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race address apt city state age ageatoffensetime name edate involvement
isid incidentnum servnumid 
tostring servyr, replace force
replace servyr = "2015" if servyr == "2105"
clean_all
append using `12_28_16'
duplicates drop 
duplicates drop incidentnum servnumid name age sex race address, force
keep if !mi(name)
tempfile 6_23_17
save 	`6_23_17'

// file 3
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_11_17_17.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race address apt city state age ageatoffensetime name edate involvement
isid incidentnum servnumid 
tostring servyr, replace force
replace servyr = "2015" if servyr == "2105"
clean_all
append using `6_23_17'
duplicates drop 
duplicates drop incidentnum servnumid name age sex race address, force
keep if !mi(name)
tempfile 11_17_17
save 	`11_17_17'

// file 4
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_7_19_18.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race address apt city state age ageatoffensetime name edate involvement
isid incidentnum servnumid 
tostring servyr, replace force
replace servyr = "2015" if servyr == "2105"
clean_all
append using `11_17_17'
duplicates drop 
duplicates drop incidentnum servnumid name age sex race address, force
keep if !mi(name)
tempfile 7_19_18
save 	`7_19_18', replace

// file 5
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_7_19_19.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race age ageatoffensetime name edate involvement
isid incidentnum servnumid 
replace servyr = subinstr(servyr, ",", "", .)
replace servyr = "2019" if servyr == "2109"
destring age ageatoffensetime, replace force
clean_names 
clean_gender 
clean_race
append using `7_19_18'
duplicates drop 
keep if !mi(name)
tempfile 7_19_19
save 	`7_19_19'

// file 6
import delimited "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/raw/Police_Person_3_11_20.csv", clear
keep if involvement=="Suspect" | involvement=="Arrested Person" | involvement=="Arrestee"
keep incidentnum servyr servnumid sex race age ageatoffensetime name edate involvement
isid incidentnum servnumid
replace servyr = subinstr(servyr, ",", "", .)
destring age ageatoffensetime, replace force
clean_names 
clean_gender 
clean_race
append using `7_19_19'
duplicates drop 
keep if !mi(name)
tostring age, replace
gen data_source = "police-persons"
save "/Users/vaidehiparameswaran/Dropbox/arrests/dallas-arrests/data/intermediate/police_persons.dta", replace


