/**************************************************************************************
Class Name : OpportunityParentDeliveredHandler
Version : 1.0 
Created Date : 07/24/2019
Function : when all of child CSP B2B opportunity delivered equals true, then change the CSP Parent opportunity delivered value to true

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             07/24/2019              Original Version
*************************************************************************************/
global class OpportunityParentDeliveredHandler extends hed.TDTM_Runnable {
     global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    	//get the opportunity CSP B2B record type Id
    	ID recordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CSP_Child_Opportunity'].Id;
    	Set<String> opptyIdSet = new Set<String>();
    	if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
    		for(Opportunity oppty : (List<Opportunity>)newlist) {
	        	//if opportunity record type equals CSP B2B
	        	if(oppty.RecordTypeId == recordtypeId && oppty.CSP_Parent_Opportunity__c != null) {
	        		opptyIdSet.add(oppty.CSP_Parent_Opportunity__c);
	        	}
	        }
    	}
    	if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<String,Opportunity> oldopptyMap = new Map<String,Opportunity>();
            for(Opportunity oppty : (List<Opportunity>)oldlist) {
                oldopptyMap.put(oppty.Id,oppty);
            }
 
    		for(Opportunity oppty : (List<Opportunity>)newlist) {
	        	Opportunity oldoppty = oldopptyMap.get(oppty.Id);
	        	//if opportunity record type equals CSP B2B and Child_Delivered__c change from false to true
	        	if(oppty.RecordTypeId == recordtypeId && oppty.CSP_Parent_Opportunity__c != null && oppty.Child_Delivered__c != oldoppty.Child_Delivered__c) {
	        		opptyIdSet.add(oppty.CSP_Parent_Opportunity__c);
	        	}
	        }
    	}
        
        //get parent opportunity info
        List<Opportunity> parentopptylist = [SELECT Id,Parent_Delivered__c,(SELECT Id,Child_Delivered__c FROM Child_CSP_Opportunities__r) FROM Opportunity WHERE Id =: opptyIdSet];
        System.debug('parentopptylist info: '+parentopptylist);
        for(Opportunity oppty : parentopptylist) {
        	if(oppty.Child_CSP_Opportunities__r.size() != 0) {
        		Integer truenum = oppty.Child_CSP_Opportunities__r.size();
        		for(Opportunity childoppty : oppty.Child_CSP_Opportunities__r) {
        			if(childoppty.Child_Delivered__c) {
        				truenum += -1;
        			}
        		}
        		// all of child opportunity delivered equals true
        		if(truenum == 0) {
        			oppty.Parent_Delivered__c = true;
        		}
        		else {    
        			oppty.Parent_Delivered__c = false;
        		} 
        	}
        }
        if(parentopptylist.size() != 0) {
            update parentopptylist;
        }
        return null;
    }
}