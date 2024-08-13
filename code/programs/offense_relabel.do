/*******************************************************************************
- APPEND THE OFFENSE CODES FOR EACH DATA SET, CREATE CODE TO CLEAN UP THE NAMES,
THEN CALCULATE MSHARE, FSHARE, AND MFSHARE.

*******************************************************************************/

******************************************
*FIRST CLEAN UCR OFFENSE CODE*
******************************************

******************************************
*FIX SPELLING ERRORS & COMBINE CATEGORIES*
******************************************
gen offense=ucr_offense
replace offense=strupper(offense)
replace offense=trim(offense)

replace offense="ACCIDENT-FIREARM" if ///
	offense=="FIRE-ARMS ACCID" | ///
	offense=="FIREARMS ACCIDENT" | ///
	offense=="INJURED FIREARM"

replace offense="ACCIDENT-OTHER" if ///
	offense=="HOME ACCIDENT NON-FATAL" | ///
	offense=="INJURED HOME"
	
replace offense="ACCIDENT-VEHICLE" if ///
	offense=="MOTOR VEHICLE ACCIDENT" | ///
	offense=="ACCIDENT MV" 

replace offense="AGG ASSAULT" if offense=="AGG ASSAULT - NFV" ///
	| ucr_offense=="AGG ASSAULT - FV" ///
	| ucr_offense=="AGGRAVATED ASSAULT"

replace offense="ASSAULT" if offense=="AASLTO" | offense=="OASLTO"

replace offense="ARSON" if offense=="ARSON/BOMB THREATS"

replace offense="BURGLARY" if offense=="BURGALRY" ///
	| offense=="BURGLARY-BUSINESS" ///
	| offense=="BURGLARY-RESIDENCE"

replace offense="BURGLARY-VEHICLE" if offense=="THEFT/BMV"
	
replace offense="FORGE/COUNTERFEIT" if ///
	offense=="FORGE & CONTERFEIT"| ///
	offense=="FORGE & COUNTERFEIT"

replace offense="FRAUD" if offense=="FRAUDW"

replace offense="DISORDERLY CONDUCT" if offense=="DRUNK & DISORDERLY"

replace offense="DWI" if offense=="DWI - ARREST ONLY"

replace offense="INJURY" if ///
	offense=="INJURED PUBLIC" | ///
	offense=="INJURY (PUBLIC ACCIDENT)" | ///
	offense=="INJURED OCCUPA" | ///
	offense=="OCCUP INJURY"
	
replace offense="INTOXICATION MANSLAUGHTER" if ///
	offense=="INTOX MANSLAUGHTER (DWI FATAL)"

replace offense="MISCHIEF/VANDALISM" if ///
	offense=="CRIMINAL MISCHIEF/VANDALI" | ///
	offense=="LANDALISM & CRIM MISCHIEF" | ///
	offense=="VANDALISM & CRIM MISCHIEF" | ///
	offense=="VANDALISM & CRIMINAL MISCHIEF" | ///
	offense=="VANDEL & CRIM MISCH" 
	
replace offense="ORGANIZED CRIME" if offense=="FENCE - ARREST REPORT ONLY" ///
	| offense=="ORANIZED CRIME"

replace offense="PROSTITUTION" if offense=="HUMAN TRAFFICKING"

replace offense="ROBBERY" if offense=="ROBBERY-BUSINESS" ///
	| offense=="ROBBERY-INDIVIDUAL"

replace offense="RUNAWAY" if offense=="RUNAWA"

replace offense="SEX OFFENSE/INDECENT" if ///
	offense=="SEX OFF & INDEC COND" | ///
	offense=="SEX OFF /INDECENT CONDUCT" | ///
	offense=="SEX OFF /INDICENT CONDUCT" | ///
	offense=="SEX OFFENSES/INDECENT" | ///
	offense=="SEX OFFENSES/INDECENT CO" | ///
	offense=="SEX OFFENSE /INDICENT CONDUCT" | ///
	offense=="RAPE"

replace offense="SUDDEN DEATH" if ///
	offense=="SUDDEN DEATH & FOUND BODIES" | ///
	offense=="SUDDEN DEATH&FOUND BODIES"

replace offense="THEFT-RETAIL" if ///
	offense=="THEFT ORG RETAIL" | ///
	offense=="THEFT/SHOPLIFT" | ///
	offense=="THEFT" | ///
	offense=="THEFT/"

