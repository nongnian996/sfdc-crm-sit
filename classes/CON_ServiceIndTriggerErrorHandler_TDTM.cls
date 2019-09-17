public class CON_ServiceIndTriggerErrorHandler_TDTM implements Triggers.Handler {
    public void handle() {
        if(Trigger.isUpdate) {
            //compare ModifiedDate_by_CSO__c
            for(Service_Indicator__c servic : (List<Service_Indicator__c>)Trigger.new) {
                Service_Indicator__c oldservic = (Service_Indicator__c)Trigger.oldMap.get(servic.Id);
                // the new record is not the latest
                if(servic.ModifiedDate_by_CSO__c!=null && oldservic.ModifiedDate_by_CSO__c!=null && servic.ModifiedDate_by_CSO__c < oldservic .ModifiedDate_by_CSO__c) {
                   servic.addError(errorMessage('CSO',oldservic.ModifiedDate_by_CSO__c,servic.ModifiedDate_by_CSO__c));
                }
            }
        }
    }

    public static String errorMessage(String type,Datetime oldtime,Datetime newtime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type +': can\'t update this record cause ' + oldtime +' > ' + newtime;
    }

}