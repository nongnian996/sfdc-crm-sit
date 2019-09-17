/**************************************************************************************
Class Name:  AccountRevenueSummaryExt
Version     : 1.0 
Created Date    : 05/30/2019
Function    : Roll up all relate opportunity revenue 

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             05/30/2019              Original Version
*************************************************************************************/
public without sharing class AccountRevenueSummaryExt {
    
    public Account acct { get;set; }
    public Map<String, Decimal> accountRevenueMap { get;set; }

    public AccountRevenueSummaryExt(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        List<Account> acctList = findAllChildrenList(this.acct.Id);
        Set<String> accountIdSet = new Set<String>{this.acct.Id};
        for(Account acc : acctList) {
            accountIdSet.add(acc.Id);
        }
        accountRevenueMap = doCalculate(accountIdSet);
    }

    @AuraEnabled
    public static String doInitialize(String recordId) {
        System.debug(LoggingLevel.INFO, '*** recordId: ' + recordId);
        List<Account> acctList = findAllChildrenList(recordId);
        Set<String> accountIdSet = new Set<String>{recordId};
        for(Account acc : acctList) {
            accountIdSet.add(acc.Id);
        }
        Map<String, Decimal> accountRevenueMap = doCalculate(accountIdSet);
        return JSON.serialize(accountRevenueMap);
    }
    
    public static List<Account> findAllChildrenList(String parentId) {
        List<Account> acctList;
        List<String> parentIdList = new List<String>{parentId};
        List<Account> childrenList = new List<Account>();
        Boolean endTraversing = false;
        String query = '';
        while(!endTraversing) {
            query = 'select Id, Name, ParentId from Account WHERE ParentId IN :parentIdList';
            acctList = (List<Account>)Database.query(query);
            if(acctList.size() == 0 ) {
               endTraversing = true;
            }else {
               parentIdList.clear();
               // acctList.sort();
               Account a;
               for(Integer i = 0; i < acctList.size(); i++ ) {
                   a = acctList.get(i);
                   parentIdList.add(a.Id);
                   childrenList.add(a);
               }
            }
        }
        System.debug(LoggingLevel.INFO, '*** childrenList.size(): ' + childrenList.size());
        return childrenList;
    }


    // public static List<Opportunity> findAllOpportunityByAccountIds(String ) {
    //     return
    // }

    public static Map<String, Decimal> doCalculate(Set<String> accountIdSet) {

        List<Opportunity> oppList = [Select Id, Name, Delivered_Revenue__c, Amount, StageName From Opportunity Where AccountId IN: accountIdSet];
        Decimal totalDeliveredRevenue = 0, totalAmount = 0, totalWonAmount = 0;
        Map<String, Decimal> revenueMap = new Map<String, Decimal>();
        for(Opportunity opp : oppList) {

            if(InseadUtil.stageLostSet.contains(opp.StageName)) continue;
            
            totalDeliveredRevenue += opp.Delivered_Revenue__c == null? 0 : opp.Delivered_Revenue__c;
            totalAmount += opp.Amount == null? 0 : opp.Amount;
            System.debug(LoggingLevel.INFO, '*** opp.Name: ' + opp.Name);
            System.debug(LoggingLevel.INFO, '*** opp.StageName: ' + opp.StageName);
            if(InseadUtil.stageWonSet.contains(opp.StageName)) {
                totalWonAmount += opp.Amount == null? 0 : opp.Amount;
            }
            System.debug(LoggingLevel.INFO, '*** totalWonAmount: ' + totalWonAmount);
        }
        revenueMap.put('totalDeliveredRevenue', totalDeliveredRevenue);
        revenueMap.put('totalAmount', totalAmount);
        revenueMap.put('totalWonAmount', totalWonAmount);
        return revenueMap;
    }
}