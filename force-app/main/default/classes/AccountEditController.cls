/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     AccountEditController
* @author             Swami Goskula<Swami.goskula@consulant.volvo.com>
* @Created Date       04-06-2025 
* @Used By            LWC Component on Edit Button on Account
* ------------------------------------------------------------------------------------------
* @description        Used in LWC Component which is used in Edit Button on Account Record Page to Let the users save the Existing Accounts and also to find the
duplicates based on Duplicate rule in Org(Added in Duplicate Rule Metadata)
* ------------------------------------------------------------------------------------------
*/

public class AccountEditController {
    public class DuplicateRuleResult {
        @AuraEnabled public Boolean isDuplicate; 
        @AuraEnabled public Boolean isBlock; 
        @AuraEnabled public Boolean isAllow; 
        @AuraEnabled public List<String> matchedFieldNames; 
        @AuraEnabled public String ruleName;
        
        @AuraEnabled public List<Account> matchedAccounts;
    }
    @AuraEnabled(cacheable=false)
    public static DuplicateRuleResult checkDuplicateRules(Map<String, Object> fieldMap) {
        DuplicateRuleResult result = new DuplicateRuleResult();
        result.isDuplicate = false;
        result.isBlock = false;
        result.isAllow = false;
        result.matchedFieldNames = new List<String>();
        result.matchedAccounts = new List<Account>();
        
        List<Duplicate_Rule__mdt> rules = [
            SELECT Rule_Name__c, Field__c, Match_Type__c, Action_On_Edit__c, Operation__c, Order__c
            FROM Duplicate_Rule__mdt
            WHERE Active__c = true
            ORDER BY Order__c ASC, Rule_Name__c
        ];
        
        Map<String, List<Duplicate_Rule__mdt>> ruleGroups = new Map<String, List<Duplicate_Rule__mdt>>();
        for (Duplicate_Rule__mdt rule : rules) {
            if (!ruleGroups.containsKey(rule.Rule_Name__c)) {
                ruleGroups.put(rule.Rule_Name__c, new List<Duplicate_Rule__mdt>());
            }
            ruleGroups.get(rule.Rule_Name__c).add(rule);
        }
        
        Id currentRecordId = fieldMap.containsKey('Id') ? (Id)fieldMap.get('Id') : null;
        
        for (String groupName : ruleGroups.keySet()) {
            List<Duplicate_Rule__mdt> groupRules = ruleGroups.get(groupName);
            List<String> queryConditions = new List<String>();
            
            for (Duplicate_Rule__mdt ruleItem : groupRules) {
                if (fieldMap.containsKey(ruleItem.Field__c) && fieldMap.get(ruleItem.Field__c) != null) {
                    String val = String.escapeSingleQuotes(String.valueOf(fieldMap.get(ruleItem.Field__c)).trim());
                    
                    if (ruleItem.Match_Type__c == 'Exact') {
                        queryConditions.add(ruleItem.Field__c + ' = \'' + val + '\'');
                    } else if (ruleItem.Match_Type__c == 'Fuzzy') {
                        queryConditions.add(ruleItem.Field__c + ' LIKE \'' + val + '%\'');
                    }
                }
            }
            
            if (queryConditions.isEmpty()) {
                continue;
            }
            
            String queryStr = 'SELECT Id, Name, BillingCity, BillingCountry,CompanyRegistrationNumber__c,Customer_Number__c, CustomerID__c,Owner.Alias,Phone FROM Account WHERE IsDeleted = false';
            if (currentRecordId != null) {
                queryStr += ' AND Id != \'' + currentRecordId + '\'';
            }
            queryStr += ' AND (' + String.join(queryConditions, ' OR ') + ')';
            
            List<Account> potentialMatches = Database.query(queryStr);
            List<Account> fullyMatchedAccounts = new List<Account>();
            
            for (Account acc : potentialMatches) {
                Boolean allMatch = true;
                List<String> matchedFields = new List<String>();
                
                for (Duplicate_Rule__mdt ruleItem : groupRules) {
                    Object inputVal = fieldMap.get(ruleItem.Field__c);
                    Object dbVal = acc.get(ruleItem.Field__c);
                    
                    if (inputVal == null || dbVal == null) {
                        allMatch = false;
                        break;
                    }
                    
                    String inputStr = String.valueOf(inputVal).trim().toLowerCase();
                    String dbStr = String.valueOf(dbVal).trim().toLowerCase();
                    
                    if (ruleItem.Match_Type__c == 'Exact' && inputStr != dbStr) {
                        allMatch = false;
                        break;
                    } else if (ruleItem.Match_Type__c == 'Fuzzy' && !dbStr.startsWith(inputStr)) {
                        allMatch = false;
                        break;
                    } else {
                        matchedFields.add(ruleItem.Field__c);
                    }
                }
                
                if (allMatch) {
                    fullyMatchedAccounts.add(acc);
                }
            }
            
            if (!fullyMatchedAccounts.isEmpty()) {
                result.isDuplicate = true;
                result.matchedFieldNames = groupRules.size() > 0 ? new List<String>{ groupRules[0].Field__c } : new List<String>();
                result.ruleName = groupName;
                result.matchedAccounts = fullyMatchedAccounts;                
                String action = groupRules[0].Action_On_Edit__c;
                result.isBlock = (action == 'Block');
                result.isAllow = (action == 'Allow');
                
                return result;
            }
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountDetails(Id recordId) {
        try {
            return [SELECT Name, BillingStreet, BillingCity, BillingState, BillingStateCode, BillingCountry, BillingPostalCode 
                    FROM Account WHERE Id = :recordId LIMIT 1];
        } catch (Exception e) {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Account> getDuplicateAccounts(String accountId, String accountName, String billingCountry) {
        
        
        try {
            List<Account> potentialMatches = [
                SELECT Id, Name,CustomerID__c,Customer_Number__c,Phone,Owner.Alias, BillingStreet, BillingCity, BillingCountry, BillingStateCode 
                FROM Account 
                WHERE BillingCountry = :billingCountry 
                AND Id != :accountId
            ];
            
            List<Account> fuzzyMatchedAccounts = new List<Account>();
            
            for (Account acc : potentialMatches) {
                Integer distance = getLevenshteinDistance(accountName.toLowerCase(), acc.Name.toLowerCase());
                Double similarity = 1 - ((Double)distance / Math.max(accountName.length(), acc.Name.length()));
                
                if (similarity >= 0.9) { 
                    fuzzyMatchedAccounts.add(acc);
                }
            }
            
            return fuzzyMatchedAccounts;
        } catch (Exception e) {
            return new List<Account>();
        }
    }
    public static Integer getLevenshteinDistance(String s1, String s2) {
        if (s1.equals(s2)) return 0;
        
        Integer len1 = s1.length(), len2 = s2.length();
        
        List<List<Integer>> dp = new List<List<Integer>>();
        
        for (Integer i = 0; i <= len1; i++) {
            dp.add(new List<Integer>()); 
            for (Integer j = 0; j <= len2; j++) {
                dp[i].add(j == 0 ? i : (i == 0 ? j : 0));
            }
        }
        
        for (Integer i = 1; i <= len1; i++) {
            for (Integer j = 1; j <= len2; j++) {
                Integer cost = (s1.charAt(i - 1) == s2.charAt(j - 1)) ? 0 : 1;
                dp[i][j] = Math.min(dp[i - 1][j] + 1, Math.min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost));
            }
        }
        return dp[len1][len2];
    }    
    
    @AuraEnabled
    public static Map<String, Object> updateMultipleAccounts(Map<String, Object> acc) {
        Map<String, Object> result = new Map<String, Object>();
        List<String> errors = new List<String>();
        
        if (acc == null || !acc.containsKey('Id')) {
            result.put('success', false);
            result.put('errors', new List<String>{'Account Id is missing.'});
            return result;
        }
        
        Id accId = (Id) acc.get('Id');
        Account existing = new Account(Id = accId);
        
        for (String fieldName : acc.keySet()) {
            if (fieldName != 'Id') {
                try {
                    Object value = acc.get(fieldName);
                    if (value == null) continue;
                    if (fieldName == 'NumberOfEmployees' || fieldName == 'Fleet_Size__c') {
                        value = Integer.valueOf(String.valueOf(value));
                    }                   
                        if (fieldName == 'Invoices_Fetched_On__c') {
                            String raw = String.valueOf(acc.get('Invoices_Fetched_On__c'));
                            raw = raw.replace('T', ' ').replace('Z', '');
                            if (raw.contains('.')) {
                                raw = raw.substring(0, raw.indexOf('.'));
                            }
                            value = Datetime.valueOfGmt(String.valueOf(raw));
                            
                        }                   
                    if (fieldName == 'Credit_Assessment_Date__c') {
                        value = Date.valueOf(String.valueOf(value));
                    }
                    
                    existing.put(fieldName, value);
                } catch (Exception e) {
                    errors.add('Error parsing field ' + fieldName + ': ' + e.getMessage());
                }
            }
        }
        
        if (!errors.isEmpty()) {
            result.put('success', false);
            result.put('errors', errors);
            return result;
        }
        
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.DuplicateRuleHeader.allowSave = true;
        dmlOpts.DuplicateRuleHeader.runAsCurrentUser = true;
        existing.setOptions(dmlOpts);
        
        Database.SaveResult sr = Database.update(existing, dmlOpts); 
        result.put('success', true);
        
        if (sr.isSuccess()) {
            return result;
        } else {
            String errorMsg = ' Save failed: ';
            for (Database.Error err : sr.getErrors()) {
                errorMsg += err.getMessage() + ' ';
            }
            throw new AuraHandledException(errorMsg.trim());
            
        }
        
    }
}