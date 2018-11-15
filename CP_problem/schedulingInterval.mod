using CP ;
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
/** Number of stations */
int Nstations = ...;
range Stations = 1..Nstations;
 
/** Number of acquisitions (for Sat1 and Sat2) */
int Nacq = ...;
range Acq = 1..Nacq;
 
/** acquisitions size list */
int SizeAcq[Acq] = ...;

/** acquisitions realisaton date list */
int Duration[Acq] = ...;

/** acquisitions realisaton date list */
int DateAcq[Acq] = ...;

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
int StartTimeWindows[window] = ...;
int MinStartTime = min(w in window) StartTimeWindows[w];
int MaxStartTime = max(w in window) StartTimeWindows[w];

/** windows EndingTime list */
int EndTimeWindows[window] = ...;


/** windows Duration list */
//float DurationWindows[window] = ...;

/*********************************************
			Decision Variable
*********************************************/

/* Interval associated with each observation */
dvar interval AcqInterval[a in Acq] optional in MinStartTime..MaxStartTime size Duration[a] ;

//dvar interval obsIntervalInWindow[o in Obs][k in Vis] optional in VisStart[o][k]..VisEnd[o][k] size Duration[o] ;
/* Interval associated with each observation and each visibility window */
dvar interval AcqIntervalInWindow[a in Acq][w in window] optional in StartTimeWindows[w]..EndTimeWindows[w] size Duration[a] ;

/* Sequence of observations */
dvar sequence seq in AcqInterval;

dexpr int StartTime[a in Acq]=startOf(AcqInterval[a]);
dexpr int SelectAcq[a in Acq]=presenceOf(AcqInterval[a]);
dexpr int EndTime[a in Acq]= startOf(AcqInterval[a])+Duration[a];
dexpr int SelectAcqWind[a in Acq][w in window]=presenceOf(AcqIntervalInWindow[a][w]);

/*********************************************
Criterion:
0.5*(1-priority)+0.5*size - sum(w in window) selectWindow[w]
maximize sum(a in Acq) ((0.5*(1-PriorityAcq[a])+0.5*SizeAcq[a]))*presenceOf(AcqInterval[a]);
*********************************************/

maximize sum(a in Acq) (((1-PriorityAcq[a])-0.1*StartTime[a]))*presenceOf(AcqInterval[a]);

constraints{

/* No overlap between observations */
noOverlap(seq) ;

/* Realization of dowlonad in one of windows */
forall(a in Acq)
	alternative(AcqInterval[a], all(w in window) AcqIntervalInWindow[a][w]);


forall(a in Acq){
		startOf(AcqInterval[a]) >= DateAcq[a]*presenceOf(AcqInterval[a]);			
	}

}
execute {

	writeln(SelectAcq);
	writeln(seq);
	writeln(StartTime);

	var ofile = new IloOplOutputFile(OutputFile);	
	for(var w=1; w <= NW; w++) {
		for(var a=1; a<= Nacq; a++) {
			if(SelectAcqWind[a][w] == 1){
				ofile.writeln(OrAcq[a]+" "+ IdxAcq[a] + " " + IdxWindows[w] + " " + StartTime[a] + " " + EndTime[a]);	
  				}									
			}				
		}	
	}


