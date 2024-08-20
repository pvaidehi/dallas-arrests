*-------------------------------------*
// import may data and clean
*-------------------------------------*

// may 2019 - 2014-2019
import delimited "../../data/raw/PersonsGOLive.csv", encoding(ISO-8859-1) clear
tostring servyr, replace force
fix_incident_number
fix_servnum_number
drop if strlen(incidentnum) != 11
isid incidentnum servnumid 
keep incidentnum servyr servnumid sex race address apt city state age ageatoffensetime personid persontype name edate involvement ethnic
tempfile may_persons1
save 	`may_persons1'

// may 2019 - 2007-2014
import delimited "../../data/raw/Persons_B4GOLive.csv", encoding(ISO-8859-1) clear
tostring servyr, replace force
fix_incident_number
destring age, replace force
keep incidentnum servyr sex race address city state age name edate involvement

// the above datasets have no obs in common 
append using `may_persons1'
duplicates drop
clean_all
gen data_source = "may2019"
tostring age, replace
save "../../data/intermediate/may_2019_suspects.dta", replace
