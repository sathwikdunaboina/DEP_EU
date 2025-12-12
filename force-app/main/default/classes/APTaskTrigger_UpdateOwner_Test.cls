/***********************************************************************************************************
 * Test Class Name: APTaskTrigger_UpdateOwner_Test
 * Test class for: "APTaskTrigger_UpdateAssignedName and TaskTrigger_UpdateOwner" Trigger
 * Created Date: 11th Aug 2025
 * Code coverage for intended Artifact on 11th Aug 2025: 100%
************************************************************************************************************
*******************************************   Changelog   **************************************************
S.No.    Date                    Developer Name         Azure Item Number
(1)      11th Aug 2025           Infosys                
***********************************************************************************************************/

@isTest
public class APTaskTrigger_UpdateOwner_Test {

    @isTest
    
    
    static void testOwnerUpdateFromAPTask() {
        // Create a test user to assign as "Assigned_To_Id__c"
           Group queue = new Group(Name = 'Test Queue', Type = 'Queue');
        insert queue;
        
        
        Group beEotQueue = [
    SELECT Id, Name, DeveloperName, Email
    FROM Group
    WHERE Type = 'Queue'
    AND DeveloperName = 'BE_EOT' // API name of the queue, underscores instead of spaces
    LIMIT 1
];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tusr',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'testuser' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        List<ApTask__c> apTask 
            =APTaskTestHelper.createNonSetupData(queue.Id, testUser.Id);
        System.debug('This is the ApTask List'+apTask[0].Id);
        Id apTaskid=apTask[0].Id;

        // Create APTask__c with Assigned_To_Id__c as our test user
        /*APTask__c apTask = new APTask__c(
            Name = 'User Assigned Task',
            Assigned_To_Id__c = testUser.Id
        );
        insert apTask;
         */
        // Create a Task with a different OwnerId initially
       Task t = new Task(
            Subject = 'Test Task',
            TaskAPTask__c =apTask[0].Id,
            //OwnerId=beEotQueue.Id,
            OwnerId = UserInfo.getUserId(), // current running user, different from testUser
            Status = 'Not Started'
        );
        insert t; // Trigger should fire here

        // Query task again to check if trigger updated it
        Task updatedTask = [SELECT Id, OwnerId, TaskAPTask__c FROM Task WHERE Id = :t.Id LIMIT 1];
          APTask__c 
        queueTask = [
            SELECT Id, Assigned_To_Id__c, Assigned_To_Name__c
            FROM APTask__c
            WHERE Id =: apTaskid
            LIMIT 1
        ];
        System.debug('This is the Action plan task'+queueTask);

        System.assertEquals(beEotQueue.Id, updatedTask.OwnerId,
            'OwnerId should have been updated to match Assigned_To_Id__c from APTask__c');
          System.assertEquals(queueTask.Assigned_To_Name__c, 'BE-EOT');
    }
}