replace offense="THEFT-OTHER" if offense=="OTHER THEFTS"

replace offense="TRAFFIC" if ///
	offense=="TRAFFIC NON HAZARDOUS" | ///
	offense=="TRAFFIC VIOLATION" | ///
	offense=="TRAFFIC HAZARDOUS"
	
replace offense="TRAFFIC FATALITY" if ///
	offense=="VEHICLE FATALITY"

replace offense="TRESPASS" if offense=="CRIMINAL TRESPASS"

replace offense="OTHER" if ///
	offense=="OTHERS" | ///
	offense=="CPW CH TO WEAPON - ARREST REPORT ONLY" | ///
	offense=="******" | ///
	offense=="VAG" | ///
	offense==""

***************************************************	
*CODE REMAINING UNCODED OFFENSES*
***************************************************	
	
*THEN USE OFFINCIDENT  VARIABLE*
*tab offense, sort //Uncoded: Not Coded, Miscellaneous, Other
gen nocode=offense=="OTHER" ///
	| offense=="NOT CODED" ///
	| offense=="MISCELLANEOUS" ///
	| offense=="INVESTIGATION OF" ///
	| offense==""
tab nocode //






*Replace all no codes when same fields are in offincident*

replace offincident=strtrim(offincident)
replace offincident=stritrim(offincident)

replace offense="ACCIDENT-FIREARM" if nocode==1 ///
	& (strpos(offincident,"ACC")>0 | strpos(offincident,"DISCHARG")>0 ) ///
	& strpos(offincident,"FIREARM")>0 

replace offense="ACCIDENT-OTHER" if nocode==1 ///
	& strpos(offincident,"ACC")>0 ///
	& strpos(offincident,"FIREARM")==0 ///
	& strpos(offincident,"VEH")==0 

replace offense="ACCIDENT-VEHICLE" if nocode==1 ///
	& strpos(offincident,"ACC")>0 ///
	& strpos(offincident,"VEH")>0 

replace offense="ALARM INCIDENT" if nocode==1 ///
	& strpos(offincident,"FAL")>0 ///
	& strpos(offincident,"ALARM")>0
	
replace offense="AGG ASSAULT" if nocode==1 ///
	& (strpos(offincident,"ASS")>0 ///
	| strpos(offincident,"ASLT")>0) ///
	& strpos(offincident,"AGG")>0 
	
replace offense="ANIMAL BITE" if nocode==1 ///
	& strpos(offincident,"ANIMAL")>0 ///
	& strpos(offincident,"BITE")>0 

replace offense="ARSON" if nocode==1 ///
	& strpos(offincident,"ARSON")>0 

replace offense="ASSAULT" if nocode==1 ///
	& (strpos(offincident,"ASS")>0 ///
	| strpos(offincident,"ASLT")>0) ///
	& strpos(offincident,"AGG")==0 

replace offense="BURGLARY-BUSINESS" if nocode==1 ///
	& strpos(offincident,"BURG")>0 ///
	& (strpos(offincident,"BUS")>0 ///
	| strpos(offincident,"BUILD")>0)
	
replace offense="BURGLARY-RESIDENCE" if nocode==1 ///
	& strpos(offincident,"BURG")>0 ///
	& strpos(offincident,"BUS")==0 ///
	& strpos(offincident,"BUILD")==0 ///
	& strpos(offincident,"VEH")==0 ///
	& strpos(offincident,"BMV")==0 ///
	& strpos(offincident,"B.M.V.")==0 

replace offense="BURGLARY-VEHICLE" if nocode==1 ///
	& ((strpos(offincident,"BURG")>0 ///
	& strpos(offincident,"VEH")>0) ///
	| strpos(offincident,"BMV")>0 ///
	| strpos(offincident,"B.M.V.")>0) 

replace offense="DEADLY CONDUCT" if nocode==1 ///
	& strpos(offincident,"DEAD")>0 & strpos(offincident,"COND")>0
	
replace offense="DISORDERLY CONDUCT" if nocode==1 ///
	& strpos(offincident,"DISORDERLY")>0 ///
	| strpos(offincident,"DIS COND")>0
	
replace offense="DWI" if nocode==1 ///
	& (strpos(offincident,"DWI")>0 ///
	| strpos(offincident,"DUI")>0)

replace offense="EMBEZZLEMENT" if nocode==1	///
	& strpos(offincident,"EMBEZZLEMENT")>0 

