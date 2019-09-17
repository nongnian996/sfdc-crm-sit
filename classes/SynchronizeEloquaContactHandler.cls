/************************************************************************************
Class Name : AutoConvertLeadHandler
Version : 1.0 
Created Date : 07/10/2019
Function : update sfdc contact id and sfdc account id when lead was converted

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/10/2019               Version 1.0
*************************************************************************************/
public without sharing class SynchronizeEloquaContactHandler implements Triggers.Handler {
    public void handle() {
        // List<Id> leadIdList = new List<Id>();
        // Map<String, String> rtMap = InseadUtil.getObjectRecordType('Lead');
        // System.debug(LoggingLevel.INFO, '*** rtMap: ' + rtMap);
        if(Trigger.isAfter && Trigger.isUpdate) {
            for(Lead ld : (List<Lead>) Trigger.new) {
                if(ld.Status == 'Converted' && ld.Email != null && ld.Eloqua_Contact_ID__c != null) {
                    System.debug(LoggingLevel.INFO, '*** ld.Email: ' + ld.Email);
                    System.debug(LoggingLevel.INFO, '*** ld.ConvertedAccountId: ' + ld.ConvertedAccountId);
                    System.debug(LoggingLevel.INFO, '*** ld.ConvertedContactId: ' + ld.ConvertedContactId);
                    System.debug(LoggingLevel.INFO, '*** ld.ConvertedOpportunityId: ' + ld.ConvertedOpportunityId);
                    //call out to update eloqua contact
                    EloquaRestApiService.updateEloquaContact(ld.Email, ld.Id);
                }
            }
            
        }

        if(Trigger.isAfter && Trigger.isDelete) {
            for(Lead ld : (List<Lead>) Trigger.old) {
                if(ld.Email != null && ld.Eloqua_Contact_ID__c != null) {
                    System.debug(LoggingLevel.INFO, '*** ld.Email: ' + ld.Email);
                    System.debug(LoggingLevel.INFO, '*** ld.Id: ' + ld.Id);
                    System.debug(LoggingLevel.INFO, '*** ld.Eloqua_Contact_ID__c: ' + ld.Eloqua_Contact_ID__c);
                    //call out to update eloqua contact
                    EloquaRestApiService.deleteEloquaContact(ld.Email, ld.Id, ld.Eloqua_Contact_ID__c, ld.MasterRecordId);
                }
            }
            
        }
        // if(Trigger.isAfter && Trigger.isInsert) {
        //     for(Lead ld : (List<Lead>) Trigger.new) {
                
        //     }
        // }
        // if(Trigger.isAfter && Trigger.isUpdate) {
        //     for(Lead newLead : (List<Lead>) Trigger.new) {
        //         Lead oldLead = (Lead)Trigger.oldMap.get(newLead.Id);
        //     }
        // }
        // System.debug(LoggingLevel.INFO, '*** leadIdList: ' + leadIdList);
        // if(leadIdList.size() > 0) {
        //     AutoConvertLeads.autoConvert(leadIdList);
        // }
    }
}