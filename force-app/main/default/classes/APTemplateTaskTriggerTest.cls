/***********************************************************************************************************
 * Class Name: APTemplateTaskTriggerTest 
 *  class for: APTemplateTaskTrigger trigger test coverage
 * Created Date: 13th Aug 2025
 * Test Coverage as of 13th Aug is 100 %
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      13th Aug 2025           Infosys                
***********************************************************************************************************/
@isTest
private class APTemplateTaskTriggerTest {

    @testSetup
    static void setupData() {
        // Create a Queue (Group) for APTemplateTask__c
        Group queue = new Group(
            Name = 'Test Queue',
            Type = 'Queue',
            DeveloperName = 'Test_Queue'
        );
        insert queue;
        
        
           // Create a Queue (Group) for APTemplateTask__c
        Group queue2 = new Group(
            Name = 'Test Queue2',
            Type = 'Queue',
            DeveloperName = 'Test_Queue2'
        );
        insert queue2;

        
        //Create Action Plan Template Record 
        ActionPlanTemplate__c actionPlanTemplate= new ActionPlanTemplate__c(Name='Test Action Plan Template');
        insert actionPlanTemplate;
        	
            APTemplateTask__c task = new APTemplateTask__c(
            Name = 'Initial Task',
            Action_Plan_Template__c=actionPlanTemplate.id,
            Assigned_To_Id__c=String.valueOf(queue.Id),
            Subject__c='Test Subject',
            DaysFromStart__c=3
        );
        insert task;
        

    }

    @isTest
    static void testInsertWithQueue() {
        // Get queue Id
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name='Test Queue' LIMIT 1].Id;
         String idAsString = String.valueOf(queueId);
        Id templateId = [SELECT Id From ActionPlanTemplate__c where Name='Test Action Plan Template' limit 1].Id;

        System.debug('This is action plan' + queueId + ' ' +templateId );
        Test.startTest();
        // Insert task assigned to queue
        
        APTemplateTask__c task = new APTemplateTask__c(
            Name = 'Queue Task Insert',
            Assigned_To_Id__c = idAsString,
            Action_Plan_Template__c=templateId,
            Subject__c='Test Sub',
            DaysFromStart__c=3
        );
        insert task;
        Test.stopTest();

        // Verify that Assigned_To_Name__c got updated
        task = [SELECT Assigned_To_Name__c FROM APTemplateTask__c WHERE Id = :task.Id];
        System.assertEquals('Test Queue', task.Assigned_To_Name__c,
            'Assigned_To_Name__c should be updated to Queue name on insert');
    }

    @isTest
    static void testUpdateWithQueueChange() {
        // Get queue Id
        Id queueId2 = [SELECT Id FROM Group WHERE Type = 'Queue' and name='Test Queue2' LIMIT 1].Id;
                Id queueId1 = [SELECT Id FROM Group WHERE Type = 'Queue' and name='Test Queue' LIMIT 1].Id;

                Id templateId = [SELECT Id From ActionPlanTemplate__c where Name='Test Action Plan Template' limit 1].Id;

         String idAsString1 = String.valueOf(queueId1);
                 String idAsString2 = String.valueOf(queueId2);

        System.debug('THis is the second queue' + queueId1);

                	
            APTemplateTask__c task1 = new APTemplateTask__c(
            Name = 'Initial Task',
            Action_Plan_Template__c=templateId,
            Assigned_To_Id__c=idAsString1,
            Subject__c='Test Subject',
            DaysFromStart__c=3
        );
        insert task1;

        // Get an existing task from setup
        APTemplateTask__c task = [SELECT Id, Assigned_To_Id__c, Assigned_To_Name__c
                                  FROM APTemplateTask__c
                                  WHERE Id =: task1.id
                                  LIMIT 1];
        System.debug('THis is the template task '+task);

        Test.startTest();
        // Update Assigned_To_Id__c to the queue
        task.Assigned_To_Id__c = idAsString2;
        update task;
        Test.stopTest();

        // Verify that Assigned_To_Name__c got updated
        task = [SELECT Assigned_To_Name__c FROM APTemplateTask__c WHERE Id = :task.Id];
        System.assertEquals('Test Queue2', task.Assigned_To_Name__c,
            'Assigned_To_Name__c should be updated to Queue name on update');
    }

   /* @isTest
    static void testNoChangeWhenSameQueueName() {
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1].Id;

        // Insert with queue already
        APTemplateTask__c task = new APTemplateTask__c(
            Name = 'Queue Task Same Name',
            Assigned_To_Id__c = queueId,
            Assigned_To_Name__c = 'Test Queue'
        );
        insert task;

        Test.startTest();
        // Update but keep same Assigned_To_Id__c and Assigned_To_Name__c
        task.Name = 'Queue Task Same Name Updated';
        update task;
        Test.stopTest();

        // Verify name is still the same
        task = [SELECT Assigned_To_Name__c FROM APTemplateTask__c WHERE Id = :task.Id];
        System.assertEquals('Test Queue', task.Assigned_To_Name__c,
            'Assigned_To_Name__c should remain same if already correct');
    }*/
}