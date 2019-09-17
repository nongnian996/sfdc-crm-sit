/**************************************************************************************
Class Name:  OpportunityProductFieldUpdate
Version     : 1.0 
Created Date    : 09/09/2019
Function    : when opportunity create or opportunity stage changed, then the related opportunity product oppty stage field update

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             09/09/2019              Original Version
*************************************************************************************/
global class OpportunityProductFieldUpdate extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       	if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
       		Set<String> idSet = new Set<String>();
       		for(Opportunity oppty : (List<Opportunity>)newlist) {
       			idSet.add(oppty.Id);
       		}
       		List<Opportunity> opptylist = [SELECT Id,StageName,(SELECT Id,Opportunity_Stage__c FROM OpportunityLineItems ) FROM Opportunity WHERE Id IN : idSet];
       		List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
       		for(Opportunity oppty : opptylist) {
       			for(OpportunityLineItem item : oppty.OpportunityLineItems) {
       				item.Opportunity_Stage__c = oppty.StageName;
       				itemlist.add(item);
       			}
       		}
       		if(itemlist.size() != 0) {
       			update itemlist;
       		}
       	}

       	if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
       		Set<String> idSet = new Set<String>();
       		Map<String,Opportunity> oldMap = new Map<String,Opportunity>();
       		for(Opportunity oppty : (List<Opportunity>)oldlist) {
       			oldMap.put(oppty.Id,oppty);
       		}
       		for(Opportunity oppty : (List<Opportunity>)newlist) {
       			Opportunity oldoppty = oldMap.get(oppty.Id);
       			if(oppty.StageName != oldoppty.StageName) {
       				idSet.add(oppty.Id);
       			}
       		}
       		List<Opportunity> opptylist = [SELECT Id,StageName,(SELECT Id,Opportunity_Stage__c FROM OpportunityLineItems ) FROM Opportunity WHERE Id IN : idSet];
       		List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
       		for(Opportunity oppty : opptylist) {
       			for(OpportunityLineItem item : oppty.OpportunityLineItems) {
       				item.Opportunity_Stage__c = oppty.StageName;
       				itemlist.add(item);
       			}
       		}
       		if(itemlist.size() != 0) {
       			update itemlist;
       		}
       	}
       	return null;
    }
}