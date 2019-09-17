/************************************************************************************
Class Name : WarmActivity4LeadConversionBatch
Version : 1.0 
Created Date : 08/28/2019
Function : Auto convert lead to Account, Contact, Opportunity when there's a warm activity coming in salesforce

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/28/2019               Version 1.0
*************************************************************************************/
global class WarmActivity4LeadConversionBatch implements Database.Batchable<sObject> {
    public String query;

    global WarmActivity4LeadConversionBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Date today = System.today();
        // Date startDate = today.addDays(Integer.valueOf(Label.START_DAY_NUMBER));
        // Date endDate = today.addDays(Integer.valueOf(Label.END_DAY_NUMBER));
        // query += ' And CreatedDate <=: startDate';
        // query += ' And CreatedDate >=: endDate';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        // System.debug(LoggingLevel.INFO, '*** 111: ' + 111);
        System.debug(LoggingLevel.INFO, '*** scope: ' + scope);
        List<Activity__c> activityList = (List<Activity__c>)scope;

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
            System.debug(LoggingLevel.INFO, '*** activity: ' + activity);
            if(activity.Contact__c != null) {
                WarmActivity4LeadConversionHandler.autoCreateOpportunity4Contact(activity, activity.Contact__c);
            }else if(activity.Lead__c != null) {
                if(convertedLeadMap.containsKey(activity.Lead__c)) {
                    WarmActivity4LeadConversionHandler.autoCreateOpportunity4Contact(activity, convertedLeadMap.get(activity.Lead__c).ConvertedContactId);
                }else {
                    WarmActivity4LeadConversionHandler.autoConvertLead(activity);
                }

                // WarmActivity4LeadConversionHandler.autoConvertLead(activity);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}