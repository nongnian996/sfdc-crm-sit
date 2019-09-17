global class CON_ProgramPlanTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__Program_Plan__c> oldMap = new Map<String,hed__Program_Plan__c>();
        	for(hed__Program_Plan__c pplan : (List<hed__Program_Plan__c>)oldlist) {
        		oldMap.put(pplan.Id,pplan);
        	}

        	//compare Modified_by_CSO_Date__c
        	for(hed__Program_Plan__c pplan : (List<hed__Program_Plan__c>)newlist) {
        		// the new record is not the latest
        		if(pplan.Modified_by_CSO_Date__c!=null && oldMap.get(pplan.Id).Modified_by_CSO_Date__c!=null && pplan.Modified_by_CSO_Date__c < oldMap.get(pplan.Id).Modified_by_CSO_Date__c) {
                   pplan.addError(errorMessage('CSO',oldMap.get(pplan.Id).Modified_by_CSO_Date__c,pplan.Modified_by_CSO_Date__c));
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