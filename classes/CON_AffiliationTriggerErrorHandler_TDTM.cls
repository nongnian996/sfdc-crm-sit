global class CON_AffiliationTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__Affiliation__c> oldMap = new Map<String,hed__Affiliation__c>();
        	for(hed__Affiliation__c affilia : (List<hed__Affiliation__c>)oldlist) {
        		oldMap.put(affilia.Id,affilia);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(hed__Affiliation__c affilia : (List<hed__Affiliation__c>)newlist) {
        		// the new record is not the latest
        		if(affilia.ModifiedDate_by_CSO__c!=null && oldMap.get(affilia.Id).ModifiedDate_by_CSO__c!=null && affilia.ModifiedDate_by_CSO__c < oldMap.get(affilia.Id).ModifiedDate_by_CSO__c) {
                   affilia.addError(errorMessage('CSO',oldMap.get(affilia.Id).ModifiedDate_by_CSO__c,affilia.ModifiedDate_by_CSO__c));
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