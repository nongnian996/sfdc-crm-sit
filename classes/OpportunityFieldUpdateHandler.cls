/**************************************************************************************
Class Name:  OpportunityFieldUpdateHandler
Version     : 1.0 
Created Date    : 07/04/2019
Function    : update Contract Validity field automatically when Stage = 'Contract Issue'

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             07/04/2019              Original Version
*************************************************************************************/
global class OpportunityFieldUpdateHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            for(Opportunity opp : (List<Opportunity>)newlist) {
                if(opp.StageName == 'Contract Issued') opp.Contract_Validity_Date__c = System.today().addMonths(Integer.valueOf(Label.Contract_Validity));
            }
        }
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
            for(Opportunity oppty : (List<Opportunity>)oldlist) {
                oldMap.put(oppty.Id,oppty);
            }
            for(Opportunity opp : (List<Opportunity>)newlist) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                if(opp.StageName != oldOpp.StageName && opp.StageName == 'Contract Issued') {
                    opp.Contract_Validity_Date__c = System.today().addMonths(Integer.valueOf(Label.Contract_Validity));
                }
            }
        }
        return null;
    }
    // public void handle() {
    //     Map<String, String> accountOwnerMap = new Map<String, String>();
    //     if(Trigger.isBefore && Trigger.isInsert) {
    //         for(Opportunity opp : (List<Opportunity>) Trigger.new) {
    //             if(opp.StageName == 'Contract Issued') opp.Contract_Validity_Date__c = System.today().addMonths(Integer.valueOf(Label.Contract_Validity));
    //         }
    //     }
    //     if(Trigger.isBefore && Trigger.isUpdate) {
    //        for(Opportunity opp : (List<Opportunity>) Trigger.new) {
    //            Opportunity oldOpp = ((Map<Id, Opportunity>)Trigger.oldMap).get(opp.Id);
    //            if(opp.StageName != oldOpp.StageName && opp.StageName == 'Contract Issued') {
    //                opp.Contract_Validity_Date__c = System.today().addMonths(Integer.valueOf(Label.Contract_Validity));
    //            }
    //        }
    //     }
    // }
}