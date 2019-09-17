/************************************************************************************
Class Name : PublishDeleteMergeEvents4Lead
Version : 1.0 
Created Date : 08/01/2019
Function : publish an event for lead merge/delete

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/01/2019               Version 1.0
*************************************************************************************/
public without sharing class PublishDeleteMergeEvents4Lead implements Triggers.Handler {

    public void handle() {

        CustomNotificationSetting__c setting = CustomNotificationSetting__c.getInstance();
        if(!setting.Lead_Notification__c) {
            return;
        }
        /***
        List<Id> leadIdList = new List<Id>();
        if(Trigger.isBefore && Trigger.isInsert) {
            for(Lead ld : (List<Lead>) Trigger.new) {
                
                if(ld.LastName == null) ld.LastName = '<Individual>';
                if(ld.Company == null) ld.Company = ld.FirstName + ' ' + ld.LastName + ' ' + 'Administrative Account';
            }
            
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            for(Lead ld : (List<Lead>) Trigger.new) {
                
            }
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            for(Lead newLead : (List<Lead>) Trigger.new) {
                Lead oldLead = (Lead)Trigger.oldMap.get(newLead.Id);
            }
        }
        ***/

        List<LeadCustomNotification__e> deleteMergeEventsList = new List<LeadCustomNotification__e>();
        Set<Id> masterRecordIdSet = new Set<Id>();
        Map<Id, Id> contMap = new Map<Id, Id>();
        for(Lead con : (List<Lead>)Trigger.old) {
            // LeadCustomNotification__e evnt = new LeadCustomNotification__e();
            // evnt.CRMoDId__c = con.Id;
            if(con.MasterRecordId != null && con.MasterRecordId != con.Id) {
                masterRecordIdSet.add(con.MasterRecordId);
                contMap.put(con.Id, con.MasterRecordId);
            }
        }
        System.debug(LoggingLevel.INFO, '*** masterRecordIdSet: ' + masterRecordIdSet);
        Map<Id, Lead> masterContMap = new Map<Id, Lead>([Select Id, CRMOD_External_ID__c From Lead Where Id IN: masterRecordIdSet And CRMOD_External_ID__c != null]);
        System.debug(LoggingLevel.INFO, '*** masterContMap: ' + masterContMap);
        for(Lead con : (List<Lead>)Trigger.old) {
            System.debug(LoggingLevel.INFO, '*** con: ' + con);
            LeadCustomNotification__e evnt = new LeadCustomNotification__e();
            evnt.Type__c = 'Delete';
            if(con.MasterRecordId != null && con.MasterRecordId != con.Id && masterContMap.containsKey(con.MasterRecordId)) {
                evnt.MergedCRMoDId__c  = masterContMap.get(con.MasterRecordId).CRMOD_External_ID__c;
            }
            if(con.CRMOD_External_ID__c != null) {
                evnt.CRMoDId__c = con.CRMOD_External_ID__c;
            }
            if(evnt.MergedCRMoDId__c != null && evnt.CRMoDId__c != null) {
                evnt.Type__c = 'Merge';
            }
            System.debug(LoggingLevel.INFO, '*** evnt: ' + evnt);
            if(evnt.CRMoDId__c != null) {
                deleteMergeEventsList.add(evnt);
            }
            System.debug(LoggingLevel.INFO, '*** evnt: ' + evnt);
        }
        System.debug(LoggingLevel.INFO, '*** deleteMergeEventsList: ' + deleteMergeEventsList);
        if(deleteMergeEventsList.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(deleteMergeEventsList);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
        }
    }
}