replace offense="ESCAPE" if nocode==1 ///
	& strpos(offincident,"ESCAPE")>0 	

replace offense="EVADING" if nocode==1 ///
	& ( strpos(offincident,"EVA")>0 ///
	| strpos(offincident,"FLEE")>0 ///
	| strpos(offincident,"EVEAD")>0 ) 	

replace offense="FAIL TO ID" if nocode==1 ///
	& strpos(offincident,"FAIL")>0 ///
	& (strpos(offincident,"ID")>0 ///
	| strpos(offincident,"PRESENT DL")>0 ///
	| strpos(offincident,"PRESENT DR")>0 )

replace offense="FALSE REPORT" if nocode==1 ///
	& strpos(offincident,"FALSE")>0 ///
	& strpos(offincident,"REPORT")>0 
	
replace offense="FORGE/COUNTERFEIT" if nocode==1 ///
	& (strpos(offincident,"FORGE")>0 ///
	| strpos(offincident,"COUNTERFEIT")>0 )
	
replace offense="FOUND" if nocode==1 ///
	& strpos(offincident,"FOUND")>0 ///
	& strpos(offincident,"PROP")>0 

replace offense="FRAUD" if nocode==1 ///
	& strpos(offincident,"FRAUD")>0 
	
replace offense="GAMBLING" if nocode==1 ///
	& strpos(offincident,"GAMBLING")>0 
	
replace offense="ILLEGAL DUMPING" if nocode==1 ///
	& strpos(offincident,"DUMP")>0 ///
	& strpos(offincident,"ILL")>0

replace offense="IMPERSONATION" if nocode==1 ///
	& strpos(offincident,"IMPERSON")>0

replace offense="INJURY" if nocode==1 ///
	& strpos(offincident,"INJUR")>0

replace offense="INTERFERE 911 CALL" if nocode==1 ///
	& (strpos(offincident,"INTER")>0 | strpos(offincident,"ABUS")>0) ///
	& (strpos(offincident,"CALL")>0 |strpos(offincident,"911")>0)

replace offense="INVALID LICENSE" if nocode==1 ///
	& (strpos(offincident,"DWLI")>0 ///
	| strpos(offincident,"DWLS")>0 ///
	| strpos(offincident,"NO DL")>0 ///
	| strpos(offincident,"EXPIRED DL")>0 ///
	| strpos(offincident,"FICTITIOUS LICENSE PLATE")>0)
	
replace offense="KIDNAPPING" if nocode==1 ///
	& (strpos(offincident,"KIDNAP")>0 ///	
	| strpos(offincident,"KIDDNAP")>0 ///
	| strpos(offincident,"KIPNAP")>0 )
	
replace offense="LIQUOR OFFENSE" if nocode==1 ///
	& (strpos(offincident,"POSS ALCOHOL")>0 ///
	| strpos(offincident,"POS ALCOHOL")>0 ///
	| strpos(offincident,"OPEN CONTAINER")>0)

replace offense="MISCELLANEOUS REPORT" if nocode==1 ///
	& (strpos(offincident,"MIR")>0 ///
	| strpos(offincident,"M I R")>0 ///
	| strpos(offincident,"M.I.R")>0 ///
	| strpos(offincident,"M. I. R")>0 )

replace offense="MISCHIEF/VANDALISM" if nocode==1 ///
	& (strpos(offincident,"MISCH")>0 ///
	| strpos(offincident,"VANDAL")>0)

replace offense="MISSING PERSON" if nocode==1 ///
	& strpos(offincident,"MISSING")>0 ///
	& strpos(offincident,"PERSON")>0

replace offense="MURDER" if nocode==1 ///
	& (strpos(offincident,"MURDER")>0 ///
	| strpos(offincident,"HOMICIDE")>0 )
	
replace offense="NARCOTICS & DRUGS" if nocode==1 ///
	& (strpos(offincident,"POS")>0 & ///
	(strpos(offincident,"MARIJ")>0 ///
	| strpos(offincident,"HEROIN")>0 ///
	| strpos(offincident,"INHALANT")>0 ///
	| strpos(offincident,"DRUG")>0 ///
	| strpos(offincident,"DRUGS")>0 ///
	| strpos(offincident,"CS")>0 ///
	| strpos(offincident,"CONT")>0 ///
	| strpos(offincident,"CONTROL")>0 ///
	| strpos(offincident,"COCA")>0 ///
	| strpos(offincident,"COCAINE")>0 ///
	| strpos(offincident,"SUBSTANCE")>0)) ///
	| strpos(offincident,"DRUG SALE")>0 ///
	| strpos(offincident,"CONT SUB PEN GRP")

