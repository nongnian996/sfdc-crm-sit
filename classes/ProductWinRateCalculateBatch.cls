/************************************************************************
Class Name : ProductWinRateCalculateBatch
Version : 1.0
CreatedDate : 07/18/2019
Function :  Product1 :=  Is_Programme__c = True AND RecordType.DeveloperName = OEP , AND Product2=: Programme__c = Product1
            Product Win Rate : =  Closed Won Opportunities  / (Closed Won Opportunities + Closed Lost Opportunities - Withdrawn Due to Error)
Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             07/18/2019               Version 1.0
*************************************************************************/
global class ProductWinRateCalculateBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;

    global ProductWinRateCalculateBatch() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id FROM Product2 WHERE Is_Programme__c = True AND RecordType.DeveloperName = \'OEP_Programme\' ';
        System.debug('query sql: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Product2> prodlist = scope;
        Date startdate = Date.today().addYears(-2);
        Date enddate = Date.today().addDays(1);
        System.debug('start date: '+ startdate);
        System.debug('end date: '+ enddate);
        //query last two years opportunity 
        // For 1 Jan 2019, opportunities from 1 Jan 2017 to 31 Dec 2018
        // For 1 Sep 2019, opportunities from 1 Sep 2017 to 31 Aug 2019
        List<OpportunityLineItem> lineitemlist = [SELECT Id,OpportunityId,Product2Id,Opportunity.StageName,Product2.Programme__c
                                                    FROM OpportunityLineItem
                                                    WHERE Product2.Programme__c=: prodlist[0].Id
                                                    AND Opportunity.CreatedDate >=: startdate
                                                    AND Opportunity.CreatedDate <=: enddate];
        System.debug('opportunity product info: '+lineitemlist);
        //calculate number of closed won oppty, closed lost oppty, error oppty
        Set<ID> productSet = new Set<ID>();
        List<Product2> prolist = new List<Product2>();
        productSet.add(prodlist[0].Id);
        Decimal lostnum = 0, winnum = 0, errornum = 0;
        for(OpportunityLineItem lineitem : lineitemlist) {
            productSet.add(lineitem.Product2Id);
            if(lineitem.Opportunity.StageName == 'Closed Won') {
                winnum += 1;
            }
            else if(lineitem.Opportunity.StageName == 'Closed Lost') {
                lostnum += 1;
            }
            else if(lineitem.Opportunity.StageName == 'Withdrawn due to Error') {
                errornum += 1;
            }
        }
        // if total num not equal to 0, then update the product win rate
        if((winnum+lostnum-errornum) > 0) {
            for(ID productId : productSet) {
                Product2 pro = new Product2();
                pro.Id = productId;
                pro.Win_Rate__c = (winnum.divide((winnum+lostnum-errornum),2,System.RoundingMode.HALF_EVEN))*100;
                prolist.add(pro);
            }
        }
        if(prolist.size() != 0) {
            update prolist;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}