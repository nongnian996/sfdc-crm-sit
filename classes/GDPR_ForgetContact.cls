/**************************************************************************************
Class Name:  GDPR_ForgetContact
Version     : 1.0 
Created Date    : 08/26/2019
Function  : delete contact and related records: Address, Course Connection, Program Enrollment,Activities

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/26/2019            Original Version
*************************************************************************************/
public class GDPR_ForgetContact {
	@AuraEnabled
    public static String InitTips() {
    	return System.Label.Contact_Delete_Tips;
    }

	@AuraEnabled
    public static String DeleteContactAndRelatedRecords(String recordId) {
    	ResponseMsg rmsg = new ResponseMsg();
    	System.debug('*****'+recordId);
    	Savepoint sp = Database.setSavepoint();
    	try {
    		// query contact info 
    	    List<Contact> contlist = [SELECT Id,Name,CSO_Empl_ID__c,
    								(SELECT Id FROM hed__Addresses__r WHERE hed__Parent_Contact__c=: recordId),
    								(SELECT Id FROM hed__Student_Course_Enrollments__r WHERE hed__Contact__c =: recordId),
    								(SELECT Id FROM hed__Program_Enrollments__r WHERE hed__Contact__c=: recordId)
    								 FROM Contact WHERE Id=:recordId];
	    	System.debug('delete contact info: '+contlist);

	    	if(contlist[0].CSO_Empl_ID__c != null) {
	    		rmsg.result = 'Warning';
	    		rmsg.msg = System.Label.CSO_Contact_Cant_Delete;
	    		return JSON.serialize(rmsg);
	    	}

	    	//standard activities
	    	List<Task> tasklist = [SELECT Id FROM Task WHERE WhoId =: recordId];

	    	//standard activities
	    	List<Event> eventlist = [SELECT Id FROM Event WHERE WhoId =: recordId];

	    	//delete Address
	    	if(contlist[0].hed__Addresses__r.size() != 0) {
	    		delete contlist[0].hed__Addresses__r;
	    	}
	    	//delete Course Connection
	    	if(contlist[0].hed__Student_Course_Enrollments__r.size() != 0) {
	    		delete contlist[0].hed__Student_Course_Enrollments__r;
	    	}
	    	//delete Program Enrollment
	    	if(contlist[0].hed__Program_Enrollments__r.size() != 0) {
	    		delete contlist[0].hed__Program_Enrollments__r;
	    	}
	    	if(tasklist.size() != 0) {
	    		delete tasklist;
	    	}

	    	if(eventlist.size() != 0) {
	    		delete eventlist;
	    	}

	    	//delete contact
	    	if(contlist.size() !=0 ) {
	    		delete contlist;
	    	}

	    	rmsg.result = 'Successfully';
	    	rmsg.msg = [SELECT Id FROM ListView WHERE SObjectType = 'Contact' AND DeveloperName = 'RecentlyViewedContacts'].Id;
    	}
    	catch (Exception e) {
    	    System.debug('excp message: '+e.getMessage()+e.getLineNumber());
    	    rmsg.result = System.Label.Error_Message_Tips;
    	    Database.rollback(sp);
    	}
  		return JSON.serialize(rmsg);
    }

    public class ResponseMsg {
    	@AuraEnabled
    	public String result;
    	@AuraEnabled
    	public String msg;
    }
}