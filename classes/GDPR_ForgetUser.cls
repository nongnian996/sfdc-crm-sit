/**************************************************************************************
Class Name:  GDPR_ForgetUser 
Version     : 1.0 
Created Date    : 08/27/2019
Function  : deactived User and related contact , activities data etc

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/27/2019              Original Version
*************************************************************************************/
global class GDPR_ForgetUser {
    Webservice static String UserForget(String recordId) {
        System.debug('***UserId: '+recordId);
        String result;
        try {
            List<User> userlist = [SELECT Id,Name,IsActive,Profile.Name,FirstName,LastName,Email FROM User WHERE Id=:recordId];
            System.debug('userlist info: '+userlist);
            if(!userlist[0].IsActive) {
                result = 'User have already Inactived';
            }
            else if(userlist[0].Profile.Name == 'System Administrator' || userlist[0].Profile.Name == 'Integration User' || userlist[0].Profile.Name == 'Data Management Officer') {
                result = 'User is System Administrator/Integration User/Data Management Officer';
            }
            else {
                //search contact
                List<Contact> contlist = [SELECT Id FROM Contact WHERE FirstName=: userlist[0].FirstName AND LastName=: userlist[0].LastName AND (Email =: userlist[0].Email OR Home_Email__c =: userlist[0].Email OR hed__WorkEmail__c =: userlist[0].Email)];
                if(contlist.size() != 0) {
                    List<hed__Program_Enrollment__c> programlist = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c=: contlist[0].Id];
                    if(programlist.size() !=0 ) {
                        delete programlist;
                    }

                    List<hed__Affiliation__c> affilist = [SELECT Id FROM hed__Affiliation__c WHERE hed__Contact__c=: contlist[0].Id];
                    if(affilist.size() !=0 ) {
                        delete affilist;
                    }

                    List<hed__Relationship__c> relateshiplist = [SELECT Id FROM hed__Relationship__c WHERE hed__Contact__c=: contlist[0].Id];
                    if(relateshiplist.size() !=0 ) {
                        delete relateshiplist;
                    }

                    List<Activity__c> salesactivitylist = [SELECT Id FROM Activity__c WHERE Contact__c=: contlist[0].Id];
                    if(salesactivitylist.size() !=0 ) {
                        delete salesactivitylist;
                    }

                    List<Task> tasklist = [SELECT Id FROM Task WHERE WhoId=: contlist[0].Id];
                    if(tasklist.size() !=0 ) {
                        delete tasklist;
                    }

                    List<Event> eventlist = [SELECT Id FROM Event WHERE WhoId=: contlist[0].Id];
                    if(eventlist.size() !=0 ) {
                        delete eventlist;
                    }
                    delete contlist;
                }  
                userlist[0].IsActive = false;
                update userlist[0];
                //User data is not visible
                System.UserManagement.obfuscateUser(userlist[0].Id);
                result = 'Successfully';
            }
        }
        catch (Exception e) {
            System.debug('exception msg:' +e.getMessage() + e.getLineNumber());
            result = System.Label.Error_Message_Tips;
        }
        return result;
    }
}