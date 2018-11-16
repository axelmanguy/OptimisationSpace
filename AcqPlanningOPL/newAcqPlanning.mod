
/** Number of acquisition opportunities */
int NacquisitionWindowsSAT1 = ...;
int NacquisitionWindowsSAT2 = ...;
/** Acquisition range */
range AcquisitionWindows1 = 1..NacquisitionWindowsSAT1;
range AcquisitionWindows1PlusZero = 0..NacquisitionWindowsSAT1;
range AcquisitionWindows2 = 1..NacquisitionWindowsSAT2;
range AcquisitionWindows2PlusZero = 0..NacquisitionWindowsSAT2;

/** Index of the acquisition in the list of candidate acquisitions of the problem */
int CandidateAcquisitionIdxSAT1[AcquisitionWindows1] = ...;
int CandidateAcquisitionIdxSAT2[AcquisitionWindows2] = ...;
/** Index of the acquisition window in the list of windows associated with the same candidate acquisition */
int AcquisitionWindowIdxSAT1[AcquisitionWindows1] = ...;
int AcquisitionWindowIdxSAT2[AcquisitionWindows2] = ...;
/** Priority of the acquisition */
int AcquisitionPrioritySAT1[AcquisitionWindows1] = ...;
int AcquisitionPrioritySAT2[AcquisitionWindows2] = ...;
int CoefPriority1[a in AcquisitionWindows1] = NacquisitionWindowsSAT1*(1-AcquisitionPrioritySAT1[a]) + AcquisitionPrioritySAT1[a];
int CoefPriority2[a in AcquisitionWindows2] = NacquisitionWindowsSAT2*(1-AcquisitionPrioritySAT2[a]) + AcquisitionPrioritySAT2[a];
/** Estimated quality of the acquisition, proportional to the zenith angle */
float AcquisitionQualitySAT1[AcquisitionWindows1] = ...;
float AcquisitionQualitySAT2[AcquisitionWindows2] = ...;
/** Owner of each individual acquisition */
int AcquisitionOwnerSAT1[1..3][AcquisitionWindows1] = ...;
int AcquisitionOwnerSAT2[1..3][AcquisitionWindows2] = ...;
float CoefEquity = 1/(NacquisitionWindowsSAT1+NacquisitionWindowsSAT2);

/** List of the respective quota for each user **/
float UserQuota[1..3] = ...;

/** Earliest start time associated with each acquisition window */
float EarliestStartTimeSAT1[AcquisitionWindows1] = ...;
float EarliestStartTimeSAT2[AcquisitionWindows2] = ...;
/** Latest start time associated with each acquisition window */
float LatestStartTimeSAT1[AcquisitionWindows1] = ...;
float LatestStartTimeSAT2[AcquisitionWindows2] = ...;
/** Acquisition duration associated with each acquisition window */
float DurationSAT1[AcquisitionWindows1] = ...;
float DurationSAT2[AcquisitionWindows2] = ...;

/** Required transition time between each pair of successive acquisitions windows */
float TransitionTimesSAT1[AcquisitionWindows1][AcquisitionWindows1] = ...;
float TransitionTimesSAT2[AcquisitionWindows2][AcquisitionWindows2] = ...;

/** File in which the result will be written */
string OutputFileSAT1 = ...;
string OutputFileSAT2 = ...;

/** Boolean variable indicating whether an acquisition window is selected*/
dvar int selectAcq1[AcquisitionWindows1PlusZero] in 0..1;
dvar int selectAcq2[AcquisitionWindows2PlusZero] in 0..1;
// next[a1] = a2 when a2 is the follower of a1
dvar int next1[AcquisitionWindows1PlusZero][AcquisitionWindows1PlusZero] in 0..1;
dvar int next2[AcquisitionWindows2PlusZero][AcquisitionWindows2PlusZero] in 0..1;
/** Acquisition start time in each acquisition window */
dvar float+ startTime1[a in AcquisitionWindows1] in EarliestStartTimeSAT1[a]..LatestStartTimeSAT1[a];
dvar float+ startTime2[a in AcquisitionWindows2] in EarliestStartTimeSAT2[a]..LatestStartTimeSAT2[a];



execute{
	cplex.tilim = 600; // seconds
}

//maximize the number of acquisition windows selected, priority 0 first at any time
//maximize sum(a1 in AcquisitionWindows1)selectAcq1[a1] + sum(a2 in AcquisitionWindows2)selectAcq2[a2];

