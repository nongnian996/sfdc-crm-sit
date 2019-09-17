public class CON_ConstituentTriggerErrorHandler_TDTM implements Triggers.Handler {
    public void handle() {
        if(Trigger.isUpdate) {
            //compare ModifiedDate_by_CSO__c
            for(Constituent_Type__c consti : (List<Constituent_Type__c>)Trigger.new) {
                Constituent_Type__c oldconsti = (Constituent_Type__c)Trigger.oldMap.get(consti.Id);
                // the new record is not the latest
                if(consti.ModifiedDate_by_CSO__c!=null && oldconsti.ModifiedDate_by_CSO__c!=null && consti.ModifiedDate_by_CSO__c < oldconsti .ModifiedDate_by_CSO__c) {
                   consti.addError(errorMessage('CSO',oldconsti.ModifiedDate_by_CSO__c,consti.ModifiedDate_by_CSO__c));
                }
            }
        }
    }

    public static String errorMessage(String type,Datetime oldtime,Datetime newtime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type +': can\'t update this record cause ' + oldtime +' > ' + newtime;
    }
}