replace offense="OFFENSE AGAINST CHILD" if nocode==1 ///
	& strpos(offincident,"OFFENSE AGAINST CHILD")>0
	
replace offense="OPERATING SALVAGE VEHICLE" if nocode==1 ///
	& ((strpos(offincident,"OP")>0 & strpos(offincident,"SALV")>0) ///
	| strpos(offincident,"SALVAGE V")>0)

replace offense="ORGANIZED CRIME" if nocode==1 ///
	& strpos(offincident,"ORGANIZED")>0

replace offense="OTHER-FELONY" if nocode==1 ///
	& strpos(offincident,"OTHER OFFENSE - FELONY")>0

replace offense="OTHER-MISDEMEANOR" if nocode==1 ///
	& strpos(offincident,"OTHER OFFENSE - MISDEMEANOR")>0

replace offense="PROSTITUTION" if nocode==1 ///
	& strpos(offincident,"PROSTIT")>0 ///
	| strpos(offincident,"ENGAGE IN PROS")>0 ///
	| (strpos(offincident,"TRAFFIC")>0 ///
	& (strpos(offincident,"HUMAN")>0 ///
	| strpos(offincident,"PERSON")>0))

replace offense="PUBLIC INTOXICATION" if nocode==1 ///
	& (strpos(offincident,"INTOX")>0 ///  
	| strpos(offincident,"INNTOX")>0 ///
	| strpos(offincident,"PI")>0 ///
	| strpos(offincident,"P.I")>0 ///
	| strpos(offincident,"INOX")>0 )
	
replace offense="RESIST ARREST" if nocode==1 ///
	& (strpos(offincident,"RESIST")>0 ///
	| strpos(offincident,"RES ")>0 ///
	| strpos(offincident,"RES/ARREST")>0) ///
	& (strpos(offincident,"ARREST")>0 ///
	| strpos(offincident,"SEARCH")>0)

replace offense="RETALIATION" if nocode==1 ///
	& (strpos(offincident,"RETALIA")>0 ///
	| strpos(offincident,"RETAILIA")>0 ///
	| strpos(offincident,"RETAILA"))
	
replace offense="ROBBERY" if nocode==1 ///
	& (strpos(offincident,"ROBBERY")>0 ///
	| strpos(offincident,"ROBERY")>0 ///
	| strpos(offincident,"AGG ROB")>0 )

replace offense="RUNAWAY" if nocode==1 ///
	& strpos(offincident,"RUNAW")>0 	
	
replace offense="SEIZED PROPERTY" if nocode==1 ///
	& strpos(offincident,"SEIZE")>0 /// 
	& strpos(offincident,"PROP")>0 

replace offense="SEX OFFENSE/INDECENT" if nocode==1 ///
	& strpos(offincident,"SEX")>0 /// 
	| strpos(offincident,"INDEC")>0 
	
replace offense="SUDDEN DEATH" if nocode==1 ///
	& strpos(offincident,"SUDDEN")>0 ///
	& strpos(offincident,"DEATH")>0 

replace offense="SUICIDE" if nocode==1 ///
	& strpos(offincident,"SUICIDE")>0  

replace offense="SUSPICIOUS PERSON" if nocode==1 ///
	& (strpos(offincident,"SUSPIC")>0 ///
	| strpos(offincident,"SUSP PERS")>0)

replace offense="TAMPERING" if nocode==1 ///
	& strpos(offincident,"TAMP")>0 

replace offense="TERRORISTIC THREAT" if nocode==1 ///
	& strpos(offincident,"THREAT")>0 ///
	| strpos(offincident,"TERRORISTIC")>0   

replace offense="THEFT-OTHER" if nocode==1 ///
	& strpos(offincident,"THEFT")>0 ///
	& strpos(offincident,"RETAIL")==0  

replace offense="THEFT-RETAIL" if nocode==1 ///
	& strpos(offincident,"THEFT")>0 ///
	& strpos(offincident,"RETAIL")>0  

