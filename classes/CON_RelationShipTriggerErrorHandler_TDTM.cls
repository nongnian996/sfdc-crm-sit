global class CON_RelationShipTriggerErrorHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
        	Map<String,hed__RelationShip__c> oldMap = new Map<String,hed__RelationShip__c>();
        	for(hed__RelationShip__c rship : (List<hed__RelationShip__c>)oldlist) {
        		oldMap.put(rship.Id,rship);
        	}

        	//compare ModifiedDate_by_CSO__c
        	for(hed__RelationShip__c rship : (List<hed__RelationShip__c>)newlist) {
        		// the new record is not the latest
        		if(rship.ModifiedDate_by_CSO__c!=null && oldMap.get(rship.Id).ModifiedDate_by_CSO__c!=null && rship.ModifiedDate_by_CSO__c < oldMap.get(rship.Id).ModifiedDate_by_CSO__c) {
                   rship.addError(errorMessage('CSO',oldMap.get(rship.Id).ModifiedDate_by_CSO__c,rship.ModifiedDate_by_CSO__c));
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