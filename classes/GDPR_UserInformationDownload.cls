/**************************************************************************************
Class Name:  GDPR_UserInformationDownload
Version     : 1.0 
Created Date    : 08/23/2019
Function  : download User personal info & Contact, Contact Activity etc info

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/23/2019              Original Version
*************************************************************************************/
global class GDPR_UserInformationDownload {
    Webservice static String UserInformationDownload(Id recordId) {
        System.debug('****recordId: '+recordId);
        String result;
        Schema.FieldSet userFieldSet = Schema.SObjectType.User.fieldSets.getMap().get('GDPR_User_Fields');
        String csvtitle = 'User Name';
        String usersqlquery = 'SELECT Name';
        for(Schema.FieldSetMember setmember : userFieldSet.getFields()) {
            csvtitle += ','+setmember.getLabel();
            usersqlquery += ','+setmember.getFieldPath();
        }
        csvtitle +='\n';
        usersqlquery += ' FROM User WHERE Id =: recordId AND IsActive = true';
        System.debug('Query SQL: '+ usersqlquery);
        List<User> masteruserlist = Database.query(usersqlquery);
        try {
            for(User cont : masteruserlist) {
                csvtitle +=cont.Name;
                for(Schema.FieldSetMember setmember : userFieldSet.getFields()) {
                    csvtitle += ',';
                    csvtitle += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                }
            }

            //User personal data
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = Blob.valueOf(csvtitle);
            cv.Title = masteruserlist[0].Name +' Personal Data - '+String.valueOf(System.now())+'.csv';
            cv.PathOnClient = '/'+masteruserlist[0].Name+' Personal Data.csv';
            insert cv;  
            result = 'Success :'+cv.Id; 
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            result = System.Label.Error_Message_Tips;
        }

        try {
            String userfirstname = masteruserlist[0].FirstName,userlastname = masteruserlist[0].LastName,useremail = masteruserlist[0].Email;
            Schema.FieldSet contFieldSet = Schema.SObjectType.Contact.fieldSets.getMap().get('GDPR_Contact_Fields');
            String csvtitle1 = 'Name';
            String sqlquery1 = 'SELECT Name';
            for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
                csvtitle1 += ','+setmember.getLabel();
                sqlquery1 += ','+setmember.getFieldPath();
            }
            csvtitle1 +='\n';
            sqlquery1 += ' FROM Contact WHERE FirstName=: userfirstname AND LastName =: userlastname AND (Email =: useremail OR Home_Email__c =: useremail OR hed__WorkEmail__c =: useremail)';
            System.debug('Query SQL: '+ sqlquery1);
            List<Contact> mastercontlist = Database.query(sqlquery1);
            if(mastercontlist.size() != 0) {
                for(Contact cont : mastercontlist) {
                    csvtitle1 +=cont.Name;
                    for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
                        csvtitle1 += ',';
                        csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                }

                // contact personal data
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = Blob.valueOf(csvtitle1);
                cv.Title = mastercontlist[0].Name +' User Contact Personal Data - '+String.valueOf(System.now())+'.csv';
                cv.PathOnClient = '/'+mastercontlist[0].Name+' Personal Data.csv';
                insert cv;   

                String contactId = mastercontlist[0].Id;

                String csvtitle2;
                //Program Enrollment Data
                Schema.FieldSet enrollFieldSet = Schema.SObjectType.hed__Program_Enrollment__c.fieldSets.getMap().get('GDPR_Program_Enrollment_Fields');
                csvtitle2 = 'Program Enrollment Name';
                String sqlquery2 = 'SELECT Name';
                for(Schema.FieldSetMember setmember : enrollFieldSet.getFields()) {
                    csvtitle2 += ','+setmember.getLabel();
                    sqlquery2 += ','+setmember.getFieldPath();
                }
                csvtitle2 +='\n';
                sqlquery2 += ' FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: contactId';
                System.debug('Query SQL: '+ sqlquery2);
                List<hed__Program_Enrollment__c> enrolllist = Database.query(sqlquery2);
                for(hed__Program_Enrollment__c cont : enrolllist) {
                    csvtitle2 +=cont.Name;
                    for(Schema.FieldSetMember setmember : enrollFieldSet.getFields()) {
                        csvtitle2 += ',';
                        csvtitle2 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                    csvtitle2 += '\n';
                }

                ContentVersion cv1 = new ContentVersion();
                cv1.ContentLocation = 'S';
                cv1.VersionData = Blob.valueOf(csvtitle2);
                cv1.Title = mastercontlist[0].Name +' Related Program Enrolment - '+String.valueOf(System.now())+'.csv';
                cv1.PathOnClient = '/'+mastercontlist[0].Name+' Program Enrolment.csv';
                insert cv1;   

                String csvtitle3;
                //Affiliation Data
                Schema.FieldSet affilFieldSet = Schema.SObjectType.hed__Affiliation__c.fieldSets.getMap().get('GDPR_Affiliation_Fields');
                csvtitle3 += 'Affiliation Name';
                String sqlquery3 = 'SELECT Name';
                for(Schema.FieldSetMember setmember : affilFieldSet.getFields()) {
                    csvtitle3 += ','+setmember.getLabel();
                    sqlquery3 += ','+setmember.getFieldPath();
                }
                csvtitle3 +='\n';
                sqlquery3 += ' FROM hed__Affiliation__c WHERE hed__Contact__c =: contactId';
                System.debug('Query SQL: '+ sqlquery3);
                List<hed__Affiliation__c> affilist = Database.query(sqlquery3);
                for(hed__Affiliation__c cont : affilist) {
                    csvtitle3 +=cont.Name;
                    for(Schema.FieldSetMember setmember : affilFieldSet.getFields()) {
                        csvtitle3 += ',';
                        csvtitle3 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                    csvtitle3 += '\n';
                }

                ContentVersion cv2 = new ContentVersion();
                cv2.ContentLocation = 'S';
                cv2.VersionData = Blob.valueOf(csvtitle3);
                cv2.Title = mastercontlist[0].Name +' Related Affiliation - '+String.valueOf(System.now())+'.csv';
                cv2.PathOnClient = '/'+mastercontlist[0].Name+' Affiliation.csv';
                insert cv2;   

                String csvtitle4;
                //RelationShip Data
                Schema.FieldSet reshipFieldSet = Schema.SObjectType.hed__Relationship__c.fieldSets.getMap().get('GDPR_RelationShip_Fields');
                csvtitle4 += 'RelationShip Name';
                String sqlquery4 = 'SELECT Name';
                for(Schema.FieldSetMember setmember : reshipFieldSet.getFields()) {
                    csvtitle4 += ','+setmember.getLabel();
                    sqlquery4 += ','+setmember.getFieldPath();
                }
                csvtitle4 +='\n';
                sqlquery4 += ' FROM hed__Relationship__c WHERE hed__Contact__c =: contactId';
                System.debug('Query SQL: '+ sqlquery4);
                List<hed__Relationship__c> relationlist = Database.query(sqlquery4);
                for(hed__Relationship__c cont : relationlist) {
                    csvtitle4 +=cont.Name;
                    for(Schema.FieldSetMember setmember : reshipFieldSet.getFields()) {
                        csvtitle4 += ',';
                        csvtitle4 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                }

                ContentVersion cv3 = new ContentVersion();
                cv3.ContentLocation = 'S';
                cv3.VersionData = Blob.valueOf(csvtitle4);
                cv3.Title = mastercontlist[0].Name +' Related Relationship - '+String.valueOf(System.now())+'.csv';
                cv3.PathOnClient = '/'+mastercontlist[0].Name+' Relationship.csv';
                insert cv3;   

                String csvtitle5;
                //Custom Activity Data
                Schema.FieldSet activityFieldSet = Schema.SObjectType.Activity__c.fieldSets.getMap().get('GDPR_Activity_Fields');
                csvtitle5 += 'Activity ID';
                String sqlquery5 = 'SELECT Id';
                for(Schema.FieldSetMember setmember : activityFieldSet.getFields()) {
                    csvtitle5 += ','+setmember.getLabel();
                    sqlquery5 += ','+setmember.getFieldPath();
                }
                csvtitle5 +='\n';
                sqlquery5 += ' FROM Activity__c WHERE Contact__c =: contactId';
                System.debug('Query SQL: '+ sqlquery5);
                List<Activity__c> activitylist = Database.query(sqlquery5);
                for(Activity__c cont : activitylist) {
                    csvtitle5 +=cont.Id;
                    for(Schema.FieldSetMember setmember : activityFieldSet.getFields()) {
                        csvtitle5 += ',';
                        csvtitle5 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                    csvtitle5 += '\n';
                }

                ContentVersion cv4 = new ContentVersion();
                cv4.ContentLocation = 'S';
                cv4.VersionData = Blob.valueOf(csvtitle5);
                cv4.Title = mastercontlist[0].Name +' Related Sales Activities - '+String.valueOf(System.now())+'.csv';
                cv4.PathOnClient = '/'+mastercontlist[0].Name+' Sales Activities.csv';
                insert cv4;   

                String csvtitle6;
                //Standard Activity - Task Data
                Schema.FieldSet taskFieldSet = Schema.SObjectType.Task.fieldSets.getMap().get('GDPR_Task_Fields');
                csvtitle6 += 'Task ID';
                String sqlquery6 = 'SELECT Id';
                for(Schema.FieldSetMember setmember : taskFieldSet.getFields()) {
                    csvtitle6 += ','+setmember.getLabel();
                    sqlquery6 += ','+setmember.getFieldPath();
                }
                csvtitle6 +='\n';
                sqlquery6 += ' FROM Task WHERE WhoId =: contactId';
                System.debug('Query SQL: '+ sqlquery6);
                List<Task> tasklist = Database.query(sqlquery6);
                for(Task cont : tasklist) {
                csvtitle6 +=cont.Id;
                for(Schema.FieldSetMember setmember : taskFieldSet.getFields()) {
                    csvtitle6 += ',';
                    csvtitle6 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                }
                    csvtitle6 +='\n';
                }

                ContentVersion cv5 = new ContentVersion();
                cv5.ContentLocation = 'S';
                cv5.VersionData = Blob.valueOf(csvtitle6);
                cv5.Title = mastercontlist[0].Name +' Related Task Marketing Activities - '+String.valueOf(System.now())+'.csv';
                cv5.PathOnClient = '/'+mastercontlist[0].Name+' Marketing Activities.csv';
                insert cv5;   

                String csvtitle7;
                //Standard Activity - Event Data
                Schema.FieldSet eventFieldSet = Schema.SObjectType.Event.fieldSets.getMap().get('GDPR_Event_Fields');
                csvtitle7 += 'Event ID';
                String sqlquery7 = 'SELECT Id';
                for(Schema.FieldSetMember setmember : eventFieldSet.getFields()) {
                    csvtitle7 += ','+setmember.getLabel();
                    sqlquery7 += ','+setmember.getFieldPath();
                }
                csvtitle7 +='\n';
                sqlquery7 += ' FROM Event WHERE WhoId =: contactId';
                System.debug('Query SQL: '+ sqlquery7);
                List<Event> eventlist = Database.query(sqlquery7);
                for(Event cont : eventlist) {
                    csvtitle7 +=cont.Id;
                    for(Schema.FieldSetMember setmember : eventFieldSet.getFields()) {
                        csvtitle7 += ',';
                        csvtitle7 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
                    }
                    csvtitle7 +='\n';
                }

                ContentVersion cv6 = new ContentVersion();
                cv6.ContentLocation = 'S';
                cv6.VersionData = Blob.valueOf(csvtitle7);
                cv6.Title = mastercontlist[0].Name +' Related Event Marketing Activities - '+String.valueOf(System.now())+'.csv';
                cv6.PathOnClient = '/'+mastercontlist[0].Name+' Marketing Activities.csv';
                insert cv6;   
            }
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            result = System.Label.Error_Message_Tips;
        }
        return result;
    }
}