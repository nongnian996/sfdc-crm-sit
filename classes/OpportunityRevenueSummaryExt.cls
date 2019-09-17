/**************************************************************************************
Class Name:  OpportunityRevenueSummaryExt
Version     : 1.0 
Created Date    : 05/30/2019
Function    : Roll up all relate opportunity revenue 

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             05/30/2019              Original Version
*************************************************************************************/
public without sharing class OpportunityRevenueSummaryExt {

    public Opportunity opp { get;set; }
    public Map<String, Decimal> oppRevenueMap { get;set; }

    public Decimal expectedContractRevenue { get;set; }

    public OpportunityRevenueSummaryExt(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.opp = [Select Id, Expected_Contract_Revenue__c From Opportunity Where Id =: this.opp.Id];
        expectedContractRevenue = this.opp.Expected_Contract_Revenue__c == null? 0 : this.opp.Expected_Contract_Revenue__c;
        List<Opportunity> opportunityList = findAllChildrenList(this.opp.Id);
        // Set<String> oppIdSet = new Set<String>{this.acct.Id};
        // for(Opportunity acc : opportunityList) {
        //     oppIdSet.add(acc.Id);
        // }
        oppRevenueMap = doCalculate(opportunityList);
    }

    @AuraEnabled
    public static String doInitialize(String recordId) {
        System.debug(LoggingLevel.INFO, '*** recordId: ' + recordId);
        Opportunity theOpp = [Select Id, Expected_Contract_Revenue__c From Opportunity Where Id =: recordId];
        List<Opportunity> opportunityList = findAllChildrenList(recordId);
        Map<String, Decimal> revenueMap = doCalculate(opportunityList);
        Decimal expectedRevenue = theOpp.Expected_Contract_Revenue__c == null? 0 : theOpp.Expected_Contract_Revenue__c;
        revenueMap.put('expectedRevenue', expectedRevenue);
        return JSON.serialize(revenueMap);
    }

    public static List<Opportunity> findAllChildrenList(String parentId) {
        List<Opportunity> opportunityList;
        List<String> parentIdList = new List<String>{parentId};
        List<Opportunity> childrenList = new List<Opportunity>();
        Boolean endTraversing = false;
        String query = '';
        while(!endTraversing) {
            query = 'select Id, Name, Delivered_Revenues__c, Amount, StageName from Opportunity where CSP_Parent_Opportunity__c IN :parentIdList';
            opportunityList = (List<Opportunity>)Database.query(query);
            if(opportunityList.size() == 0 ) {
               endTraversing = true;
            }else {
               parentIdList.clear();
               // opportunityList.sort();
               Opportunity o;
               for(Integer i = 0; i < opportunityList.size(); i++ ) {
                   o = opportunityList.get(i);
                   parentIdList.add(o.Id);
                   childrenList.add(o);
               }
            }
        }
        System.debug(LoggingLevel.INFO, '*** childrenList.size(): ' + childrenList.size());
        return childrenList;
    }

    public static Map<String, Decimal> doCalculate(List<Opportunity> opportunityList) {
        Decimal totalDeliveredRevenue = 0, totalAmount = 0;
        Map<String, Decimal> revenueMap = new Map<String, Decimal>();
        for(Opportunity opp : opportunityList) {

            totalDeliveredRevenue += opp.Delivered_Revenues__c == null? 0 : opp.Delivered_Revenues__c;

            if(InseadUtil.stageLostSet.contains(opp.StageName)) continue;
            
            totalAmount += opp.Amount == null? 0 : opp.Amount;
        }
        revenueMap.put('totalDeliveredRevenue', totalDeliveredRevenue);
        revenueMap.put('totalAmount', totalAmount);
        System.debug(LoggingLevel.INFO, '*** revenueMap: ' + revenueMap);
        return revenueMap;
    }
}