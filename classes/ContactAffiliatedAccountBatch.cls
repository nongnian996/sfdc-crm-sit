/************************************************************************************
Class Name : ContactAffiliatedAccountBatch
Version : 1.0 
Created Date : 08/02/2019
Function :  1. Find contacts that have primary account = business org record type
            2. create an admin account for the contact (as primary account lookup)..First name + last name + Administrative Account
            3. Take the previously linked business org account and put it as an affiliated account. 
               Primary = True, Affiliation Type = Business Org, Status = Current, and Role = Employee.

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                   08/02/2019              Version 1.0
*************************************************************************************/
global class ContactAffiliatedAccountBatch implements Database.Batchable<sObject> {
    public String query;

    global ContactAffiliatedAccountBatch() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id,FirstName,LastName,AccountId FROM Contact WHERE Account.RecordType.DeveloperName = \'Business_Organization\'';
        System.debug('query sql: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Contact> scope) {
        System.debug('contact info: '+scope);
        ID recordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Administrative'].Id;
        List<hed__Affiliation__c> affiliatedlist = new List<hed__Affiliation__c>();
        for(Contact conts : scope) {
            hed__Affiliation__c affiliated = new hed__Affiliation__c();
            affiliated.hed__Contact__c = conts.Id;
            affiliated.hed__Account__c = conts.AccountId;
            affiliated.hed__Primary__c = true;
            affiliated.hed__Status__c = 'Current';
            affiliated.hed__Role__c = 'Employee'; 
            affiliatedlist.add(affiliated);
        }
        insert affiliatedlist;

        List<Account> acctlist = new List<Account>();
        for(Contact conts : scope) {
            Account acct = new Account(Name=conts.FirstName+' '+conts.LastName+' Administrative Account',RecordTypeId=recordtypeId);
            acctlist.add(acct);
        }
        Database.SaveResult[] srList = Database.insert(acctlist); 

        for(Integer i=0; i< scope.size(); i++) {
            if(srList[i].isSuccess()) {
                scope[i].AccountId = srList[i].getId();
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}