replace offense="TRAFFIC" if  nocode==1 ///
	& (strpos(offincident,"TRAF VIO")>0 ///
	| strpos(offincident,"TRAFFIC STOP")>0 ///
	| strpos(offincident,"FAIL SIGNAL INTENT")>0 ///
	| strpos(offincident,"FAIL TO SIGNAL INTENT")>0 ///
	| strpos(offincident,"DR WRONG SIDE OF STREET")>0 ///
	| strpos(offincident,"TRAFFIC VIOLATION")>0 ///
	| strpos(offincident,"FAIL MAINT FIN RESP")>0 ///
	| strpos(offincident,"FAIL MAINT FINAN RESPON")>0 ///
	| strpos(offincident,"TOW")>0 ///
	| strpos(offincident,"DR WITHOUT LIGHTS")>0 ///
	| strpos(offincident,"RAN RED LIGHT")>0 ///
	| strpos(offincident,"RAN STOP SIGN")>0 ///
	| strpos(offincident,"PED. IN THE ROADWAY")>0 ///
	| strpos(offincident,"PEDESTRIAN IN ROADWAY")>0 ///
	| strpos(offincident,"PEDESTRAIN IN ROADWAY")>0 ///
	| strpos(offincident,"SOLICIT VEHICLE")>0 ///
	| strpos(offincident,"SOLICIT/VEHICLE")>0 ///
	| strpos(offincident,"SOL/OCC/VEH")>0 ///
	| strpos(offincident,"STREET BLOCKAGE")>0 ///
	| strpos(offincident,"FAIL MAINT SINGLE LANE")>0 ///
	| strpos(offincident,"SOLICITATION OF VEHICLE")>0 ///
	| strpos(offincident,"SOLICITATION BY PED")>0 ///
	| strpos(offincident,"SEATBELT")) ///
	& strpos(offincident,"PERSONS")==0 ///
	& strpos(offincident,"HUMAN")==0

replace offense="TRAFFIC FATALITY" if nocode==1 ///
	& (strpos(offincident,"TRAFFIC FATALITY")>0 ///
	| (strpos(offincident,"CRASH")>0) ///
	& strpos(offincident,"DEATH")>0)

replace offense="TRESPASS" if nocode==1 & ///
	(strpos(offincident,"TRESPASS")>0 ///
	| strpos(offincident,"TRESSPASS")>0 ///
	| strpos(offincident,"TREASPASS")>0 ///
	| strpos(offincident,"CT WARN")>0 ///
	| strpos(offincident,"TESPASS")>0 ///
	| strpos(offincident,"TREPASS")>0 ///
	| strpos(offincident,"TREAPASS")>0 ///
	| strpos(offincident,"TRASSPASS")>0 ///
	| strpos(offincident,"TERSPASS")>0 ///
	| strpos(offincident,"TRSEPASS")>0 ///
	| strpos(offincident,"TRESASS")>0 ///
	| strpos(offincident,"TERSASS")>0 ///
	| strpos(offincident,"TESSPASS")>0 ///
	| strpos(offincident,"CRIM TRES")>0 ///
	| strpos(offincident,"CRIMINAL TRES")>0 ///
	| strpos(offincident,"TRES PASS")>0 ) ///
	| strpos(offincident,"STALK")
	
replace offense="UNLAWFUL RESTRAINT" if nocode==1 ///
	& strpos(offincident,"UNL")>0 ///
	& strpos(offincident,"RESTR")>0 
	
replace offense="UUMV" if nocode==1 ///
	& (strpos(offincident,"UUMV")>0 ///
	| strpos(offincident,"UUV")>0 ///
	| strpos(offincident,"UNAUTHORIZED USE OF MOTOR")>0 ///
	| strpos(offincident,"UNAUTHORIZE USE VEH")>0 ///
	| strpos(offincident,"UNAUTHORISE USE VEH")>0 ///
	| strpos(offincident,"UUNV")>0 )
	
replace offense="WARRANT" if nocode==1 ///
	& strpos(offincident,"WARRANT")>0 

replace offense="WEAPONS" if nocode==1 ///
	& strpos(offincident,"WEAPON")>0 ///
	| (strpos(offincident,"POS")>0 & strpos(offincident,"FIREARM")>0)

drop nocode
gen nocode=offense=="OTHER" ///
	| offense=="NOT CODED" ///
	| offense=="MISCELLANEOUS" ///
	| offense=="INVESTIGATION OF" ///
	| offense==""
tab nocode //691,094  observations

bysort offincident nocode: gen N=_N if nocode==1
bysort offincident nocode: gen n=_n==1 if nocode==1

noisily tab offincident if nocode==1 & N>100 , sort
drop n N



