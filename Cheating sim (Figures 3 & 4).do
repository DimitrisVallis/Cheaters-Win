
clear
local truepos 0.1 0.5                   //Proportion of cheaters
local propcheat 0.02 0.1                //Proportion of true positives
local tier1 0.1							//Proportion of researchers in tier1
local sensitivity 1 2 3 4 5 6 7 8 9 10  //Sensitivity to positives
local i=0
local q=0
foreach true of local truepos {
	foreach pr of local propcheat {
		local q=`q'+1
		foreach s of local sensitivity {
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

egen newtrue=group(truepos)
egen new=group( propcheat )

/*Figure 3*/
twoway connected cheater2 sensitivity if tier==1 & new==1 & newtrue==1 || connected cheater2 sensitivity if tier==1 & new==2 & newtrue==1 || connected cheater2 sensitivity if tier==1 & new==1 & newtrue==2 || connected cheater2 sensitivity if tier==1 & new==2 & newtrue==2, xlabel(1(1)10) legend(order(1 "10% TP, 2% Cheaters" 2 "10% TP, 10% Cheaters" 3 "50% TP, 2% Cheaters" 4 "50% TP, 10% Cheaters")) graphregion(color(white)) xtitle("Sensitivity") ytitle("P(Cheat | Tier1)")

/*Figure 4*/
twoway connected cheater2 sensitivity if tier==2 & new==1 & newtrue==1 || connected cheater2 sensitivity if tier==2 & new==2 & newtrue==1 || connected cheater2 sensitivity if tier==2 & new==1 & newtrue==2 || connected cheater2 sensitivity if tier==2 & new==2 & newtrue==2, xlabel(1(1)10) legend(order(1 "10% TP, 2% Cheaters" 2 "10% TP, 10% Cheaters" 3 "50% TP, 2% Cheaters" 4 "50% TP, 10% Cheaters")) graphregion(color(white)) xtitle("Sensitivity") ytitle("P(Cheat | Tier1)")
