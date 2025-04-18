/* 
* --------------------------------------------------------------------------------------------------------------------
* Apex Class Name     DashboardRefreshQueueable
* @author             Swami Goskula <swami.goskula@consultant.volvo.com> 
* @Created Date       04-09-2025         
* ---------------------------------------------------------------------------------------------------------------------
* @description        This class is designed to refresh a dashboard by making an HTTP PUT request to the Salesforce API.
* ----------------------------------------------------------------------------------------------------------------------
*/

public class DashboardRefreshQueueable implements Queueable, Database.AllowsCallouts {
   @TestVisible
   private String dashboardId;
    
    public DashboardRefreshQueueable(String dashboardId) {
        this.dashboardId = dashboardId;
    }
    
    public void execute(QueueableContext context) {
        try {
            String endPoint = URL.getOrgDomainUrl()+ '/services/data/v62.0/analytics/dashboards/' + dashboardId;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('PUT');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setBody('some post body');
            HttpResponse res = new Http().send(req);
            string statusCode = String.valueof(res.getStatusCode());
            if(!statusCode.startsWithIgnoreCase('2')){
                throw new System.CalloutException('HttpRequest to refresh Dashboard : '+ dashboardId+ ' failed with Response status code: ' + statusCode+'. Response status : ' + res.getStatus());
            }
        } catch (Exception e) {
            ErrorLogUtil.logError(e,'NoRecord','NoRecordId');           
        }
    }
}