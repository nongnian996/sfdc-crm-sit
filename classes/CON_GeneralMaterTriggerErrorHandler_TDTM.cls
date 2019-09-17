public class CON_GeneralMaterTriggerErrorHandler_TDTM implements Triggers.Handler {
    public void handle() {
        if(Trigger.isUpdate) {
            //compare ModifiedDate_by_CSO__c
            for(General_Materials__c material : (List<General_Materials__c>)Trigger.new) {
                General_Materials__c oldmaterial = (General_Materials__c)Trigger.oldMap.get(material.Id);
                // the new record is not the latest
                if(material.ModifiedDate_by_CSO__c!=null && oldmaterial.ModifiedDate_by_CSO__c!=null && material.ModifiedDate_by_CSO__c < oldmaterial .ModifiedDate_by_CSO__c) {
                   material.addError(errorMessage('CSO',oldmaterial.ModifiedDate_by_CSO__c,material.ModifiedDate_by_CSO__c));
                }
            }
        }
    }

    public static String errorMessage(String type,Datetime oldtime,Datetime newtime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type +': can\'t update this record cause ' + oldtime +' > ' + newtime;
    }
}