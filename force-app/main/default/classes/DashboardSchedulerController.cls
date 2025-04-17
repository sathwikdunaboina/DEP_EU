/* 
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Apex Class Name     DashboardSchedulerController
* @author             Swami Goskula <swami.goskula@consultant.volvo.com> 
* @Created Date       04-09-2025         
* -----------------------------------------------------------------------------------------------------------------------------------------------
* @description        This class is used to schedule dashboard refreshes at specified times and days using Schedule_Dashboard_Refresh_Screen_Flow. 
* ------------------------------------------------------------------------------------------------------------------------------------------------
*/


public with sharing class DashboardSchedulerController {
// Wrapper class to accept input from Flow
public class DashboardInput {
    @InvocableVariable(label='Dashboard Id' required=true)
    public String dashboardId;
    @InvocableVariable(label='Hours of Day' required=true)
    public String hoursOfDay = '9,11,13,15,17,19';
    @InvocableVariable(label='Days of Week' required=true)
    public String daysOfWeek = '2,3,4,5,6,7';
    @InvocableVariable(label='Scheduled Job URL' )
    public String scheduledJobURL;
    @InvocableVariable(label='Message')
    public String outputMsg;

}

// Invocable method to schedule dashboard refresh every hour
@InvocableMethod(label='Schedule Dashboard Refresh' description='Schedules refresh for the selected dashboard')
public static List<DashboardInput> scheduleDashboardRefresh(List<DashboardInput> dashboardInputs) {
List<DashboardInput> outputs = new List<DashboardInput>();
    for (DashboardInput dashboardInput : dashboardInputs) {  
    try{      
        if (dashboardInput.dashboardId != null ) {            
            String dashboardSchJobName = 'DashboardRefreshSchJob_'+dashboardInput.dashboardId;
            
            string hoursOfDay = dashboardInput.hoursOfDay.replace(';', ',');
            string daysOfWeek = dashboardInput.daysOfWeek.replace(';', ',');
            String cronExpression = '0 0 ' + hoursOfDay + ' ? * ' + daysOfWeek + ' * ';

            // Schedule the job
            Id jobId = System.schedule(dashboardSchJobName, cronExpression, new DashboardRefreshJob(dashboardInput.dashboardId));
            dashboardInput.scheduledJobURL = URL.getOrgDomainUrl().toExternalForm() + '/lightning/setup/ScheduledJobs/home';
            dashboardInput.outputMsg = 'Successfully Submitted Scheduled Refresh for Dashboard - ' + dashboardInput.dashboardId + '.Check Error Log records if dashboard fails to refresh at the scheduled time.';
            outputs.add(dashboardInput);          
        }
    }
    catch(Exception e){
        dashboardInput.outputMsg = e.getMessage();
        outputs.add(dashboardInput);
        break;
    }    
    }
    System.Debug(outputs);
    return outputs;

}
}