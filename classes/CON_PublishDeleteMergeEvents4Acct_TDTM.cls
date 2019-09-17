/************************************************************************************
Class Name : PublishDeleteMergeEvents4Lead
Version : 1.0 
Created Date : 08/01/2019
Function : publish an event for account merge/delete

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/01/2019               Version 1.0
*************************************************************************************/

global class CON_PublishDeleteMergeEvents4Acct_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedAccountIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        CustomNotificationSetting__c setting = CustomNotificationSetting__c.getInstance();
        if(!setting.Account_Notification__c) {
            return null;
        }
        List<AccountCustomNotification__e> deleteMergeEventsList = new List<AccountCustomNotification__e>();
        System.debug('Running CON_PublishDeleteMergeEvents4Acct_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.AfterDelete) {
            System.debug('CON_PublishDeleteMergeEvents4Acct_TDTM Context: AfterDelete');
            Set<Id> masterRecordIdSet = new Set<Id>();
            Map<Id, Id> acctMap = new Map<Id, Id>();
            for(Account acct : (list<Account>)oldList) {
                // AccountCustomNotification__e evnt = new AccountCustomNotification__e();
                // evnt.CRMoDId__c = acct.Id;
                if(acct.MasterRecordId != null && acct.MasterRecordId != acct.Id) {
                    masterRecordIdSet.add(acct.MasterRecordId);
                    acctMap.put(acct.Id, acct.MasterRecordId);
                }
            }
            System.debug(LoggingLevel.INFO, '*** masterRecordIdSet: ' + masterRecordIdSet);
            Map<Id, Account> masterContMap = new Map<Id, Account>([Select Id, CRMOD_External_ID__c From Account Where Id IN: masterRecordIdSet And CRMOD_External_ID__c != null]);
            System.debug(LoggingLevel.INFO, '*** masterContMap: ' + masterContMap);
            for(Account acct : (list<Account>)oldList) {
                AccountCustomNotification__e evnt = new AccountCustomNotification__e();
                evnt.Type__c = 'Delete';
                if(acct.MasterRecordId != null && acct.MasterRecordId != acct.Id && masterContMap.containsKey(acct.MasterRecordId)) {
                    evnt.MergedCRMoDId__c  = masterContMap.get(acct.MasterRecordId).CRMOD_External_ID__c;
                }
                if(acct.CRMOD_External_ID__c != null) {
                    evnt.CRMoDId__c = acct.CRMOD_External_ID__c;
                }
                if(evnt.MergedCRMoDId__c != null && evnt.CRMoDId__c != null) {
                    evnt.Type__c = 'Merge';
                }
                System.debug(LoggingLevel.INFO, '*** evnt: ' + evnt);
                if(evnt.CRMoDId__c != null) {
                    deleteMergeEventsList.add(evnt);
                }
            }
            System.debug(LoggingLevel.INFO, '*** deleteMergeEventsList: ' + deleteMergeEventsList);
            if(deleteMergeEventsList.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(deleteMergeEventsList);
                System.debug(LoggingLevel.INFO, '*** results: ' + results);
            }
        }
        return null;
    }
}