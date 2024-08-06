@isTest
public class SupportFAQCntrlrTest {
    @isTest static void testGetKnowledge() {
        List<Knowledge__kav > knowledgeList = new List<Knowledge__kav >();
        for (Integer i = 0; i < 2; i++) {
            knowledge__Kav kav = new knowledge__Kav ();
            kav.Title = 'Test Question' + i;
            kav.UrlName = 'TestQuestion' + i;
            kav.Question__c = 'Test Question' + i;
            kav.Answer__c = 'Test answer'+ i;
            kav.IsVisibleInCsp = true;
            kav.Knowledge_Region__c = 'Global';
            knowledgeList.add(kav);
        }
        insert knowledgeList;
        
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: knowledgeList[0].Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        knowledge__kav obj2 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: knowledgeList[1].Id];
        KbManagement.PublishingService.publishArticle(obj2.KnowledgeArticleId, true);
        
        List<Knowledge__kav > testKnowledgeList = SupportFAQCntrlr.getKnowledge();
        Integer size = testKnowledgeList.size();
        System.assertEquals(2, size);
    }
}