// purpose: programs to clean identifier variables in suspects data

cap program drop fix_arrest_number
program fix_arrest_number
    args arrestnumber
    replace arrestnumber = "0" + arrestnumber if strlen(arrestnumber) == 7
    replace arrestnumber = substr(arrestnumber, 1, 2) + "-" + substr(arrestnumber, 3, .) if strlen(arrestnumber) == 8
    replace arrestnumber = subinstr(arrestnumber, "-2014", "-14", .) if regexm(arrestnumber, "-2014$")
    replace arrestnumber = substr(arrestnumber, 2, .) if substr(arrestnumber, 1, 1) == "0" & strlen(arrestnumber) == 10
end

cap program drop fix_incident_number
program fix_incident_number
    args incidentnum
    replace incidentnum = subinstr(incidentnum, "O", "0", .)
    replace incidentnum = subinstr(incidentnum," -","-", .) 
    replace incidentnum = substr(incidentnum, 5, .) + "-" + servyr if strpos(incidentnum, "-") == 0 & strlen(incidentnum) == 11
    replace incidentnum = substr(incidentnum,2,12) if strlen(incidentnum) == 12 & substr(incidentnum,1,1) == "0"
    drop if mi(incidentnum)
    replace incidentnum = subinstr(incidentnum, "20140", "2014", .) if strpos(incidentnum, "20140") == 1 & strpos(incidentnum, "-") == 0
    replace incidentnum = subinstr(incidentnum, "20130", "2013", .) if strpos(incidentnum, "20130") == 1 & strpos(incidentnum, "-") == 0
    //keep if strlen(incidentnum) == 11
end

cap program drop fix_servnum_number
program fix_servnum_number
    args servnumid
    replace servnumid = subinstr(servnumid, "-01", "-2014", .) if strlen(servnumid) == 9
    cap assert substr(servnumid, 1, 1) == "0" if strlen(servnumid) == 15
    replace servnumid = substr(servnumid, 2, .) if strlen(servnumid) == 15
    replace servnumid = substr(servnumid, 2, .) if strlen(servnumid) == 15 & substr(servnumid, 1, 1) == "0"
    replace servnumid = subinstr(servnumid, " -", "-", .)
    replace servnumid = subinstr(servnumid, "/", "-", .)
end

