/************************************************************************************
Class Name : HotActivity4LeadConversionBatch
Version : 1.0 
Created Date : 08/28/2019
Function : Auto convert lead to Account, Contact, Opportunity when there's a hot activity coming in salesforce

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/28/2019               Version 1.0
*************************************************************************************/
global class HotActivity4LeadConversionBatch implements Database.Batchable<sObject> {
    public String query;

    global HotActivity4LeadConversionBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Activity__c> activityList = (List<Activity__c>)scope;
        System.debug(LoggingLevel.INFO, '*** activityList: ' + activityList);
        Set<String> leadIdSet = new Set<String>();
        for(Activity__c activity : activityList) {
            if(activity.Lead__c != null) {
                leadIdSet.add(activity.Lead__c);
            }
        }
        Map<Id, Lead> convertedLeadMap = new Map<Id, Lead>();
        for(Lead ld : [Select Id, ConvertedContactId, IsConverted From Lead Where Id IN: leadIdSet And IsConverted = true]) {
            convertedLeadMap.put(ld.Id, ld);
        }
        for(Activity__c activity : activityList) {
            if(activity.Contact__c != null) {
                HotActivity4LeadConversionHandler.autoTagOpportunity2Contact(activity, activity.Contact__c, true);
            }else if(activity.Lead__c != null) {
                if(convertedLeadMap.containsKey(activity.Lead__c)) {
                    HotActivity4LeadConversionHandler.autoTagOpportunity2Contact(activity, convertedLeadMap.get(activity.Lead__c).ConvertedContactId, true);
                }else {
                    HotActivity4LeadConversionHandler.autoConvertLead(activity);
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}