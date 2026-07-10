/***********************************************************************************************************
 * Class Name                       : MilestoneUtils
 * Test class Name                  : 
 * Created Date                     :  
 * Code coverage on 14th Feb 2024   : 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      13th Feb 2024           Infosys                User Story-7640: Second Milestone SCTASK102119711
(2)      10th July 2026          Infosys                User Story 1485127: SCTASK104107612 Configuration change on milestones
***********************************************************************************************************/
public class MilestoneUtils {
    
    public static DateTime completionDateTime;
    public static Set<Id> setCaseIdForCaseMilestoneToComplete;
    private static List<CaseMilestone> listCaseMilestone;
    private static Set<String> setUKIEMilestoneTypeName = new Set<String>
    {
        'UK/IE - CS Collections', 
        'UK/IE - CS Operation',
        'UK/IE - Service Desk',
        'UK/IE - CS Credit',
        'User Owner',
        'IE - CS Operations',
        'UK/IE - CS tech Tool',
        'UK/IE - 2nd Checking'
    };

    public static void completeMilestone(List<Id> caseIds, 
            String milestoneName, DateTime complDate) {  
    List<CaseMilestone> cmsToUpdate = [select Id, completionDate
            from CaseMilestone cm
            where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
            and completionDate = null limit 1];
        for (CaseMilestone cm : cmsToUpdate){
            cm.completionDate = complDate;
            }
        update cmsToUpdate;
        
    }


    public static void closeCaseMilestonesAfterCaseUpdate(Set<Id> setCaseIdForCaseMilestoneToComplete, DateTime caseUpdateDateTime) {

        // User Story - 7640 code changes start
        List<CaseMilestone> listCaseMilestone = 
        [Select Id, StartDate, CompletionDate, MilestoneType.Name, TargetResponseInHrs From CaseMilestone 
        Where CaseId IN :setCaseIdForCaseMilestoneToComplete AND MilestoneType.Name IN :setUKIEMilestoneTypeName AND CompletionDate = Null];

        for(CaseMilestone csm: listCaseMilestone) {

            System.debug('>>> CaseMilestone Name: ' + csm.MilestoneType.Name + ', Start Date: ' + csm.StartDate + 
            ', Completion Date: ' + csm.CompletionDate + ', Duration: ' + csm.TargetResponseInHrs);
            csm.CompletionDate = System.Now();
        }
        update listCaseMilestone;
    }
    // User Story - 7640 code changes end
}