global without sharing class DeactivationReportSchedulerClass Implements Schedulable
    {
        global void execute(SchedulableContext sc)
        {
            Monthly_User_Deactivation_Report_Name__mdt reportName = Monthly_User_Deactivation_Report_Name__mdt.getInstance('Monthly_AM04_Report_Name');
            DeactivationReportController.generateReport(reportName.Report_Name__c);
        }

     
    }