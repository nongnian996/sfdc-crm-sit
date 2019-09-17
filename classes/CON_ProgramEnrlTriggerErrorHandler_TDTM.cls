global class CON_ProgramEnrlTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__Program_Enrollment__c> oldMap = new Map<String,hed__Program_Enrollment__c>();
        	for(hed__Program_Enrollment__c program : (List<hed__Program_Enrollment__c>)oldlist) {
        		oldMap.put(program.Id,program);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(hed__Program_Enrollment__c program : (List<hed__Program_Enrollment__c>)newlist) {
        		// the new record is not the latest
        		if(program.ModifiedDate_by_CSO__c!=null && oldMap.get(program.Id).ModifiedDate_by_CSO__c!=null && program.ModifiedDate_by_CSO__c < oldMap.get(program.Id).ModifiedDate_by_CSO__c) {
                   program.addError(errorMessage('CSO',oldMap.get(program.Id).ModifiedDate_by_CSO__c,program.ModifiedDate_by_CSO__c));
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