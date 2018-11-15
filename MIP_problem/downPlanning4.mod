/*********************************************
 * OPL 12.8.0.0 Model
 * Author: manguy
 * Creation Date: 29 sept. 2018 at 15:35:17
 *********************************************/

 /*********************************************
				Problem Data
 *********************************************/
 
 string OutputFile = ...;
 
 /** ---------- Acquisition Data ----------- */
 
 /** Debit Constant */
 float Debit=...;
 
 /** Number of stations */
 int Nstations = ...;
 range Stations = 1..Nstations;
 
 /** Number of acquisitions (for Sat1 and Sat2) */
int Nacq = ...;
range Acq = 1..Nacq;
range Acq_dummy = 0..Nacq+1;
 
 /** acquisitions size list */
int SizeAcq[Acq] = ...;

 /** acquisitions realisaton date list */
float DateAcq[Acq] = ...;

 /** acquisitions priority list */
int PriorityAcq[Acq] = ...;

 /** acquisitions size list */
int UserAcq[Acq] = ...;

 /** acquisitions idx list */
int IdxAcq[Acq] = ...;

string OrAcq[Acq] = ...;



 /** ----------Visibility Windows Data ------- */
 
 /** Number of visibility windows for Sat1 and Sat2 */
int NW = ...;
range window = 1..NW;

 /** windows idx list */
int IdxWindows[window] = ...;

 /** windows StartingTime list */
float StartTimeWindows[window] = ...;
float MinStartTime = min(w in window) StartTimeWindows[w];
float MaxStartTime = max(w in window) StartTimeWindows[w];

 /** windows EndingTime list */
float EndTimeWindows[window] = ...;


 /** windows Duration list */
//float DurationWindows[window] = ...;

 /*********************************************
				Decision Variable
 *********************************************/
 
 /** Boolean variable indicating whether an acquisition is selected */
dvar int selectAcq[Acq_dummy] in 0..1;

 /** Boolean variable indicating whether the station i is selected for the aquisition j*/
dvar int selectStation[Stations][Acq] in 0..1;

 /** Boolean variable indicating whether the win i is selected for the aquisition j*/
dvar int selectWindowAcq[window][Acq] in 0..1;

 /** Boolean variable indicating whether the visibility window i is selected for the aquisition j*/
dvar int selectWindow[window] in 0..1;

/** Download start time of each aquisition */
dvar float+ StartTime[Acq] in MinStartTime..MaxStartTime;

/** next[a1][a2] = 1 when a1 is the selected acquisition window that follows a2 */
dvar int next[Acq_dummy][Acq_dummy] in 0..1;

execute{
	cplex.tilim = 60; // 
}

 /*********************************************
				 Criterion:
	0.5*(1-priority)+0.5*size - sum(w in window) selectWindow[w]
 *********************************************/

maximize sum(a in Acq) ((0.5*(1-PriorityAcq[a])+0.5*SizeAcq[a]))*selectAcq[a];

 /*********************************************
				 Constraints
 *********************************************/

constraints {
	
	// an acquisition window is selected if and only if it has a (unique) precedessor and a (unique) successor in the plan
	selectAcq[0] == 1;
	selectAcq[Nacq+1] == 1;
	forall(a1 in Acq_dummy){
		sum(a2 in Acq_dummy : a2 != a1) next[a1][a2] == selectAcq[a1];
		sum(a2 in Acq_dummy : a2 != a1) next[a2][a1] == selectAcq[a1];
		next[a1][a1] == 0;
	}
	
 	/** time constraints : StartTime is in a window*/
 	forall(a in Acq, w in window)
 	  {
 		StartTime[a]>=selectWindowAcq[w][a]*StartTimeWindows[w];
 		StartTime[a]+ (SizeAcq[a]/Debit)<=selectWindowAcq[w][a]*EndTimeWindows[w] + (1-selectWindowAcq[w][a])*MaxStartTime;
	}
	
	/** window selection constraint*/
	forall(w in window)
 	  {
 		(sum(a in Acq)selectWindowAcq[w][a])>= selectWindow[w];
 		selectWindow[w]*Nacq>=sum(a in Acq) selectWindowAcq[w][a];
	}
	
	/** acquisition selection constraint*/
	forall(a in Acq)
 	  {
 		(sum(w in window)selectWindowAcq[w][a])==selectAcq[a];
	}
 	
	// temporal separation constraints between successive acquisition windows (big-M formulation)
	forall(a1,a2 in Acq: a1 != a2){
		StartTime[a1] + (SizeAcq[a1]/Debit) <= StartTime[a2] + (1-next[a1][a2])*MaxStartTime;
	}
	/*
	forall(a1,a2 in AcquisitionWindows : a1 != a2 && EarliestStartTime[a1] + Duration[a1] + TransitionTimes[a1][a2] < LatestStartTime[a2]){
		startTime[a1] + Duration[a1] + TransitionTimes[a1][a2]  <= startTime[a2] 
                + (1-next[a1][a2])*(LatestStartTime[a1]+Duration[a1]+TransitionTimes[a1][a2]-EarliestStartTime[a2]);
	}*/

	/** one station by transmission*/
	forall(a in Acq) sum(s in Stations) selectStation[s][a] <= 1 ;
	
	/*No 2 strat time identical */
	forall(a in Acq){
		StartTime[a] >= DateAcq[a]*selectAcq[a];
			
	}

}
execute {
	var ofile = new IloOplOutputFile(OutputFile);	
	for(var i=1; i <= NW; i++) {
		for(var j=1; j<= Nacq; j++) {
			if(selectWindowAcq[i][j] == 1){	
				var duration =StartTime[j] + (SizeAcq[j]/Debit);
				ofile.writeln(OrAcq[j]+" "+ IdxAcq[j] + " " + IdxWindows[i] + " " + StartTime[j] + " " + duration);	
  				}									
			}				
		}	
	}

