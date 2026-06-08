/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     ContractVINValidationService
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       18-05-2026
* ------------------------------------------------------------------------------------------
* @description        This Service Class is to find whether a VIN number in any contracts is Valid or NOT with VINValidator Class
* ------------------------------------------------------------------------------------------
*/
public class ContractVINValidationService {
    // BEFORE INSERT
    public void validateVIN(List<Contract__c> contracts) {
        List<Contract__c> contractsToValidate = new List<Contract__c>();
        List<String> vins = new List<String>();
        // Collect VINs
        for (Contract__c con : contracts) {
            if (!String.isBlank(con.VIN_Number__c)) {
                contractsToValidate.add(con);
                vins.add(con.VIN_Number__c);
            }
        }
        // Nothing to validate
        if (vins.isEmpty()) {
            return;
        }
        // Validate VINs
        List<VINValidator.VINResult> results = VINValidator.validateBulk(vins);
        // Update field
        for (Integer i = 0; i < contractsToValidate.size(); i++) {
            VINValidator.VINResult r = results[i];
            Boolean markedValid = r.isValid && r.warnings.isEmpty();
            contractsToValidate[i].VIN_Format_Valid__c = markedValid;
        }
    }
    // BEFORE UPDATE
    public void validateVIN(List<Contract__c> newContracts,Map<Id, Contract__c> oldMap) {
        List<Contract__c> contractsToValidate = new List<Contract__c>();
        List<String> vins = new List<String>();
        for (Contract__c con : newContracts) {
            Contract__c oldCon = oldMap.get(con.Id);
            // Validate ONLY when VIN changed
            if (con.VIN_Number__c != oldCon.VIN_Number__c && !String.isBlank(con.VIN_Number__c))
            {
                    contractsToValidate.add(con);
            }
        }
        this.validateVIN(contractsToValidate);
    }
}