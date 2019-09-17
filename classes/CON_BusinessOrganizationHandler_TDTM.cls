global class CON_BusinessOrganizationHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        System.debug('Running CON_BusinessOrganizationHandler_TDTM....');
        Set<String> accountIdSet = new Set<String>();
        ID typeId = getRecordTypeId();
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            for(Contact cont : (list<Contact>)newlist) {
                if(cont.hed__Primary_Organization__c != null) {
                    System.debug(LoggingLevel.INFO, '*** 111: ' + cont.hed__Primary_Organization__c);
                    continue;
                }
                System.debug(LoggingLevel.INFO, '*** cont.AccountId: ' + cont.AccountId);
                if(cont.AccountId != null) {
                    accountIdSet.add(cont.AccountId);
                }
            }
            System.debug(LoggingLevel.INFO, '*** accountIdSet: ' + accountIdSet);
            Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, RecordTypeId From Account Where Id IN: accountIdSet And RecordTypeId =: typeId]);
            System.debug(LoggingLevel.INFO, '*** accountMap: ' + accountMap);
            Map<String, List<Contact>> acctContMap = new Map<String, List<Contact>>();
            for(Contact cont : (list<Contact>)newlist) {
                System.debug(LoggingLevel.INFO, '*** cont.hed__Primary_Organization__c: ' + cont.hed__Primary_Organization__c);
                if(accountMap.containsKey(cont.AccountId) && cont.hed__Primary_Organization__c == null) {
                    System.debug(LoggingLevel.INFO, '*** cont.AccountId xxx: ' + cont.AccountId);
                    cont.hed__Primary_Organization__c = cont.AccountId;
                    cont.AccountId = null;
                }else {
                    System.debug(LoggingLevel.INFO, '*** 222: ' + 222);
                }
            }
        }
        




        // if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        //     Map<Id, Contact> oldContMap = new Map<Id, Contact>();
        //     for(Contact cont : (list<Contact>)oldlist) {
        //         oldContMap.put(cont.Id, cont);
        //     }
        //     for(Contact cont : (list<Contact>)newlist) {
        //         Contact oldCont = oldContMap.get(cont.Id);
        //         System.debug(LoggingLevel.INFO, '*** cont.Do_Not_Call_text__c: ' + cont.Do_Not_Call_text__c);
        //         System.debug(LoggingLevel.INFO, '*** oldCont.Do_Not_Call_text__c: ' + oldCont.Do_Not_Call_text__c);
        //         if(cont.Do_Not_Call_text__c != oldCont.Do_Not_Call_text__c) {
        //             cont.DoNotCall = (cont.Do_Not_Call_text__c == null || 'N' == cont.Do_Not_Call_text__c)? false : true;
        //         }
        //         if(cont.hed__Do_Not_Contact__c != oldCont.hed__Do_Not_Contact__c) {
        //             cont.hed__Do_Not_Contact__c = (cont.Do_Not_Contact_text__c == null || 'N' == cont.Do_Not_Contact_text__c)? false : true;
        //         }
        //         if(cont.Do_Not_Call_text__c != oldCont.Do_Not_Call_text__c) {
        //             cont.Do_Not_Mail__c = (cont.Do_Not_Mail_text__c == null || 'N' == cont.Do_Not_Mail_text__c)? false : true;
        //         }
        //     }
        // }
        return null;
    }

    public static ID getRecordTypeId() {
         ID recordtypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Organization' AND SObjectType = 'Account' ].Id;
         return recordtypeId;
    }
}