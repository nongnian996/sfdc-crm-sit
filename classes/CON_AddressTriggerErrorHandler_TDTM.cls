global class CON_AddressTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__Address__c> oldMap = new Map<String,hed__Address__c>();
        	for(hed__Address__c address : (List<hed__Address__c>)oldlist) {
        		oldMap.put(address.Id,address);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(hed__Address__c address : (List<hed__Address__c>)newlist) {
        		// the new record is not the latest
        		if(address.ModifiedDate_by_CSO__c!=null && oldMap.get(address.Id).ModifiedDate_by_CSO__c!=null && address.ModifiedDate_by_CSO__c < oldMap.get(address.Id).ModifiedDate_by_CSO__c) {
                   address.addError(errorMessage('CSO',oldMap.get(address.Id).ModifiedDate_by_CSO__c,address.ModifiedDate_by_CSO__c));
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