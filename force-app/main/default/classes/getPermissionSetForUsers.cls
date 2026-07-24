global without sharing class getPermissionSetForUsers implements Schedulable
{
global void execute(SchedulableContext SC) 
{
List<User_Permission_Set__c> perSetListDel=new List<User_Permission_Set__c>();
perSetListDel =[select Id from User_Permission_Set__c];
delete perSetListDel;
        
AggregateResult[] groupedResults =[SELECT Assignee.Name userName,Assignee.Email userEmail,Assignee.Country userCountry,PermissionSet.Name perName  FROM PermissionSetAssignment WHERE permissionSet.IsOwnedByProfile = FALSE and Assignee.IsActive = TRUE and Assignee.Country != null and Assignee.Email != 'rsandoval@00d2p000000pbrleak' group by PermissionSet.Name,Assignee.Name ,Assignee.Email ,Assignee.Country];
System.debug('This is set'+groupedResults);
List<User_Permission_Set__c> perSetList=new List<User_Permission_Set__c>();
for(integer i=0 ;i<groupedResults.size(); i++)
{
    
User_Permission_Set__c obj=new User_Permission_Set__c();
obj.Name=groupedResults[i].get('perName').toString();
obj.User_Name__c=groupedResults[i].get('userName').toString();
obj.Email__c=groupedResults[i].get('userEmail').toString();
obj.Country__c=groupedResults[i].get('userCountry').toString();



perSetList.add (obj); 
}

System.debug('This is th elist'+ perSetList);
insert perSetList;
   }
}