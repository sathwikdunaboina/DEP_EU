public class DashboardController {
    @future(callout=true)
    public static void refreshDashboard(String dashboardId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v62.0/analytics/dashboards/' + dashboardId + '/refresh');
        req.setMethod('PUT');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('Response Status: ' + res.getStatus());
        System.debug('Response Body: ' + res.getBody());
    }
}

 /*   @AuraEnabled
    public static void scheduleDashboardRefreshForHour(String dashboardId) {
        String cronExp = '0 0 * * * ?';
        RemoteSiteTest invoker = new RemoteSiteTest(dashboardId);
        System.schedule('Hourly Dashboard Refresh - ' + dashboardId, cronExp, invoker);
    }*/
//}