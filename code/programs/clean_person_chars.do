// name
cap program drop clean_names 
program clean_names 
    replace name = stritrim(name)
    replace name = strtrim(name)
    replace name = subinstr(name, ",,", ",", .)
    replace name = subinstr(name, ", ,", ",", .)
    replace name = subinstr(name, "********", "", .)
    
    local to_replace "UNK UNKNOWN NULL UNKOWN UNK SUSPS UNK, UNK UNKN UNKNOWN SUSP UNKNOWN SUSPECT UNKNOWN SUSPECTS UNKNOWN, UNKNOWN UNKNOWNW UNKNWON UNK SUSP XXX"
    foreach val in `to_replace' {
        replace name = "" if name == "`val'"
    }
    replace name = "" if inlist(name, "UNK SUSP", "UNKNOWN SUSP", "UNKNOWN SUSPS", "UNKOWN, UNKNOWN", "UNKNOWN SUSPECT", "N/A", "XXXX") | inlist(name, "UNK BLACK MALE", "UNK NAME", "UNK MALE", "XXXXXXX", "UNKNOWN,UNKNOWN", "UNK,UNK", "XX, XX", "UNKNOWN MALE")
    replace name = "" if strpos(name, "SUSPECT") | strpos(name, "UNKNOWN, UNK") | strpos(name, "UNK, UNK") | strpos(name, "XX,XX") | strpos(name, "UNK,UNK,") | strpos(name, "UNK.") | strpos(name, "UNKNOWN, FLED")
    replace name = "" if strpos(name, "FLED") & strpos(name, "UNK") 
    replace name = "" if strpos(name, "FLID") & strpos(name, "UNK")
    gen match = regexm(name, "^[UNKOW]+$")
    replace name = "" if match & name != "KOKO" & name != "NUNU"
    drop match
    gen match = regexm(name, "(?i)UNK.*SUSP")
    replace name = "" if match
    drop match
    replace name = subinstr(name, ", ", ",", .)
    replace name = subinstr(name, " ", ",", .)
    replace name = subinstr(name, `"'"', "", .)
    replace name = regexr(name, ",$", "") if substr(name, -1, 1) == ","     
    replace name = subinstr(name, ".", ",", .)
    gen to_drop = regexm(name, "^(SUSP[#|,])[0-9]+$")
    replace name = "" if to_drop
    drop to_drop
end 

// gender 
cap program drop clean_gender 
program clean_gender
    replace sex = strtrim(sex)
    replace sex = "" if inlist(sex, "Unk", "Unknown", "TEST")
end 

// race
cap program drop clean_race
program clean_race
    replace race = strtrim(race)
    replace race = "" if inlist(race, "Unk", "Unknown", "NULL", "TEST", "Test")
    replace race = "" if inlist(race, "Null", "N", "A", "U", "O")
    replace race = "Native American"  if strpos(race, "Indian")
    replace race = "Asian American/Pacific Islander" if strpos(race, "Asian")
    replace race = "White" if race == "W"
    replace race = "Black" if race == "B"
    cap confirm variable ethnic
    if _rc != 0 {
    replace race = "Hispanic" if inlist(race, "Latin", "Latin/Hispanic", "Hispanic or Latino", "Latin / Hispanic")
    }

    if _rc == 0 {
    replace race = "Hispanic" if inlist(race, "Latin", "Latin/Hispanic", "Hispanic or Latino", "Latin / Hispanic") | inlist(ethnic, "Hispanic or Latino")
    }
end 

// address
cap program drop clean_address
program clean_address
    replace address = stritrim(address)
    replace address = strtrim(address)

    local to_replace `"UNK" "UNKNOWN" "NULL" "UNKOWN" "UNK SUSPS" "UNK, UNK" "UNKN" "UNKNOWN SUSP" "UNKNOWN SUSPECT" "UNKNOWN SUSPECTS" "UNKNOWN, UNKNOWN" "UNKNOWNW" "UNKNWON" "UNK SUSP" "UNKNOWN ADDRESS" "UNK UNKNOWN"'
    foreach val in `to_replace' {
        replace address = "" if address == `"`val'"'
    }
    replace address = "" if address == "99999 UNKNOWN" | address == "9999 UNKNOWN" | address == "11111 UNKNOWN"
    gen match = regexm(address, "^[0-9]+ UNKNOWN$")
    replace address = "" if match
    drop match 

    replace state = strtrim(state)
    replace state = upper(state)
    replace city = strtrim(city)
end 

cap program drop clean_all
program clean_all 
    clean_names
    clean_gender
    clean_address
    clean_race
end 