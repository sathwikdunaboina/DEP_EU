/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     fetchDuplicateAccountAndSaveAccount
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       04-06-2025 
* @Used By            LWC Component on New Button on Account
* ------------------------------------------------------------------------------------------
* @description        Used in LWC Component which is used in New Button on Account List view to Let the users save the newly created Account and also to find the
duplicates based on Duplicate rule in Org(Added in Duplicate Rule Metadata)
* ------------------------------------------------------------------------------------------
*/
public class fetchDuplicateAccountAndSaveAccount {
    public class DuplicateRuleResult {
        @AuraEnabled public Boolean isDuplicate; 
        @AuraEnabled public Boolean isBlock; 
        @AuraEnabled public Boolean isAllow; 
        @AuraEnabled public List<String> matchedFieldNames; 
        @AuraEnabled public String ruleName;
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getRecordTypeDetails
* @description     To get the Record Type Details
* ------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRecordTypeDetails(String sObjectName) {
        List<Map<String, String>> recordTypeDetails = new List<Map<String, String>>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = describeResult.getRecordTypeInfosById();
        
        for (Id rtId : recordTypeInfos.keySet()) {
            Schema.RecordTypeInfo rtInfo = recordTypeInfos.get(rtId);
            if (rtInfo.isAvailable()) { // Ensure the record type is active
                Map<String, String> rtDetail = new Map<String, String>();
                rtDetail.put('label', rtInfo.getName()); // Record Type Name (Label)
                rtDetail.put('developerName', rtInfo.getDeveloperName()); // Record Type API Name
                rtDetail.put('recordTypeId', rtId);
                recordTypeDetails.add(rtDetail);
            }
        }
        return recordTypeDetails;
    }
    
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     checkDuplicateRules
* @description     To check the whether the Account which is being created is Duplicate or Not
* ------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled(cacheable=false)
    public static DuplicateRuleResult checkDuplicateRules(Map<String, Object> fieldMap) {
        DuplicateRuleResult result = new DuplicateRuleResult();
        result.isDuplicate = false;
        result.isBlock = false;
        result.isAllow = false;
        result.matchedFieldNames = new List<String>();
        
        List<Duplicate_Rule__mdt> rules = [
            SELECT Rule_Name__c, Field__c, Match_Type__c, Action_On_Create__c, Operation__c, Order__c
            FROM Duplicate_Rule__mdt
            WHERE Active__c = true
            ORDER BY Order__c ASC, Rule_Name__c
        ];
        
        // Group rules by Rule_Name__c
        Map<String, List<Duplicate_Rule__mdt>> ruleGroups = new Map<String, List<Duplicate_Rule__mdt>>();
        for (Duplicate_Rule__mdt rule : rules) {
            if (!ruleGroups.containsKey(rule.Rule_Name__c)) {
                ruleGroups.put(rule.Rule_Name__c, new List<Duplicate_Rule__mdt>());
            }
            ruleGroups.get(rule.Rule_Name__c).add(rule);
        }
        
        for (String groupName : ruleGroups.keySet()) {
            List<Duplicate_Rule__mdt> groupRules = ruleGroups.get(groupName);
            List<String> queryConditions = new List<String>();
            
            for (Duplicate_Rule__mdt ruleItem : groupRules) {
                if (fieldMap.containsKey(ruleItem.Field__c) && fieldMap.get(ruleItem.Field__c) != null) {
                    String val = String.escapeSingleQuotes(String.valueOf(fieldMap.get(ruleItem.Field__c)));
                    
                    if (ruleItem.Match_Type__c == 'Exact') {
                        queryConditions.add(ruleItem.Field__c + ' = \'' + val + '\'');
                    } else if (ruleItem.Match_Type__c == 'Fuzzy') {
                        queryConditions.add(ruleItem.Field__c + ' LIKE \'' + val + '%\'');
                    }
                }
            }
            // If no matching fields, skip to next group
            if (queryConditions.isEmpty()) {
                continue;
            }
            // Build dynamic query string
            String queryStr = 'SELECT Id, Name, BillingCity, BillingCountry,CompanyRegistrationNumber__c,CustomerID__c FROM Account WHERE IsDeleted = false AND (' + String.join(queryConditions, ' OR ') + ')';
            List<Account> potentialMatches = Database.query(queryStr);
            // Evaluate each account for full match
            for (Account acc : potentialMatches) {
                Boolean allMatch = true;
                List<String> matchedFields = new List<String>();
                for (Duplicate_Rule__mdt ruleItem : groupRules) {
                    Object inputVal = fieldMap.get(ruleItem.Field__c);
                    if (inputVal == null) {
                        allMatch = false;
                        break;
                    }
                    Object dbVal = acc.get(ruleItem.Field__c);
                    if (dbVal == null) {
                        allMatch = false;
                        break;
                    }
                    if (ruleItem.Match_Type__c == 'Exact' && !String.valueOf(dbVal).trim().equalsIgnoreCase(String.valueOf(inputVal).trim())) {
                        allMatch = false;
                        break;
                    } else if (ruleItem.Match_Type__c == 'Fuzzy' && !String.valueOf(dbVal).toLowerCase().startsWith(String.valueOf(inputVal).toLowerCase())) {
                        allMatch = false;
                        break;
                    } else {
                        matchedFields.add(ruleItem.Field__c);
                    }
                }
                if (allMatch) {
                    result.isDuplicate = true;
                    result.matchedFieldNames = matchedFields;
                    result.ruleName = groupName;
                    String action = groupRules[0].Action_On_Create__c;
                    if (action == 'Block') {
                        result.isBlock = true;
                    } else if (action == 'Allow') {
                        result.isAllow = true;
                    }
                    return result; // return early after first match
                }
            }
        }
        return result;
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getMatchingDuplicates
* @description     This method is used to get the matching Accounts with detail When user clicks on View Duplicates in UI while creating a new Account
* ------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static List<Account> getMatchingDuplicates(Map<String, Object> fieldMap, String ruleName) {
        List<Account> duplicates = new List<Account>();
        // Only fetch rules that match the active rule group (not all active rules)
        List<Duplicate_Rule__mdt> rules = [
            SELECT Rule_Name__c, Field__c, Match_Type__c
            FROM Duplicate_Rule__mdt
            WHERE Active__c = true AND Rule_Name__c = :ruleName
        ];
        
        List<String> conditions = new List<String>();
        
        for (Duplicate_Rule__mdt rule : rules) {
            if (fieldMap.containsKey(rule.Field__c)) {
                Object rawVal = fieldMap.get(rule.Field__c);
                if (rawVal == null) continue;
                
                String fieldVal = String.escapeSingleQuotes(String.valueOf(rawVal));
                if (rule.Match_Type__c == 'Exact') {
                    conditions.add(rule.Field__c + ' = \'' + fieldVal + '\'');
                } else if (rule.Match_Type__c == 'Fuzzy') {
                    conditions.add(rule.Field__c + ' LIKE \'' + fieldVal + '%\'');
                }
            }
        }
        
        if (!conditions.isEmpty()) {
            String baseQuery = 'SELECT Id, Name, Phone,Customer_Number__c,CompanyRegistrationNumber__c,CustomerID__c,OwnerId,Owner.Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM Account WHERE IsDeleted = false';
            String finalQuery = baseQuery + ' AND (' + String.join(conditions, ' AND ') + ')';
            duplicates = Database.query(finalQuery);
        }
        
        return duplicates;
    }
    
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     saveAccountRecord
* @description     This method is used by LWC component(customNewButtonOnAccount) when user clicks on Save button to allow the users to save the record
* ------------------------------------------------------------------------------------------------------
*/
    
    @AuraEnabled
    public static Id saveAccountRecord(Map<String, Object> fields) {
        Account acc = new Account();
        
        // Get the field describe map once
        Map<String, SObjectField> fieldDefs = Schema.SObjectType.Account.fields.getMap();
        
        for (String fieldName : fields.keySet()) {
            if (fieldName == 'Id') continue;
            
            if (fieldDefs.containsKey(fieldName)) {
                Schema.DisplayType dtype = fieldDefs.get(fieldName).getDescribe().getType();
                Object value = fields.get(fieldName);
                
                if (value == null) continue;
                try {
                    switch on dtype {
                        when INTEGER {
                            acc.put(fieldName, Integer.valueOf(String.valueOf(value)));
                        }
                        when DOUBLE {
                            acc.put(fieldName, Double.valueOf(String.valueOf(value)));
                        }
                        when CURRENCY {
                            acc.put(fieldName, Decimal.valueOf(String.valueOf(value)));
                        }
                        when BOOLEAN {
                            acc.put(fieldName, Boolean.valueOf(String.valueOf(value)));
                        }
                        when DATE {
                            acc.put(fieldName, Date.valueOf(String.valueOf(value)));
                        }
                        when DATETIME {
                            try {
                                String rawValue = String.valueOf(value);
                                // Remove the 'Z' and replace 'T' with space
                                rawValue = rawValue.replace('T', ' ').replace('Z', '');
                                // Remove milliseconds if present
                                if (rawValue.contains('.')) {
                                    rawValue = rawValue.substring(0, rawValue.indexOf('.'));
                                }
                                acc.put(fieldName, Datetime.valueOfGmt(rawValue));
                            } catch (Exception e) {
                                throw new AuraHandledException('Invalid datetime format for field ' + fieldName + ': ' + String.valueOf(value));
                            }
                        }
                        when else {
                            acc.put(fieldName, value);
                        }
                    }
                } catch (Exception ex) {
                    System.debug(' Field conversion error for field: ' + fieldName +
                                 ', Value: ' + value +
                                 ', Expected Type: ' + dtype +
                                 ', Error: ' + ex.getMessage());
                }
            }
        }
        
        // Insert with duplicate rule override
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(acc, dmlOpts); 
        
        if (sr.isSuccess()) {
            return sr.getId();
        } else {
            String errorMsg = ' Save failed: ';
            for (Database.Error err : sr.getErrors()) {
                errorMsg += err.getMessage() + ' ';
            }
            throw new AuraHandledException(errorMsg.trim());
        }
    }
    /*
* ------------------------------------------------------------------------------------------------------
* @Method Name     updateState
* @description     This method is used to update the state name on Account after Account creation
* ------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static void updateState(Account acc) {
        if (acc == null) {
            return;
        }
        try {
            Account existing = [SELECT Id,BillingState FROM Account WHERE Id = :acc.Id LIMIT 1];
            if (acc.BillingState != null) {
                existing.BillingState = acc.BillingState;
            }
            if (acc.BillingStateCode != null) {
                existing.BillingStateCode = acc.BillingStateCode;
            }
            update existing;
        } catch (Exception e) {
            System.debug(' Error updating account: ' + e.getMessage());
        }
    }
}