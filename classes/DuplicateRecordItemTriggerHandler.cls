/********************************************************************************************
Class Name : DuplicateRecordItemTriggerHandler
Version : 1.0
CreatedDate : 06/18/2019
Function : when duplicate record generated, assigned to the record type and email address fields, that we can notice the user

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             06/18/2019                Version 1.0
*********************************************************************************************/
public class DuplicateRecordItemTriggerHandler implements Triggers.Handler {
    public void handle() {
    	//get the custom setting all values named duplicate notice email
    	Map<String,Duplicate_Notice_Email__c> emailMaps = Duplicate_Notice_Email__c.getAll();
    	for(DuplicateRecordItem recorditem : (List<DuplicateRecordItem>)Trigger.new) {
    		//get the object Name from Record Id method:
            //Id.getSobjectType().getDescribe().getName()   
    		if(recorditem.RecordId.getSobjectType().getDescribe().getName() == 'Account') {
    			recorditem.Record_Type__c = 'Account';
    			recorditem.Email_Address__c = emailMaps.get('Account Email').Email_Address__c;
    		}else if(recorditem.RecordId.getSobjectType().getDescribe().getName() == 'Contact') {
    			recorditem.Record_Type__c = 'Contact';
    			recorditem.Email_Address__c = emailMaps.get('Contact Email').Email_Address__c;
    		}else if(recorditem.RecordId.getSobjectType().getDescribe().getName() == 'Lead') {
    			recorditem.Record_Type__c = 'Lead';
    			recorditem.Email_Address__c = emailMaps.get('Lead Email').Email_Address__c;
    		}
    	}
    }
}