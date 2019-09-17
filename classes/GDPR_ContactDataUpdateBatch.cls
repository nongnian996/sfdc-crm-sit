/**************************************************************************************
Class Name:  GDPR_ContactDataUpdate
Version    : 1.0 
Created Date   : 08/26/2019
Function  : update these contact opt out field

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/26/2019             Original Version
*************************************************************************************/
global class GDPR_ContactDataUpdateBatch implements Database.Batchable<sObject> {
    public String query;

    global GDPR_ContactDataUpdateBatch() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // five years ago
        Datetime time1 = System.now().addYears(-5);
        Date time2 = Date.today().addYears(-5);
        query = 'SELECT Id,Name,Activity_Date__c,Opt_Out__c,Opt_In_Date__c FROM Contact WHERE Opt_In_Date__c <: time2 OR Activity_Date__c <: time1 limit 50000';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Contact> contlist = new List<Contact>();
        for(Contact cont : (List<Contact>)scope) {
            if(!cont.Opt_Out__c) {
                cont.Opt_Out__c = true;
                contlist.add(cont);
            }
        }
        if(contlist.size() != 0) {
            update contlist;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}