/**************************************************************************************
Class Name:  GDPR_ContactInformationDownload
Version     : 1.0 
Created Date    : 08/23/2019
Function  : download contact and related records: Address, Course Connection, Program Enrollment,Activity

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/23/2019             Original Version
*************************************************************************************/
global class GDPR_ContactInformationDownload {
	@AuraEnabled
    global static String GDPR_ContactInformationDownload(Id recordId) {
    	System.debug('****recordId: '+recordId);
    	Schema.FieldSet contFieldSet = Schema.SObjectType.Contact.fieldSets.getMap().get('GDPR_Contact_Fields');
        String csvtitle = 'Name';
        String sqlquery = 'SELECT Name';
        for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
        	csvtitle += ','+setmember.getLabel();
            sqlquery += ','+setmember.getFieldPath();
        }
        csvtitle +='\n';
        sqlquery += ' FROM Contact WHERE Id =: recordId';
        System.debug('Query SQL: '+ sqlquery);
        List<Contact> mastercontlist = Database.query(sqlquery);
        for(Contact cont : mastercontlist) {
        	csvtitle +=cont.Name;
        	for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
        		csvtitle += ',';
        		csvtitle += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
        	}
        }

        try {
            // contact personal data
	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle);
	        cv.Title = mastercontlist[0].Name +' Personal Data - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Personal Data.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        	System.debug('****'+cv.Id);
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
        	//Program Enrollment Data
            Schema.FieldSet enrollFieldSet = Schema.SObjectType.hed__Program_Enrollment__c.fieldSets.getMap().get('GDPR_Program_Enrollment_Fields');
	        csvtitle1 = 'Program Enrollment Name';
	        String sqlquery3 = 'SELECT Name';
	        for(Schema.FieldSetMember setmember : enrollFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery3 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery3 += ' FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: recordId';
	        System.debug('Query SQL: '+ sqlquery3);
	        List<hed__Program_Enrollment__c> enrolllist = Database.query(sqlquery3);
	        for(hed__Program_Enrollment__c cont : enrolllist) {
	        	csvtitle1 +=cont.Name;
	        	for(Schema.FieldSetMember setmember : enrollFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        	csvtitle1 += '\n';
	        }

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Program Enrolment Academic - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Academic.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
	        //Affiliation Data
            Schema.FieldSet affilFieldSet = Schema.SObjectType.hed__Affiliation__c.fieldSets.getMap().get('GDPR_Affiliation_Fields');
	        csvtitle1 += 'Affiliation Name';
	        String sqlquery1 = 'SELECT Name';
	        for(Schema.FieldSetMember setmember : affilFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery1 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery1 += ' FROM hed__Affiliation__c WHERE hed__Contact__c =: recordId';
	        System.debug('Query SQL: '+ sqlquery1);
	        List<hed__Affiliation__c> affilist = Database.query(sqlquery1);
	        for(hed__Affiliation__c cont : affilist) {
	        	csvtitle1 +=cont.Name;
	        	for(Schema.FieldSetMember setmember : affilFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        	csvtitle1 += '\n';
	        }

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Affiliation Academic - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Academic.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }
		        
        try {
        	String csvtitle1;
	        //RelationShip Data
            Schema.FieldSet reshipFieldSet = Schema.SObjectType.hed__Relationship__c.fieldSets.getMap().get('GDPR_RelationShip_Fields');
	        csvtitle1 += 'RelationShip Name';
	        String sqlquery2 = 'SELECT Name';
	        for(Schema.FieldSetMember setmember : reshipFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery2 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery2 += ' FROM hed__Relationship__c WHERE hed__Contact__c =: recordId';
	        System.debug('Query SQL: '+ sqlquery2);
	        List<hed__Relationship__c> relationlist = Database.query(sqlquery2);
	        for(hed__Relationship__c cont : relationlist) {
	        	csvtitle1 +=cont.Name;
	        	for(Schema.FieldSetMember setmember : reshipFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        }

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Relationship Academic - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Academic.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
        	//Case Data
            Schema.FieldSet caseFieldSet = Schema.SObjectType.Case.fieldSets.getMap().get('GDPR_Case_Fields');
	        csvtitle1 = 'Case ID';
	        String sqlquery3 = 'SELECT Id';
	        for(Schema.FieldSetMember setmember : caseFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery3 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery3 += ' FROM Case WHERE ContactId =: recordId';
	        System.debug('Query SQL: '+ sqlquery3);
	        List<Case> caselist = Database.query(sqlquery3);
	        for(Case cont : caselist) {
	        	csvtitle1 +=cont.Id;
	        	for(Schema.FieldSetMember setmember : caseFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        	csvtitle1 += '\n';
	        }
	   
	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Case Activities - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Activities.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
	        //Custom Activity Data
            Schema.FieldSet activityFieldSet = Schema.SObjectType.Activity__c.fieldSets.getMap().get('GDPR_Activity_Fields');
	        csvtitle1 += 'Activity ID';
	        String sqlquery1 = 'SELECT Id';
	        for(Schema.FieldSetMember setmember : activityFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery1 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery1 += ' FROM Activity__c WHERE Contact__c =: recordId';
	        System.debug('Query SQL: '+ sqlquery1);
	        List<Activity__c> activitylist = Database.query(sqlquery1);
	        for(Activity__c cont : activitylist) {
	        	csvtitle1 +=cont.Id;
	        	for(Schema.FieldSetMember setmember : activityFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        	csvtitle1 += '\n';
	        }

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Sales Activities - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Activities.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
			//Standard Activity - Task Data
			Schema.FieldSet taskFieldSet = Schema.SObjectType.Task.fieldSets.getMap().get('GDPR_Task_Fields');
			csvtitle1 += 'Task ID';
			String sqlquery2 = 'SELECT Id';
			for(Schema.FieldSetMember setmember : taskFieldSet.getFields()) {
				csvtitle1 += ','+setmember.getLabel();
				sqlquery2 += ','+setmember.getFieldPath();
			}
			csvtitle1 +='\n';
			sqlquery2 += ' FROM Task WHERE WhoId =: recordId';
			System.debug('Query SQL: '+ sqlquery2);
			List<Task> tasklist = Database.query(sqlquery2);
			for(Task cont : tasklist) {
			csvtitle1 +=cont.Id;
			for(Schema.FieldSetMember setmember : taskFieldSet.getFields()) {
				csvtitle1 += ',';
				csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
			}
				csvtitle1 +='\n';
			}

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Task Marketing Activities - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Activities.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }

        try {
        	String csvtitle1;
	        //Standard Activity - Event Data
            Schema.FieldSet eventFieldSet = Schema.SObjectType.Event.fieldSets.getMap().get('GDPR_Event_Fields');
	        csvtitle1 += 'Event ID';
	        String sqlquery4 = 'SELECT Id';
	        for(Schema.FieldSetMember setmember : eventFieldSet.getFields()) {
	        	csvtitle1 += ','+setmember.getLabel();
	            sqlquery4 += ','+setmember.getFieldPath();
	        }
	        csvtitle1 +='\n';
	        sqlquery4 += ' FROM Event WHERE WhoId =: recordId';
	        System.debug('Query SQL: '+ sqlquery4);
	        List<Event> eventlist = Database.query(sqlquery4);
	        for(Event cont : eventlist) {
	        	csvtitle1 +=cont.Id;
	        	for(Schema.FieldSetMember setmember : eventFieldSet.getFields()) {
	        		csvtitle1 += ',';
	        		csvtitle1 += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
	        	}
	        	csvtitle1 +='\n';
	        }

	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle1);
	        cv.Title = mastercontlist[0].Name +' Event Marketing Activities - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+mastercontlist[0].Name+' Activities.csv';
	        insert cv;   

	        ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = recordId;
			cdl.ShareType = 'V';
			insert cdl;
        }
        catch (Exception e) {
            System.debug('@@@@@'+e.getMessage()+' '+e.getLineNumber());
            return System.Label.Error_Message_Tips;
        }
        return 'Success';
    }
}