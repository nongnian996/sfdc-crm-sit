global class CON_ApplicationTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,Application__c> oldMap = new Map<String,Application__c>();
        	for(Application__c Application : (List<Application__c>)oldlist) {
        		oldMap.put(Application.Id,Application);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(Application__c Application : (List<Application__c>)newlist) {
        		// the new record is not the latest
        		if(Application.ModifiedDate_by_CSO__c!=null && oldMap.get(Application.Id).ModifiedDate_by_CSO__c!=null && Application.ModifiedDate_by_CSO__c < oldMap.get(Application.Id).ModifiedDate_by_CSO__c) {
                   Application.addError(errorMessage('CSO',oldMap.get(Application.Id).ModifiedDate_by_CSO__c,Application.ModifiedDate_by_CSO__c));
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