/**************************************************************************************
Class Name : UpdateOpportunityOwnerAsPAHandler
Version : 1.0 
Created Date : 09/10/2019
Function : update OEP opportunity owner if there is a opportunity product created

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             09/10/2019             Original Version
*************************************************************************************/
public class UpdateOpportunityOwnerAsPAHandler implements Triggers.Handler{
    public void handle() {
        Set<String> ItemIdSet = new Set<String>();
        //get the opportunity CSP B2B record type Id
        
        Set<String> oepRecordTypeIdSet = new Set<String>();
        Map<String, String> opptyRTMap = InseadUtil.getObjectRecordType('Opportunity');
        for(String rt : opptyRTMap.KeySet()) {
            if(rt.containsIgnoreCase('OEP')) {
                oepRecordTypeIdSet.add(opptyRTMap.get(rt));
            }
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            Set<String> productIdSet = new Set<String>();
            Set<String> opptyIdSet = new Set<String>();
            for(OpportunityLineItem item : (List<OpportunityLineItem>)Trigger.new) {
                productIdSet.add(item.Product2Id);
                opptyIdSet.add(item.OpportunityId);
            }
            Map<Id, Product2> productMap = new Map<Id, Product2>([Select Id, Primary_PA__c, Secondary_PA__c From Product2 Where Id IN: productIdSet]);
            // for(Product2 p : [Select Id, Primary_PA__c, Secondary_PA__c From Product2 Where Id IN: productIdSet]) {
            //     productMap.put(p.Id, p);
            // }
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, OwnerId From Opportunity Where Id IN: opptyIdSet And RecordTypeId IN: oepRecordTypeIdSet]);
            
            Map<Id, Opportunity> opptyUpdateMap = new Map<Id, Opportunity>();
            for(OpportunityLineItem item : (List<OpportunityLineItem>)Trigger.new) {
                Product2 p = productMap.get(item.Product2Id);
                String paId = p.Primary_PA__c == null? p.Secondary_PA__c : p.Primary_PA__c;
                if(paId != null && opportunityMap.containsKey(item.OpportunityId)) {
                    Opportunity oppty = new Opportunity(
                        Id = item.OpportunityId,
                        OwnerId = paId
                    );
                    opptyUpdateMap.put(item.OpportunityId, oppty);
                }
            }
            if(opptyUpdateMap.size() > 0) {
                update opptyUpdateMap.values();
            }
        }
        
    }
}