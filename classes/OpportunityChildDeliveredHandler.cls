/**************************************************************************************
Class Name : OpportunityChildDeliveredHandler
Version : 1.0 
Created Date : 07/24/2019
Function : when all of opportunity product delivered equals true, then change the CSP B2B opportunity delivered value to true

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             07/24/2019              Original Version
*************************************************************************************/
public class OpportunityChildDeliveredHandler implements Triggers.Handler{
    public void handle() {
        Set<String> ItemIdSet = new Set<String>();
        //get the opportunity CSP B2B record type Id
        ID recordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CSP_Child_Opportunity'].Id;
        if(Trigger.isInsert) {
            Set<String> idSet = new Set<String>();
            for(OpportunityLineItem item : (List<OpportunityLineItem>)Trigger.new) {
                idSet.add(item.Id);
            }
            List<OpportunityLineItem> itemlist = [SELECT Id,Opportunity.RecordTypeId,Delivered__c FROM OpportunityLineItem WHERE Id IN : idSet];
            for(OpportunityLineItem lineitem : itemlist) {
                //if opportunity product record type equals CSP B2B , and delivered equals true
                if(lineitem.Opportunity.RecordTypeId == recordtypeId) {
                    System.debug('record type Id'+lineitem.Opportunity.RecordTypeId);
                    ItemIdSet.add(lineitem.OpportunityId);
                }
            }
        }
        if(Trigger.isUpdate) {
            Set<String> idSet = new Set<String>();
            for(OpportunityLineItem item : (List<OpportunityLineItem>)Trigger.new) {
                idSet.add(item.Id);
            }
            List<OpportunityLineItem> itemlist = [SELECT Id,Opportunity.RecordTypeId,Delivered__c FROM OpportunityLineItem WHERE Id IN : idSet];
            for(OpportunityLineItem lineitem : itemlist) {
                OpportunityLineItem oldItem = (OpportunityLineItem)Trigger.oldMap.get(lineitem.Id);
                //if opportunity product record type equals CSP B2B , and delivered from false to true
                System.debug('record type Id'+lineitem.Opportunity.RecordTypeId);
                if(lineitem.Opportunity.RecordTypeId == recordtypeId && lineitem.Delivered__c != oldItem.Delivered__c) {
                    ItemIdSet.add(lineitem.OpportunityId);
                }
            }
        }
        
        //get child opportunity info
        List<Opportunity> childopptylist = [SELECT Id,Child_Delivered__c,(SELECT Id,Delivered__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =: ItemIdSet];
        System.debug('childopptylist info: '+childopptylist);
        for(Opportunity oppty : childopptylist) {
            if(oppty.OpportunityLineItems.size() != 0) {
                Integer truenum = oppty.OpportunityLineItems.size();
                for(OpportunityLineItem lineitem : oppty.OpportunityLineItems) {
                    if(lineitem.Delivered__c) {
                        truenum += -1;
                    }
                }
                // all of child opportunity delivered equals true
                if(truenum == 0) {
                    oppty.Child_Delivered__c = true;
                }
                else {
                    oppty.Child_Delivered__c = false;
                }
            }
        }
        if(childopptylist.size() != 0) {
            update childopptylist;
        }
    }
}