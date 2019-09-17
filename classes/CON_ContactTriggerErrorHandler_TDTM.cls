global class CON_ContactTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_ContactTriggerErrorHandler_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Contact> oldMap = new Map<Id, Contact>();
            for(Contact cont : (list<Contact>)oldlist) {
                oldMap.put(cont.Id, cont);
            }
            System.debug('CON_ContactTriggerErrorHandler_TDTM Context: BeforeUpdate');
            Map<Id, Contact> contMap = new Map<Id, Contact>();
            Set<Id> idSet = new Set<Id>();
            for(Contact cont : (list<Contact>)newlist) {
                Contact oldCont = oldMap.get(cont.Id); 
                if(String.isBlank(cont.LastModifiedBy__c) || cont.LastModifiedBy__c == 'Salesforce') {
                    continue;
                }
                if(oldCont.LastModifiedDate_CRMoD__c == cont.LastModifiedDate_CRMoD__c 
                    && oldCont.LastModifiedDate_Eloqua__c == cont.LastModifiedDate_Eloqua__c 
                    && oldCont.LastModifiedDate_ProSoft__c == cont.LastModifiedDate_ProSoft__c) {
                    continue;
                }
                idSet.add(cont.Id);
            }
            for(Contact cont : [Select Id, LastModifiedBy__c, LastModifiedDate_CRMoD__c, LastModifiedDate_Eloqua__c, LastModifiedDate_ProSoft__c From Contact Where Id IN: idSet]) {
                contMap.put(cont.Id, cont);
            }
            for(Contact cont : (list<Contact>)newlist) {

                if(!oldMap.containsKey(cont.Id)) continue;

                try {
                    System.debug(LoggingLevel.INFO, '*** cont.LastModifiedBy__c: ' + cont.LastModifiedBy__c);
                    Contact oldCont = oldMap.get(cont.Id); 
                    if(cont.LastModifiedDate_CRMoD__c != null && oldCont.LastModifiedDate_CRMoD__c > cont.LastModifiedDate_CRMoD__c) {
                        cont.addError(errorMessage('CRMoD', oldCont.LastModifiedDate_CRMoD__c, cont.LastModifiedDate_CRMoD__c));
                    }
                    
                    System.debug(LoggingLevel.INFO, '*** : ' + (oldCont.LastModifiedDate_Eloqua__c > cont.LastModifiedDate_Eloqua__c));
                    if(cont.LastModifiedDate_Eloqua__c != null && oldCont.LastModifiedDate_Eloqua__c > cont.LastModifiedDate_Eloqua__c) {
                        cont.addError(errorMessage('Eloqua', oldCont.LastModifiedDate_Eloqua__c, cont.LastModifiedDate_Eloqua__c));
                    }
                    if(cont.LastModifiedDate_ProSoft__c != null && oldCont.LastModifiedDate_ProSoft__c > cont.LastModifiedDate_ProSoft__c) {
                        cont.addError(errorMessage('CSO', oldCont.LastModifiedDate_ProSoft__c, cont.LastModifiedDate_ProSoft__c));
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