/* 
* -----------------------------------------------------------------------------------------------------------------------------
* Apex Class Name     DashboardSchedulerController_Test
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       09-04-2025 

* ------------------------------------------------------------------------------------------------------------------------------
* @description        This class is used to test DashboardSchedulerController & DashboardRefreshJob & DashboardRefreshQueueable
* ------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
global class DashboardSchedulerController_Test {
    /*
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* @Method Name     testScheduleDashboardRefresh
* @description     It Create a test DashboardInput object with a dashboardId, hoursOfDay, and daysOfWeek and verifies that a scheduled job has been created with the correct cron expression.
* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void testScheduleDashboardRefresh() {
        // Cleanup any existing scheduled jobs
        List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'DashboardRefreshSchJob_%'];
        for (CronTrigger job : existingJobs) {
            System.abortJob(job.Id);
        }
        
        DashboardSchedulerController.DashboardInput input = new DashboardSchedulerController.DashboardInput();
        input.dashboardId = 'testDashboardId';
        input.hoursOfDay = '9,11,13,15,17,19';
        input.daysOfWeek = '2,3,4,5,6,7';
        
        List<DashboardSchedulerController.DashboardInput> inputs = new List<DashboardSchedulerController.DashboardInput>{input};
            
        Test.startTest();
        List<DashboardSchedulerController.DashboardInput> outputs = DashboardSchedulerController.scheduleDashboardRefresh(inputs);
        Test.stopTest();
        
        // Verify the scheduled job
        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                          FROM CronTrigger WHERE CronExpression = '0 0 9,11,13,15,17,19 ? * 2,3,4,5,6,7 *'];
        System.debug('cronTriggers'+cronTriggers);
        System.assertNotEquals(null, cronTriggers);
        System.assertNotEquals(0, cronTriggers.size());
        System.assertEquals('0 0 9,11,13,15,17,19 ? * 2,3,4,5,6,7 *', cronTriggers[0].CronExpression);
        System.assertEquals(0, cronTriggers[0].TimesTriggered);
        
        // Verify the output message
        System.assertNotEquals(null, outputs);
        System.assertNotEquals(0, outputs.size());
        System.assertEquals('Successfully Submitted Scheduled Refresh for Dashboard - testDashboardId.Check Error Log records if dashboard fails to refresh at the scheduled time.', outputs[0].outputMsg);
        System.assertNotEquals(null, outputs[0].scheduledJobURL);
    }
    
    @isTest
    static void testScheduleDashboardRefreshWithException() {
        DashboardSchedulerController.DashboardInput input = new DashboardSchedulerController.DashboardInput();
        input.dashboardId = 'testDashboardId';
        input.hoursOfDay = 'invalidHour';
        input.daysOfWeek = '2,3,4,5,6,7';
        
        List<DashboardSchedulerController.DashboardInput> inputs = new List<DashboardSchedulerController.DashboardInput>{input};
        system.debug('Inputs in Exception'+inputs);
        Test.startTest();
        List<DashboardSchedulerController.DashboardInput> outputs = DashboardSchedulerController.scheduleDashboardRefresh(inputs);
        Test.stopTest();
        system.debug('outputs in Exception'+outputs);
        System.assertNotEquals(null, outputs);
        System.assertNotEquals(0, outputs.size());
        if (outputs.size() == 1) {
            System.assertEquals(null, outputs[0].scheduledJobURL); 
            System.assertNotEquals(null, outputs[0].outputMsg); 
        } else {
            System.assert(true, 'Outputs list does not have exactly one element as expected');
        }
        
    }
   
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testDashboardRefreshJob
* @description     It verifies that a job of type 'Queueable' has been enqueued and that the dashboardId is correctly passed to the job.
* ------------------------------------------------------------------------------------------------------
*/ 
    @isTest
    static void testDashboardRefreshJob() {
        String dashboardId = 'testDashboardId';
        DashboardRefreshJob job = new DashboardRefreshJob(dashboardId);
        
        Test.startTest();
        job.execute(null);
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertEquals(1, jobs.size());
        System.assertEquals('Queueable', jobs[0].JobType);
        
        System.assertEquals(dashboardId, job.dashboardId);
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testDashboardRefreshQueueable
* @description     It will set a up a mock HTTP response to simulate a successful callout
* ------------------------------------------------------------------------------------------------------
*/
    
    @isTest
    static void testDashboardRefreshQueueable() {
        String dashboardId = 'testDashboardId';
        DashboardRefreshQueueable queueable = new DashboardRefreshQueueable(dashboardId);
        
        HttpResponse res = new HttpResponse();
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
        
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
        System.assertEquals(dashboardId, queueable.dashboardId);
    }
    
    @isTest
    static void testDashboardRefreshQueueableWithException() {
        String dashboardId = 'testDashboardId';
        DashboardRefreshQueueable queueable = new DashboardRefreshQueueable(dashboardId);
        
        HttpResponse res = new HttpResponse();
        res.setBody('{"status":"error"}');
        res.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
        
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']); 
        System.assertEquals(dashboardId, queueable.dashboardId);
    }
        
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return response;
        }
    }
}