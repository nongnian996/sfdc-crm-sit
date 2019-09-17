/******************************************************************
Class Name : ContactRegionAssignHandler
Version : 1.0 
Created Date : 08/15/2019
Function : contact region field assignment according to the work country field

Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/15/2019               Version 1.0
********************************************************************/
global class ContactRegionAssignHandler extends hed.TDTM_Runnable{
	global String validFor{get;set;}
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        Map<String,List<String>> fieldMap = new Map<String,List<String>>();
        fieldMap = getFieldDependencies('Contact','Work_Country__c','Region__c');
        for(Contact cont : (List<Contact>)newlist) {
        	if(fieldMap.containsKey(cont.Work_Country__c)) {
        		cont.Region__c = fieldMap.get(cont.Work_Country__c)[0];
        	}
        	else {
        		cont.Region__c = 'Others';
        	}
        }
        return null;	
    }

    global static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
    	Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
    	Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    	Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    	Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
    	Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    	List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    	List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

    	for(Schema.PicklistEntry currControllingValue : controllingValues)
    	{
    		controllingInfo.put(currControllingValue.getLabel(), new List<String>());
    	}

    	for(Schema.PicklistEntry currDependentValue : dependentValues)
    	{
    		String jsonString = JSON.serialize(currDependentValue);
    		ContactRegionAssignHandler info = (ContactRegionAssignHandler) JSON.deserialize(jsonString, ContactRegionAssignHandler.class);
    		String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
    		Integer baseCount = 0;
    		for(Integer curr : hexString.getChars())
    		{
    			Integer val = 0;

    			if(curr >= 65)
    			{
    				val = curr - 65 + 10;
    			}
    			else
    			{
    				val = curr - 48;
    			}

    			if((val & 8) == 8)
    			{
    				controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
    			}
    			if((val & 4) == 4)
    			{
    				controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel()); 
    			}
    			if((val & 2) == 2)
    			{
    				controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel()); 
    			}
    			if((val & 1) == 1)
    			{
    				controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel()); 
    			}

    			baseCount += 4;
    		} 
    	}
    	System.debug('ControllingInfo: ' + controllingInfo);
		return controllingInfo;
    }
}