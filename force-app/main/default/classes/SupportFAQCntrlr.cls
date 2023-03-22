public without sharing class SupportFAQCntrlr {
    @AuraEnabled
    public static List<Knowledge__kav > getKnowledge(){
        List<Knowledge__kav > knowledgeList = new List<Knowledge__kav >();
        Id userId = UserInfo.getUserId();
        User user = [SELECT Id,Country FROM User WHERE Id = :userId];
        for(Knowledge__kav  kon : [Select Id,Question__c,Answer__c,Knowledge_Region__c,CreatedDate from Knowledge__kav where IsVisibleInCsp=true and PublishStatus='Online' and (Knowledge_Region__c =:user.Country or Knowledge_Region__c = 'Global') ORDER BY CreatedDate Desc]){
            knowledgeList.add(kon); 
        }
        return knowledgeList;
    }
}