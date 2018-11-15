package solver;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.xml.stream.FactoryConfigurationError;
import javax.xml.stream.XMLStreamException;

import params.Params;
import problem.Acquisition;
import problem.AcquisitionWindow;
import problem.CandidateAcquisition;
import problem.PlanningProblem;
import problem.ProblemParserXML;
import problem.RecordedAcquisition;
import problem.Satellite;

/**
 * Download data generator.
 * Extract all required data from aquisition plan and various xml.
 *
 */
public class DownloadDataGen {

	/**
	 * Write a .dat file which represents the download planning data for a particular satellite
	 * @param satellite satellite for which the acquisition plan must be built
	 * @param datFilename name of the .dat file generated
	 * @param solutionFilename name of the file in which CPLEX solution will be written
	 * @throws IOException
	 */
	public static void writeDatFile(SolutionPlan plan,Satellite satellite, String datFilename) throws IOException{
		PlanningProblem pb = plan.pb;
		List<CandidateAcquisition> acqPlan = plan.plannedAcquisitions;
		
		// generate OPL data (only for the satellite selected)
		PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(datFilename, false)));

		// plan downloads for each satellite independently (possible due to the configuration of the constellation)
		for(Satellite satellite1 : pb.satellites){
			// get all recorded acquisitions associated with this satellite
			List<Acquisition> candidateDownloads = new ArrayList<Acquisition>();
			for(RecordedAcquisition dl : pb.recordedAcquisitions){
				if(dl.satellite == satellite1)
					candidateDownloads.add(dl);
			}
			// get all planned acquisitions associated with this satellite
			for(CandidateAcquisition a : acqPlan){
				if(a.selectedAcquisitionWindow.satellite == satellite1)
					candidateDownloads.add(a);
			}
		
		//**********************************//
		// ACQUISITION DATA
		//**********************************//
			
		// write the Debit 
		writer.write("Debit = " + Params.downlinkRate + ";");
		
		//write the number of stations
		int Nstations = pb.stations.size();
		writer.write("\nNstations =" + Nstations + ";");
		
		//write the number of acquisitions
		int Nacq= candidateDownloads.size();
		writer.write("\nNacq= " + Nacq + ";");
		
		//write the list of volume of the acquisitions
		writer.write("\nSizeAcq = [");
		if(!candidateDownloads.isEmpty()){
			writer.write(""+candidateDownloads.get(0).getVolume());
			for(int i=1;i<Nacq;i++){
				writer.write(","+candidateDownloads.get(i).getVolume());
			}
		}
		writer.write("];");
		
		//write the list of the time acquisition
		writer.write("\nDateAcq = [");
		if(!candidateDownloads.isEmpty()){
			writer.write(""+candidateDownloads.get(0).getAcquisitionTime());
			for(int i=1;i<Nacq;i++){
				writer.write(","+candidateDownloads.get(i).getAcquisitionTime());
			}
		}
		writer.write("];");
		
		//write the list of priorities
		writer.write("\nPriorityAcq = [");
		if(!candidateDownloads.isEmpty()){
			writer.write(""+candidateDownloads.get(0).priority);
			for(int i=1;i<Nacq;i++){
				writer.write(","+candidateDownloads.get(i).priority);
			}
		}
		writer.write("];");
		
		//write the list of users
		writer.write("\nUserAcq = [");
		if(!candidateDownloads.isEmpty()){
			writer.write(""+candidateDownloads.get(0).user.idx);
			for(int i=1;i<Nacq;i++){
				writer.write(","+candidateDownloads.get(i).user.idx);
			}
		}
		writer.write("];");
		
		//write the list of users
		writer.write("\nIdxAcq = [");
		if(!candidateDownloads.isEmpty()){
			writer.write(""+candidateDownloads.get(0).idx);
			for(int i=1;i<Nacq;i++){
				writer.write(","+candidateDownloads.get(i).idx);
			}
		}
		writer.write("];");
		
		//write the list of origins
		writer.write("\nOrAcq = [");
		if(!candidateDownloads.isEmpty()){
			if(candidateDownloads.get(0) instanceof CandidateAcquisition) {
				writer.write("CAND");
			}else {
				writer.write("REC");
			}
			for(int i=1;i<Nacq;i++){
				if(candidateDownloads.get(i) instanceof CandidateAcquisition) {
					writer.write(",CAND");
				}else {
					writer.write(",REC");
				}					
			}
		}
		writer.write("];");
		
		
		//**********************************//
		//WINDOW DATA                     
		//**********************************//
		
		//write the number of windows for the satellite
		
		int NW = 0;
		//pb.downloadWindows.size()
		for(int i=0;i<pb.downloadWindows.size();i++){
			if(pb.downloadWindows.get(i).satellite==satellite){
				NW+=1;
			}
		}
		writer.write("\nNW =" + NW + ";");
		
		
		//write the list of window idx time of the satellite
		writer.write("\nIdxWindows= [");
		if(!pb.downloadWindows.isEmpty()){
			if(pb.downloadWindows.get(0).satellite==satellite){
				writer.write(""+pb.downloadWindows.get(0).idx);
			}
			for(int i=1;i<pb.downloadWindows.size();i++){
				if(pb.downloadWindows.get(i).satellite==satellite) {
					writer.write(","+pb.downloadWindows.get(i).idx);
				}
			}
		}
		writer.write("];");
		
		//write the list of window start time of the satellite
		writer.write("\nStartTimeWindows= [");
		if(!pb.downloadWindows.isEmpty()){
			if(pb.downloadWindows.get(0).satellite==satellite){
				writer.write(""+pb.downloadWindows.get(0).start);
			}
			for(int i=1;i<pb.downloadWindows.size();i++){
				if(pb.downloadWindows.get(i).satellite==satellite) {
					writer.write(","+pb.downloadWindows.get(i).start);
				}
			}
		}
		writer.write("];");
		
		//write the list of window end time of the satellite
		writer.write("\nEndTimeWindows= [");
		if(!pb.downloadWindows.isEmpty()){
			if(pb.downloadWindows.get(0).satellite==satellite){
				writer.write(""+pb.downloadWindows.get(0).end);
			}
			for(int i=1;i<pb.downloadWindows.size();i++){
				if(pb.downloadWindows.get(i).satellite==satellite) {
					writer.write(","+pb.downloadWindows.get(i).end);
				}
			}
		}
		writer.write("];");
		

		// write the name of the file in which the result will be written
		writer.write("\nOutputFile = \"" + "DownloadPlan_"+satellite.name+".txt" + "\";");

		// close the writer
		writer.flush();
		writer.close();		
	}
		
	};
	public static void main(String[] args) throws XMLStreamException, FactoryConfigurationError, IOException{
		ProblemParserXML parser = new ProblemParserXML(); 
		PlanningProblem pb = parser.read(Params.systemDataFile,Params.planningDataFile);
		SolutionPlan plan = new SolutionPlan(pb);
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT1.txt");
		plan.readAcquisitionPlan("output/solutionAcqPlan_SAT2.txt");
		for(Satellite satellite : pb.satellites){
			String datFilename = "output/DownloadDATA_"+satellite.name+".dat";
			writeDatFile(plan, satellite, datFilename);
		}
	}

}
