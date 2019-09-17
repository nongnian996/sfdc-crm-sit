/**************************************************************************************
Class Name:  OpportunityRevenueSummaryHandler
Version     : 1.0 
Created Date    : 05/27/2019
Function    : roll up Contract/Delivered Revenue for parent Opportunity

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             05/27/2019              Original Version
*************************************************************************************/
public with sharing class OpportunityRevenueSummaryHandler implements Triggers.Handler {
    public void handle() {
        
        
        Set<String> accountIdSet = new Set<String>();
        Map<String, String> oppAccMap = new Map<String, String>();
        if(Trigger.isAfter && Trigger.isInsert) {
            for(Opportunity opp : (List<Opportunity>) Trigger.new) {
                accountIdSet.add(opp.AccountId);
                oppAccMap.put(opp.Id, opp.AccountId);
            }
            
        }
    }
}