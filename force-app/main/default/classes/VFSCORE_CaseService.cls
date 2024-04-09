/**
 * -------------------------------------------------------------------------------
 * @Name            VFSCORE_CaseService
 * @Author          Alok Kumar <alok.kumar.3@consultant.volvo.com>
 * @CreatedDate     2nd April 2024
 * @UsedBy          Flows
 * @SystemLayer     Service
 * ------------------------------------------------------------------------------
 * @Description
 * This is a utility class on Case object to extend the functionaltiies on Case which are
 * otherwise not provided as Salesforce standard.
 * -------------------------------------------------------------------------------  
 */
public without sharing class VFSCORE_CaseService {
    /**
    * ----------------------------------------------------------------------------
    * @Description
    *  Invokes default case assignment rule
    *  ----------------------------------------------------------------------------    
    *  @param1      listCase    cases on which to apply the case assignment rule
    *  @returns     void
    * -----------------------------------------------------------------------------
    **/
    @InvocableMethod (label='Apply Case Assignment Rules')
    public static void ApplyCaseAssignmentRule(List<case> listCase)
    {
    System.Debug('Inside ApplyCaseAssignmentRule');
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule= true;
    dmo.EmailHeader.TriggerUserEmail = true;
        system.debug('Test Data'+listCase);
    List<case> listCaseToUpdate = new List<case>();
    for(Case varCase : listCase){
        varCase.setOptions(dmo);
        listCaseToUpdate.add(varCase);
    }
    update listCaseToUpdate;
          system.debug('Test Data'+listCaseToUpdate);
    }
}