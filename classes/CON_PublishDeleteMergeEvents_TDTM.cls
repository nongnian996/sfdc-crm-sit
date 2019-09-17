// Trigger Handler Class on Contact, to set Merged_Contacts__c field on Contact Merge

global class CON_PublishDeleteMergeEvents_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        CustomNotificationSetting__c setting = CustomNotificationSetting__c.getInstance();
        if(!setting.Contact_Notification__c) {
            return null;
        }
        List<ContactCustomNotification__e> deleteMergeEventsList = new List<ContactCustomNotification__e>();
        System.debug('Running CON_PublishDeleteMergeEvents_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.AfterDelete) {
            System.debug('CON_PublishDeleteMergeEvents_TDTM Context: AfterDelete');
            Set<Id> masterRecordIdSet = new Set<Id>();
            Map<Id, Id> contMap = new Map<Id, Id>();
            for(Contact con : (list<Contact>)oldList) {
                // ContactCustomNotification__e evnt = new ContactCustomNotification__e();
                // evnt.CRMoDId__c = con.Id;
                if(con.MasterRecordId != null && con.MasterRecordId != con.Id) {
                    masterRecordIdSet.add(con.MasterRecordId);
                    contMap.put(con.Id, con.MasterRecordId);
                }
            }
            System.debug(LoggingLevel.INFO, '*** masterRecordIdSet: ' + masterRecordIdSet);
            Map<Id, Contact> masterContMap = new Map<Id, Contact>([Select Id, CRMOD_External_ID__c From Contact Where Id IN: masterRecordIdSet And CRMOD_External_ID__c != null]);
            System.debug(LoggingLevel.INFO, '*** masterContMap: ' + masterContMap);
            for(Contact con : (list<Contact>)oldList) {
                ContactCustomNotification__e evnt = new ContactCustomNotification__e();
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