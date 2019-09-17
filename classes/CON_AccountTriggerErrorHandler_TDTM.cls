global class CON_AccountTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedAccountIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_AccountTriggerErrorHandler_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Account> oldMap = new Map<Id, Account>();
            for(Account acct : (list<Account>)oldlist) {
                oldMap.put(acct.Id, acct);
            }
            System.debug('CON_AccountTriggerErrorHandler_TDTM Context: BeforeUpdate');
            // Map<Id, Account> acctMap = new Map<Id, Account>();
            // Set<Id> idSet = new Set<Id>();
            // for(Account acct : (list<Account>)newlist) {
                // Account oldAcct = oldMap.get(acct.Id); 
                // if(String.isBlank(acct.Data_Source__c) || acct.Data_Source__c == 'Salesforce') {
                //     continue;
                // }
                

                // if(acct.Data_Source__c == 'CRM OD' && oldAcct.LastModifiedDate_CRMoD__c == acct.LastModifiedDate_CRMoD__c) {
                //     continue;
                // }
                // if(acct.Data_Source__c == 'Eloqua' && oldAcct.LastModifiedDate_Eloqua__c == acct.LastModifiedDate_Eloqua__c) {
                //     continue;
                // }
                // if(acct.Data_Source__c == 'PeopleSoft' && oldAcct.LastModifiedDate_ProSoft__c == acct.LastModifiedDate_ProSoft__c) {
                //     continue;
                // }
                
                // idSet.add(acct.Id);
            // }
            // for(Account acct : [Select Id, Data_Source__c, LastModifiedDate_CRMoD__c, LastModifiedDate_Eloqua__c, LastModifiedDate_ProSoft__c From Account Where Id IN: idSet]) {
            //     acctMap.put(acct.Id, acct);
            // }
            for(Account acct : (list<Account>)newlist) {

                if(!oldMap.containsKey(acct.Id)) continue;

                try {
                    System.debug(LoggingLevel.INFO, '*** acct.Data_Source__c: ' + acct.Data_Source__c);
                    Account oldAcct = oldMap.get(acct.Id); 
                    if(acct.LastModifiedDate_CRMoD__c != null && oldAcct.LastModifiedDate_CRMoD__c > acct.LastModifiedDate_CRMoD__c) {
                        acct.addError(errorMessage('CRMoD', oldAcct.LastModifiedDate_CRMoD__c, acct.LastModifiedDate_CRMoD__c));
                    }
                    
                    System.debug(LoggingLevel.INFO, '*** : ' + (oldAcct.LastModifiedDate_Eloqua__c > acct.LastModifiedDate_Eloqua__c));
                    if(acct.LastModifiedDate_Eloqua__c != null && oldAcct.LastModifiedDate_Eloqua__c > acct.LastModifiedDate_Eloqua__c) {
                        
                        acct.addError(errorMessage('Eloqua', oldAcct.LastModifiedDate_Eloqua__c, acct.LastModifiedDate_Eloqua__c));
                    }
                    if(acct.LastModifiedDate_ProSoft__c != null && oldAcct.LastModifiedDate_ProSoft__c > acct.LastModifiedDate_ProSoft__c) {
                        acct.addError(errorMessage('CSO', oldAcct.LastModifiedDate_ProSoft__c, acct.LastModifiedDate_ProSoft__c));
                    }
                }catch(Exception ex) {
                    System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
                }
                
            }
        }
        return null;
    }

    public static String errorMessage(String type, Datetime oldDatetime, Datetime newDatetime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type + ': can\'t update this record cause ' + oldDatetime + ' > ' + newDatetime;
    }
}