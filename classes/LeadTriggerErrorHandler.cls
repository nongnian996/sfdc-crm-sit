/************************************************************************************
Class Name : LeadTriggerErrorHandler
Version : 1.0 
Created Date : 08/05/2019
Function : Handle error message for each data source

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/05/2019               Version 1.0
*************************************************************************************/

global class LeadTriggerErrorHandler implements Triggers.Handler {
   //global Static Map<ID, Set<ID>> mapMergedLeadIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    public void handle() {
        List<Id> leadIdList = new List<Id>();
        if(Trigger.isBefore && Trigger.isUpdate) {
        
            Map<Id, Lead> oldMap = (Map<Id, Lead>)Trigger.oldMap;
            System.debug('LeadTriggerErrorHandler Context: BeforeUpdate');
            // Map<Id, Lead> ldMap = new Map<Id, Lead>();
            // Set<Id> idSet = new Set<Id>();
            // for(Lead ld : (list<Lead>)Trigger.new) {
            //     Lead oldLead = oldMap.get(ld.Id); 
            //     if(String.isBlank(ld.Data_Source__c) || ld.Data_Source__c == 'Salesforce') continue;
            //     System.debug(LoggingLevel.INFO, 'CRMoD *** new datetime: ' + ld.LastModifiedDate_CRMoD__c + ' *** old datetime: ' + oldLead.LastModifiedDate_CRMoD__c);
            //     System.debug(LoggingLevel.INFO, 'Eloqua *** new datetime: ' + ld.LastModifiedDate_Eloqua__c + ' *** old datetime: ' + oldLead.LastModifiedDate_Eloqua__c);
            //     System.debug(LoggingLevel.INFO, 'PeopleSoft *** new datetime: ' + ld.LastModifiedDate_ProSoft__c + ' *** old datetime: ' + oldLead.LastModifiedDate_ProSoft__c);

            //     if(ld.Data_Source__c == 'CRM OD' && oldLead.LastModifiedDate_CRMoD__c == ld.LastModifiedDate_CRMoD__c) continue;
            //     if(ld.Data_Source__c == 'Eloqua' && oldLead.LastModifiedDate_Eloqua__c == ld.LastModifiedDate_Eloqua__c) continue;
            //     if(ld.Data_Source__c == 'PeopleSoft' && oldLead.LastModifiedDate_ProSoft__c == ld.LastModifiedDate_ProSoft__c) continue;
                
            //     idSet.add(ld.Id);
            // }
            // for(Lead ld : [Select Id, Data_Source__c, LastModifiedDate_CRMoD__c, LastModifiedDate_Eloqua__c, LastModifiedDate_ProSoft__c From Lead Where Id IN: idSet]) {
            //     ldMap.put(ld.Id, ld);
            // }
            for(Lead ld : (list<Lead>)Trigger.new) {

                if(!oldMap.containsKey(ld.Id)) continue;

                try {
                    System.debug(LoggingLevel.INFO, '*** ld.Data_Source__c: ' + ld.Data_Source__c);
                    Lead oldLead = oldMap.get(ld.Id); 
                    if(ld.LastModifiedDate_CRMoD__c != null && oldLead.LastModifiedDate_CRMoD__c > ld.LastModifiedDate_CRMoD__c) {
                        ld.addError(errorMessage('CRMoD', oldLead.LastModifiedDate_CRMoD__c, ld.LastModifiedDate_CRMoD__c));
                    }
                    
                    System.debug(LoggingLevel.INFO, '*** : ' + (oldLead.LastModifiedDate_Eloqua__c > ld.LastModifiedDate_Eloqua__c));
                    if(ld.LastModifiedDate_Eloqua__c != null && oldLead.LastModifiedDate_Eloqua__c > ld.LastModifiedDate_Eloqua__c) {
                        
                        ld.addError(errorMessage('Eloqua', oldLead.LastModifiedDate_Eloqua__c, ld.LastModifiedDate_Eloqua__c));
                    }
                    if(ld.LastModifiedDate_ProSoft__c != null && oldLead.LastModifiedDate_ProSoft__c > ld.LastModifiedDate_ProSoft__c) {
                        ld.addError(errorMessage('PeopleSoft', oldLead.LastModifiedDate_ProSoft__c, ld.LastModifiedDate_ProSoft__c));
                    }
                }catch(Exception ex) {
                    System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
                }
            }
        }
    }

    public static String errorMessage(String type, Datetime newDatetime, Datetime oldDatetime) {
        return type + ': can\'t update this record cause ' + newDatetime + ' > ' + oldDatetime;
    }
}