/**************************************************************************************
Class Name:  GDPR_ForgetLead
Version     : 1.0 
Created Date    : 08/26/2019
Function  : delete lead and related records: Activities

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon              08/26/2019              Original Version
*************************************************************************************/
public with sharing class GDPR_ForgetLead {
    @AuraEnabled
    public static String InitTips() {
        return System.Label.Lead_Delete_Tips;
    }
    @AuraEnabled
    public static String DeleteLeadAndRelatedRecords(String recordId) {
    	ResponseMsg rmsg = new ResponseMsg();
    	System.debug('*****'+recordId);
    	Savepoint sp = Database.setSavepoint();
    	try {
    		// query contact info 
    	    List<Contact> leadlist = [SELECT Id,Name FROM Contact WHERE Id=:recordId];
	    	System.debug('delete lead info: '+leadlist);
	    	//standard activities
	    	List<Task> tasklist = [SELECT Id FROM Task WHERE WhoId =: recordId];

	    	//standard activities
	    	List<Event> eventlist = [SELECT Id FROM Event WHERE WhoId =: recordId];

	    	//delete contact
	    	if(leadlist.size() !=0 ) {
	    		delete leadlist;
	    	}

	    	if(tasklist.size() != 0) {
	    		delete tasklist;
	    	}

	    	if(eventlist.size() != 0) {
	    		delete eventlist;
	    	}
	    	
	    	rmsg.result = 'ok';
	    	rmsg.msg = [SELECT Id FROM ListView WHERE SObjectType = 'Lead' AND DeveloperName = 'RecentlyViewedLeads'].Id;
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