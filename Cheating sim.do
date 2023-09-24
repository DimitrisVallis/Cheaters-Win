
clear
local propcheat 0.1  //Set probability of cheating
local truepos 0.1    //Set likelihood of a true positive
local tier1 0.1      //Set proportion of researchers in Tier 1
local sensitivity 5  //Set sensitivity level
local sim 1000		 //Set no. of simulations

foreach n of numlist 1/`sim'{
	set obs 10000
	gen inseq = _n
	gen probability = runiform()
	gen cheat = probability<=`propcheat' 
	gen results=0
	gen resultp = runiform()
	replace results =1 if resultp<=`truepos' 
	replace results =1 if cheat==1     
	gen tier=2
	gen runiform3 = runiform()
	replace tier =1 if runiform3<=`tier1' & results==0 
	replace tier = 1 if runiform3<=(`tier1'*`sensitivity') & results==1 
	gen tier1 = tier==1
	gen tier2 = tier==2
	qui tabulate cheat, generate(cheater)
	collapse cheater1 cheater2, by(tier) //Proportion of cheaters per simulation
	gen sensitivity=`sensitivity'
	gen propcheat = `propcheat'
	gen truepos = `truepos'
	tempfile Sim_`n'
	save `Sim_`n''
	clear
	}

//Collect results
use `Sim_1', replace
forvalues j=2/`sim' {
	append using `Sim_`j''
	tempfile Sim__`i'
	save `Sim__`i''
	}

//Calculate average proportion of cheaters and honest researchers in each Tier
collapse cheater1 cheater2, by(tier) 
gen Sensitivity=`sensitivity'
gen Prob_cheating = `propcheat'
gen True_positive = `truepos'
rename (cheater1 cheater2) (Honest Cheater)
mkmat Honest Cheater Sensitivity Prob_cheating True_positive, matrix(X)
matrix list X
