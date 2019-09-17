global class CON_TermTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<String,hed__Term__c> oldMap = new Map<String,hed__Term__c>();
            for(hed__Term__c term : (List<hed__Term__c>)oldlist) {
                oldMap.put(term.Id,term);
            }

            //compare ModifiedDate_by_CSO__c
            for(hed__Term__c term : (List<hed__Term__c>)newlist) {
                // the new record is not the latest
                if(term.ModifiedDate_by_CSO__c!=null && oldMap.get(term.Id).ModifiedDate_by_CSO__c!=null && term.ModifiedDate_by_CSO__c < oldMap.get(term.Id).ModifiedDate_by_CSO__c) {
                   term.addError(errorMessage('CSO',oldMap.get(term.Id).ModifiedDate_by_CSO__c, term.ModifiedDate_by_CSO__c));
                }
            }
        }
        return null;
    }

    public static String errorMessage(String type,Datetime oldtime,Datetime newtime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type +': can\'t update this record cause ' + oldtime +' > ' + newtime;
    }
}