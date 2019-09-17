/**************************************************************************************
Class Name:  GDPR_LeadInformationDownload
Version     : 1.0 
Created Date    : 08/23/2019
Function  : download Lead info

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/23/2019              Original Version
*************************************************************************************/
global with sharing class GDPR_LeadInformationDownload {
	@AuraEnabled
    global static String GDPR_LeadInformationDownload(Id recordId) {
        System.debug('****recordId: '+recordId);
    	Schema.FieldSet leadFieldSet = Schema.SObjectType.Lead.fieldSets.getMap().get('GDPR_Lead_Fields');
        String csvtitle = 'Name';
        String sqlquery = 'SELECT Name';
        for(Schema.FieldSetMember setmember : leadFieldSet.getFields()) {
        	csvtitle += ','+setmember.getLabel();
            sqlquery += ','+setmember.getFieldPath();
        }
        csvtitle +='\n';
        sqlquery += ' FROM Lead WHERE Id =: recordId';
        System.debug('Query SQL: '+ sqlquery);
        List<Lead> masterleadlist = Database.query(sqlquery);
        for(Lead cont : masterleadlist) {
        	csvtitle +=cont.Name;
        	for(Schema.FieldSetMember setmember : leadFieldSet.getFields()) {
        		csvtitle += ',';
        		csvtitle += cont.get(setmember.getFieldPath()) != null ? cont.get(setmember.getFieldPath()) : '';
        	}
        }

        try {
            //lead personal data
	        ContentVersion cv = new ContentVersion();
	        cv.ContentLocation = 'S';
	        cv.VersionData = Blob.valueOf(csvtitle);
	        cv.Title = masterleadlist[0].Name +' Personal Data - '+String.valueOf(System.now())+'.csv';
	        cv.PathOnClient = '/'+masterleadlist[0].Name+' Personal Data.csv';
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
        return 'Success';
    }
}