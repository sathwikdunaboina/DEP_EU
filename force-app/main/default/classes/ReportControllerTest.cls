@isTest(seeAllData=true)
public class ReportControllerTest {
 
       @isTest static void sendReport() {
           
           Test.startTest();
           DeactivationReportSchedulerClass scObj=new DeactivationReportSchedulerClass();
           String sch ='0 48 * * * ?'; 
           System.schedule('Report', sch,scObj);
           Test.stopTest();
    }
}