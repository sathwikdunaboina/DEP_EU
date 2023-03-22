public without sharing class NewCommunityUserController {
    
    public id newUserId {set;get;}
    
    public User newUser {set;
                         get{
                             if (newUser == null)
                             {                   
                                 newUser = [SELECT id, Name, Username, Country, LanguageLocaleKey 
                                            FROM User 
                                            WHERE id = :newUserId 
                                            LIMIT 1];
                             }
                             return newUser;
                         }
                        }
    
    
    public String newUserName {set;
                               get{
                                   if (newUserName == null)
                                   {
                                       newUserName = newUser.Name;
                                   }
                                   return newUserName;
                               }
                              }
    
    public String newUserUsername {set;
                                   get{
                                       if (newUserUsername == null)
                                       {
                                           newUserUsername = newUser.Username;
                                       }
                                       return newUserUsername;
                                   }
                                  }
    
    public String newUserLanguage {set;
                                   get{
                                       if (newUserLanguage == null)
                                       {
                                           newUserLanguage = newUser.LanguageLocaleKey;
                                       }
                                       return newUserLanguage;
                                   }
                                  }
    
    public String newUserPhone {set;
                                get{
                                    if (newUserPhone == null)
                                    {
                                        newUserPhone = String.valueOf([SELECT id, Phone__c
                                                                       FROM Welcome_Mail_Info__c 
                                                                       WHERE Country__c =: newUser.Country
                                                                       LIMIT 1].Phone__c);
                                    }
                                    return newUserPhone;
                                }
                               }
    
    public String newUserEmail {set;
                                get{
                                    if (newUserEmail == null)
                                    {
                                        newUserEmail = String.valueOf([SELECT id, Email__c
                                                                       FROM Welcome_Mail_Info__c 
                                                                       WHERE Country__c =: newUser.Country
                                                                       LIMIT 1].Email__c);
                                    }
                                    return newUserEmail;
                                }
                               }
}