/*minimize sum(k in 1..3) (abs(UserQuota[k]*NacquisitionWindowsSAT1*200*7*3.14*NacquisitionWindowsSAT1 
	- sum(a in AcquisitionWindows1) AcquisitionOwnerSAT1[k][a]*AcquisitionQualitySAT1[a] *AcquisitionPrioritySAT1[a] * selectAcq1[a]) 
					   + abs(UserQuota[k]*NacquisitionWindowsSAT2*200*7*3.14*NacquisitionWindowsSAT2 
	- sum(a in AcquisitionWindows2) AcquisitionOwnerSAT2[k][a]*AcquisitionQualitySAT2[a] *AcquisitionPrioritySAT2[a] * selectAcq2[a]));
/*	*/
	
maximize sum(a in AcquisitionWindows1) AcquisitionQualitySAT1[a]*CoefPriority1[a] * selectAcq1[a]
    	+ sum(a in AcquisitionWindows2) AcquisitionQualitySAT2[a]*CoefPriority2[a] * selectAcq2[a]
    	 - CoefEquity*(sum(k in 1..3) 
    	  (abs(sum(a in AcquisitionWindows1) (AcquisitionOwnerSAT1[k][a] - UserQuota[k] * selectAcq1[a]) +
    	 	   sum(a in AcquisitionWindows2) (AcquisitionOwnerSAT2[k][a] - UserQuota[k] * selectAcq2[a]))));
/* */
constraints {
	
	// default selection of the dummy acquisition window numbered by 0
	selectAcq1[0] == 1;
	selectAcq2[0] == 1;
	// an acquisition window is selected if and only if it has a (unique) precedessor and a (unique) successor in the plan
	forall(a1 in AcquisitionWindows1PlusZero){
		sum(a2 in AcquisitionWindows1PlusZero : a2 != a1) next1[a1][a2] == selectAcq1[a1];
		sum(a2 in AcquisitionWindows1PlusZero : a2 != a1) next1[a2][a1] == selectAcq1[a1];
		next1[a1][a1] == 0;	
		//sum(a2 in AcquisitionWindows1) (next1[a2] == a1) == selectAcq1[a1];	
	}
	forall(a1 in AcquisitionWindows2PlusZero){
		sum(a2 in AcquisitionWindows2PlusZero : a2 != a1) next2[a1][a2] == selectAcq2[a1];
		sum(a2 in AcquisitionWindows2PlusZero : a2 != a1) next2[a2][a1] == selectAcq2[a1];
		next2[a1][a1] == 0;	
		//sum(a2 in AcquisitionWindows2) (next2[a2] == a1) == selectAcq2[a1];	
	}
	/* */
	// restriction of possible successive selected acquisition windows by using earliest and latest acquisition times
	/*forall(a1,a2 in AcquisitionWindows1 : 
			a1 != a2 && EarliestStartTimeSAT1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2] >= LatestStartTimeSAT1[a2] 
					&& EarliestStartTimeSAT1[a2] + DurationSAT1[a2] + TransitionTimesSAT1[a2][a1] >= LatestStartTimeSAT1[a1]){
		selectAcq1[a1] + selectAcq1[a2] <=1;
	}
	forall(a1,a2 in AcquisitionWindows2 : 
			a1 != a2 && EarliestStartTimeSAT2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2] >= LatestStartTimeSAT2[a2] 
					&& EarliestStartTimeSAT2[a2] + DurationSAT2[a2] + TransitionTimesSAT2[a2][a1] >= LatestStartTimeSAT2[a1]){
		selectAcq2[a1] + selectAcq2[a2] <=1;
	}*/
	forall(a1,a2 in AcquisitionWindows1 : 
			a1 != a2 && EarliestStartTimeSAT1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2] >= LatestStartTimeSAT1[a2]){
		next1[a1][a2] == 0;
		//next1[a1] != a2;
	}
	forall(a1,a2 in AcquisitionWindows2 : 
			a1 != a2 && EarliestStartTimeSAT2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2] >= LatestStartTimeSAT2[a2]){
		next2[a1][a2] == 0;
		//next2[a1] != a2;
	}
	/* */

	// temporal separation constraints between successive acquisition windows (big-M formulation)
	/*forall(a1,a2 in AcquisitionWindows1 : 
				a1 != a2 && EarliestStartTimeSAT1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2] < LatestStartTimeSAT1[a2]){
		(startTime1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2]) <= startTime1[a2] 
												+ (1-selectAcq1[a2])*(LatestStartTimeSAT1[a2]+DurationSAT1[a1]+TransitionTimesSAT1[a1][a2]);
	}
	forall(a1,a2 in AcquisitionWindows2 : 
				a1 != a2 && EarliestStartTimeSAT2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2] < LatestStartTimeSAT2[a2]){
		(startTime2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2]) <= startTime2[a2] 
												+ (1-selectAcq2[a2])*(LatestStartTimeSAT2[a2]+DurationSAT2[a1]+TransitionTimesSAT2[a1][a2]);
	}
	/* */
	
	forall(a1,a2 in AcquisitionWindows1 : 
				a1 != a2 && EarliestStartTimeSAT1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2] < LatestStartTimeSAT1[a2]){
		startTime1[a1] + DurationSAT1[a1] + TransitionTimesSAT1[a1][a2]  <= startTime1[a2] 
                + (1-next1[a1][a2]/*(next1[a1] == a2)*/)*(LatestStartTimeSAT1[a2]+DurationSAT1[a1]+TransitionTimesSAT1[a1][a2]-EarliestStartTimeSAT1[a2]);
	}
	forall(a1,a2 in AcquisitionWindows2 : 
				a1 != a2 && EarliestStartTimeSAT2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2] < LatestStartTimeSAT2[a2]){
		startTime2[a1] + DurationSAT2[a1] + TransitionTimesSAT2[a1][a2]  <= startTime2[a2] 
                + (1-next1[a1][a2]/*(next2[a1] == a2)*/)*(LatestStartTimeSAT2[a2]+DurationSAT2[a1]+TransitionTimesSAT2[a1][a2]-EarliestStartTimeSAT2[a2]);
	}
	/* */
	
	// restriction: one aquisition has at the most one window 
	forall(a1,a2 in AcquisitionWindows1 : a1!=a2 && CandidateAcquisitionIdxSAT1[a1] == CandidateAcquisitionIdxSAT1[a2]){
		selectAcq1[a1] + selectAcq1[a2] <=1;	
	}
	forall(a1,a2 in AcquisitionWindows2 : a1!=a2 && CandidateAcquisitionIdxSAT2[a1] == CandidateAcquisitionIdxSAT2[a2]){
		selectAcq2[a1] + selectAcq2[a2] <=1;
	}
	
	// restriction: one aquisition has at the most one satellite 
	forall(a1 in AcquisitionWindows1,a2 in AcquisitionWindows2 : CandidateAcquisitionIdxSAT1[a1] == CandidateAcquisitionIdxSAT2[a2]){
		selectAcq1[a1] + selectAcq2[a2] <=1;	
	}
	
}

