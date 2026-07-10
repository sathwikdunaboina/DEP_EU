/***********************************************************************************************************
 * Trigger Name                       : CompletePickupTimeMilestone
 * Test class Name                  : 
 * Created Date                     :  
 * Code coverage on 14th Feb 2024   : 
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      13th Feb 2024           Infosys                User Story-7640: Second Milestone SCTASK102119711
***********************************************************************************************************/
trigger CompletePickupTimeMilestone on Case (before update, after update) {

    if(trigger.isBefore && trigger.isUpdate) {

        set<Id> setCaseIdForCaseMilestoneToComplete = new Set<Id>();
        for(Case cs: trigger.New) {

            if(cs.EntitlementId != Null && cs.Status == 'Closed' && trigger.oldMap.get(cs.Id).Status != 'Closed' 
              
              //User story 628022 Changes for the test class Added on Date 24th April 2024 
               && cs.SlaExitDate==Null
              ) {

                    setCaseIdForCaseMilestoneToComplete.add(cs.Id);
            }
        }
        if(!setCaseIdForCaseMilestoneToComplete.isEmpty()) { 

            milestoneUtils.closeCaseMilestonesAfterCaseUpdate(setCaseIdForCaseMilestoneToComplete, System.Now());
        }
    }

    if(trigger.isAfter && trigger.isUpdate) {

        if (UserInfo.getUserType() == 'Standard'){
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : Trigger.new){
                if (((c.Status == 'In Progress'))&&((c.SlaStartDate <= completionDate)&&(c.SlaExitDate == null)))
                    updateCases.add(c.Id);
            }
            if (updateCases.isEmpty() == false)
                milestoneUtils.completeMilestone(updateCases, 'Case Pickup', completionDate);
        }

        // User Story - 7640 code changes start
        set<Id> setCaseIdForCaseMilestoneToComplete = new Set<Id>();
        for(Case cs: trigger.New) {

            if(cs.EntitlementId != Null && 
            (trigger.oldMap.get(cs.Id).OwnerId != cs.OwnerId) && (cs.Status != 'Closed')) {

                    setCaseIdForCaseMilestoneToComplete.add(cs.Id);
            }
        }
        if(!setCaseIdForCaseMilestoneToComplete.isEmpty()) { 

            milestoneUtils.closeCaseMilestonesAfterCaseUpdate(setCaseIdForCaseMilestoneToComplete, System.Now());
        }
    }
    // User Story - 7640 code changes end
}