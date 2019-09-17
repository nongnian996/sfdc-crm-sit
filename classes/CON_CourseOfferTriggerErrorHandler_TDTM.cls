global class CON_CourseOfferTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__Course_Offering__c> oldMap = new Map<String,hed__Course_Offering__c>();
        	for(hed__Course_Offering__c course : (List<hed__Course_Offering__c>)oldlist) {
        		oldMap.put(course.Id,course);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(hed__Course_Offering__c course : (List<hed__Course_Offering__c>)newlist) {
        		// the new record is not the latest
        		if(course.ModifiedDate_by_CSO__c!=null && oldMap.get(course.Id).ModifiedDate_by_CSO__c!=null && course.ModifiedDate_by_CSO__c < oldMap.get(course.Id).ModifiedDate_by_CSO__c) {
                   course.addError(errorMessage('CSO',oldMap.get(course.Id).ModifiedDate_by_CSO__c,course.ModifiedDate_by_CSO__c));
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