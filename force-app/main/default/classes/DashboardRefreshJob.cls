/* 
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Apex Class Name     DashboardRefreshJob
* @author             Swami Goskula <swami.goskula@consultant.volvo.com> 
* @Created Date       04-09-2025         
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* @description       This class schedules a job to refresh a dashboard at specified times and enqueues another job (DashboardRefreshQueueable) to perform the refresh.
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

global without sharing class DashboardRefreshJob implements Schedulable {
        public String dashboardId;

    
    public DashboardRefreshJob(String dashboardId) {
        this.dashboardId = dashboardId;
    }
    
    global void execute(SchedulableContext ctx) {
         System.enqueueJob(new DashboardRefreshQueueable(dashboardId));
    }
}