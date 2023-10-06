
clear
local propcheat 0.02 0.1 									//Proportion of cheaters
local truepos 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5	//Proportion of true positives
local tier1 0.1												//Proportion of researchers in tier1
local sensitivity 2 5										//Sensitivity to positives
local i=0
local q=0
foreach s of local sensitivity {
	foreach pr of local propcheat {
		local q=`q'+1
		foreach true of local truepos {
			local i=`i'+1
			foreach n of numlist 1/1000{
			clear
			set obs 10000
			gen inseq = _n
			gen probability = runiform()
			gen cheat = probability<=`pr' 
			gen results=0
			gen resultp = runiform()

			replace results =1 if resultp<=`true' 
			replace results =1 if cheat==1
			gen tier=2
			gen runiform3 = runiform()

			replace tier =1 if runiform3<=`tier1' & results==0 
			replace tier = 1 if runiform3<=(`tier1'*`s') & results==1 

			gen tier1 = tier==1
			gen tier2 = tier==2

			qui tabulate cheat, generate(cheater)
			collapse cheater1 cheater2, by(tier)
			gen sensitivity=`s'
			gen propcheat = `pr'
			gen truepos = `true'
			tempfile Sim_`n'
			save `Sim_`n''
			clear
			}
		disp "`q'"
		use `Sim_1', replace
		forvalues j=2/1000 {
			append using `Sim_`j''
			tempfile Sim__`i'
			save `Sim__`i''
			}
			
		collapse cheater1 cheater2, by(tier)
		gen sensitivity=`s'
		gen propcheat = `pr'
		gen truepos = `true'
		tempfile Sim_1_`i'
		save `Sim_1_`i''
		}

	disp "`q'"
	use `Sim_1_1', replace
	forvalues j=2/`i' {
		append using `Sim_1_`j''
		tempfile Sim_2_`q'
		save `Sim_2_`q''
		}
	}

	tempfile sim_all
	save `sim_all'
	}

egen new=group( propcheat )

/*Figure1*/
twoway connected cheater2 truepos if tier==1 & new==1 & sensitivity==2, lcolor(navy) || connected cheater2 truepos if tier==1 & new==2 & sensitivity==2, lcolor(maroon) || connected cheater2 truepos if tier==1 & new==1 & sensitivity==5, lcolor(green) || connected cheater2 truepos if tier==1 & new==2 & sensitivity==5, lcolor(orange) legend(order(1 "2% cheating, low sensitivity" 2 "10% cheating, low sensitivity" 3 "2% cheating, high sensitivity" 4 "10% cheating, high sensitivity")) graphregion(color(white)) xtitle("True Positive rate") ytitle("P(Cheat | Tier1)")

/*Figure 2*/
twoway connected cheater2 truepos if tier==2 & new==1 & sensitivity==2, lcolor(navy) || connected cheater2 truepos if tier==2 & new==2 & sensitivity==2, lcolor(maroon) || connected cheater2 truepos if tier==2 & new==1 & sensitivity==5, lcolor(green) || connected cheater2 truepos if tier==2 & new==2 & sensitivity==5, lcolor(orange) legend(order(1 "2% cheating, low sensitivity" 2 "10% cheating, low sensitivity" 3 "2% cheating, high sensitivity" 4 "10% cheating, high sensitivity")) graphregion(color(white)) xtitle("True Positive rate") ytitle("P(Cheat | Tier1)")