execute {
	var ofile1 = new IloOplOutputFile(OutputFileSAT1);
	var ofile2 = new IloOplOutputFile(OutputFileSAT2);
	for(var i=1; i <= NacquisitionWindowsSAT2; i++) { 
		if(selectAcq2[i] == 1){
			ofile2.writeln(CandidateAcquisitionIdxSAT2[i] + " " + AcquisitionWindowIdxSAT2[i] + " " 
							+ startTime2[i] + " " + (startTime2[i]+DurationSAT2[i])+ " " 
							+ AcquisitionOwnerSAT2[1][i]+ " " + AcquisitionOwnerSAT2[2][i]+ " " + AcquisitionOwnerSAT2[3][i] + " "
							+ AcquisitionPrioritySAT2[i] + " " + AcquisitionQualitySAT2[i])  ;
		}
	}	
	for(var i=1; i <= NacquisitionWindowsSAT1; i++) { 
		if(selectAcq1[i] == 1)
			ofile1.writeln(CandidateAcquisitionIdxSAT1[i] + " " + AcquisitionWindowIdxSAT1[i] + " " 
							+ startTime1[i] + " " + (startTime1[i]+DurationSAT1[i])+ " " 
							+ AcquisitionOwnerSAT1[1][i]+ " " + AcquisitionOwnerSAT1[2][i]+ " " + AcquisitionOwnerSAT1[3][i] + " "
							+ AcquisitionPrioritySAT1[i] + " " + AcquisitionQualitySAT1[i])  ;
	}	
	
}

