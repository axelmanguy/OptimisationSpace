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
import problem.AcquisitionWindow;
import problem.CandidateAcquisition;
import problem.PlanningProblem;
import problem.ProblemParserXML;
import problem.Satellite;

/**
 * Acquisition planner which solves the acquisition problem for both satellites,
 * and which only tries to maximize the number of acquisitions realized. To do this, this
 * planner generates OPL data files.
 * @author cpralet
 *
 */
public class NewAcquisitionPlanner {

	/**
	 * Write a .dat file which represents the acquisition planning problem for both satellites
	 * @param pb planning problem
	 * @param datFilename name of the .dat file generated
	 * @param solutionFilename name of the file in which CPLEX solution will be written
	 * @throws IOException
	 */
	public static void writeDatFile(PlanningProblem pb, String datFilename, String solutionFilename) throws IOException{ 
		// Satellite satellite, 
			//String datFilename, String solutionFilename) throws IOException{
		// generate OPL data (only for the satellite selected)
		PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(datFilename, false)));

		// get all acquisition windows involved in the problem
		List<AcquisitionWindow> acquisitionWindows = new ArrayList<AcquisitionWindow>();
		
		for(Satellite satellite : pb.satellites){
			for(CandidateAcquisition a : pb.candidateAcquisitions){
				for(AcquisitionWindow w : a.acquisitionWindows){
					if(w.satellite == satellite){
						acquisitionWindows.add(w);
					}
				}
			}	
			
			// write the name of the file in which the result will be written
			writer.write("\nOutputFile" + satellite.name + " = \"" + solutionFilename + satellite.name +".txt\";");
	
			// write the number of acquisition windows
			int nAcquisitionWindows = acquisitionWindows.size();
			writer.write("\nNacquisitionWindows" + satellite.name + " = " + nAcquisitionWindows + ";");
	
			// write the index of each acquisition
			writer.write("\nCandidateAcquisitionIdx" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).candidateAcquisition.idx);
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).candidateAcquisition.idx);
				}
			}
			writer.write("];");
					
			// write the priority of each acquisition, either 1 for low priority or a big number for high priority
			writer.write("\nAcquisitionPriority" + satellite.name + " = [");
			int count=0;
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).candidateAcquisition.priority);
				if(acquisitionWindows.get(0).candidateAcquisition.priority==1) {
					count++;
				}
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).candidateAcquisition.priority);
					if(acquisitionWindows.get(i).candidateAcquisition.priority==1) {
						count++;
					}
				}
			}
			System.out.println(count);
			writer.write("];");	
			
			// write the quality of the acquisition, which is proportional to the viewing angle wrt to the zenith direction.
			writer.write("\nAcquisitionQuality" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				double quality = (1-Math.abs(acquisitionWindows.get(0).zenithAngle)/Math.PI);
				writer.write(""+ quality);
				for(int i=1;i<nAcquisitionWindows;i++){
					quality = (1-Math.abs(acquisitionWindows.get(i).zenithAngle)/Math.PI);
					writer.write(","+ quality);
				}
			}
			writer.write("];");	
	
			// write the index of each acquisition window
			writer.write("\nAcquisitionWindowIdx" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).idx);
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).idx);
				}
			}
			writer.write("];");
			
			// write the owner of each acquisition
			writer.write("\nAcquisitionOwner" + satellite.name + " = [[");
			if(!acquisitionWindows.isEmpty()){
				String user = acquisitionWindows.get(0).candidateAcquisition.user.toString();
				if (user.equals("User1")) {
					writer.write(""+1);
				}
				else {
					writer.write(""+0);
				}
					for(int i=1;i<nAcquisitionWindows;i++){
						user = acquisitionWindows.get(i).candidateAcquisition.user.toString();
						if (user.equals("User1")) {
							writer.write(","+1);
						}
						else {
							writer.write(","+0);
						}
				}
			}
			writer.write("],");
			
			// write the owner of each acquisition
			writer.write("[");
			if(!acquisitionWindows.isEmpty()){
				String user = acquisitionWindows.get(0).candidateAcquisition.user.toString();
				if (user.equals("User2")) {
					writer.write(""+1);
				}
				else {
					writer.write(""+0);
				}
					for(int i=1;i<nAcquisitionWindows;i++){
						user = acquisitionWindows.get(i).candidateAcquisition.user.toString();
						if (user.equals("User2")) {
							writer.write(","+1);
						}
						else {
							writer.write(","+0);
						}
				}
			}
			writer.write("],");
			
			// write the owner of each acquisition
			writer.write("[");
			if(!acquisitionWindows.isEmpty()){
				String user = acquisitionWindows.get(0).candidateAcquisition.user.toString();
				if (user.equals("User3")) {
					writer.write(""+1);
				}
				else {
					writer.write(""+0);
				}
					for(int i=1;i<nAcquisitionWindows;i++){
						user = acquisitionWindows.get(i).candidateAcquisition.user.toString();
						if (user.equals("User3")) {
							writer.write(","+1);
						}
						else {
							writer.write(","+0);
						}
				}
			}
			writer.write("]];");
	
			// write the earliest acquisition start time associated with each acquisition window
			writer.write("\nEarliestStartTime" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).earliestStart);
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).earliestStart);
				}
			}
			writer.write("];");
	
			// write the latest acquisition start time associated with each acquisition window
			writer.write("\nLatestStartTime" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).latestStart);
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).latestStart);
				}
			}
			writer.write("];");
	
			// write the duration of acquisitions in each acquisition window
			writer.write("\nDuration" + satellite.name + " = [");
			if(!acquisitionWindows.isEmpty()){
				writer.write(""+acquisitionWindows.get(0).duration);
				for(int i=1;i<nAcquisitionWindows;i++){
					writer.write(","+acquisitionWindows.get(i).duration);
				}
			}
			writer.write("];");
	
			// write the transition times between acquisitions in acquisition windows
			writer.write("\nTransitionTimes" + satellite.name + " = [");
			for(int i=0;i<nAcquisitionWindows;i++){
				AcquisitionWindow a1 = acquisitionWindows.get(i);
				if(i != 0) writer.write(",");
				writer.write("\n\t[");
				for(int j=0;j<nAcquisitionWindows;j++){
					if(j != 0) writer.write(",");
					writer.write(""+pb.getTransitionTime(a1, acquisitionWindows.get(j)));
				}	
				writer.write("]");
			}
			writer.write("\n];");
	
			acquisitionWindows.clear();
			

		}
	
	// write the quota for each user
	List<problem.User> Users = pb.getUsers();
	writer.write("\nUserQuota = [");
	if(!Users.isEmpty()){
		int nUser=Users.size();
		writer.write(""+Users.get(0).getQuota());	
		for (int i=1;i<nUser;i++) {
			writer.write(","+Users.get(i).getQuota());
		}
	}
	writer.write("];");
	
	// close the writer
	writer.flush();
	writer.close();	
}

	public static void main(String[] args) throws XMLStreamException, FactoryConfigurationError, IOException{
		ProblemParserXML parser = new ProblemParserXML(); 
		PlanningProblem pb = parser.read(Params.systemDataFile,Params.planningDataFile);
		pb.printStatistics();
		//for(Satellite satellite : pb.satellites){
		String datFilename = "output/acqPlanning_.dat";//"+satellite.name+".dat";
		String solutionFilename = "solutionAcqPlan_";//_.txt";//"+satellite.name+".txt";
		writeDatFile(pb, datFilename, solutionFilename);
		//}
	}

}
