

use  "../../data/intermediate/incident_persons_unique.dta", clear
append using "../../data/intermediate/duplicate_names_matchit_cleaned.dta"
append using "../../data/intermediate/duplicate_name_containments_cleaned.dta"
append using "../../data/intermediate/unresolved_duplicate_incident_persons.dta"

merge m:1 incidentnum using "../../data/intermediate/offenses_data_suspects.dta"

// try and use incidents also


