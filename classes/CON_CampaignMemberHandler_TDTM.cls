/************************************************************************************
Class Name : CON_CampaignMemberHandler_TDTM
Version : 1.0 
Created Date : 09/03/2019
Function : find campaign by crm campaign id or eloqua campaign id

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/10/2019               Version 1.0
*************************************************************************************/
global class CON_CampaignMemberHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_CampaignMemberHandler_TDTM....');
        Set<String> eloquaCampaignIdSet = new Set<String>();
        Set<String> crmCampaignIdSet = new Set<String>();
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            for(CampaignMember member : (list<CampaignMember>)newlist) {
                // if(member.CampaignId.getSobjectType().getDescribe().getName() == 'Lead')
                if(member.CampaignId != null && member.CampaignId.getSobjectType().getDescribe().getName() == 'Campaign') {
                    continue;
                }
                if(member.Eloqua_Campaign_Id__c != null) {
                    eloquaCampaignIdSet.add(member.Eloqua_Campaign_Id__c);
                }
                if(member.CRM_Campaign_Id__c != null) {
                    crmCampaignIdSet.add(member.CRM_Campaign_Id__c);
                }
            }

            System.debug(LoggingLevel.INFO, '*** eloquaCampaignIdSet: ' + eloquaCampaignIdSet);
            System.debug(LoggingLevel.INFO, '*** crmCampaignIdSet: ' + crmCampaignIdSet);
            //tag task to campaign
            Map<String, Campaign> campaignMap = new Map<String, Campaign>();
            for(Campaign camp : [Select Id, Eloqua_Campaign_Id__c, CRM_Campaign_Id__c, Integration_ID__c From Campaign Where (Eloqua_Campaign_Id__c != null And Eloqua_Campaign_Id__c IN: eloquaCampaignIdSet) OR (CRM_Campaign_Id__c != null And CRM_Campaign_Id__c IN: crmCampaignIdSet) OR (Integration_ID__c != null And Integration_ID__c IN: crmCampaignIdSet)]) {
                if(camp.Eloqua_Campaign_Id__c != null) {
                    campaignMap.put(camp.Eloqua_Campaign_Id__c, camp);
                }
                if(camp.CRM_Campaign_Id__c != null) {
                    campaignMap.put(camp.CRM_Campaign_Id__c, camp);
                }
                if(camp.Integration_ID__c != null) {
                    campaignMap.put(camp.Integration_ID__c, camp);
                }
            }
            System.debug(LoggingLevel.INFO, '*** campaignMap: ' + campaignMap);
            for(CampaignMember member : (list<CampaignMember>)newlist) {
                if(member.CampaignId != null && member.CampaignId.getSobjectType().getDescribe().getName() == 'Campaign') {
                    continue;
                }
                if(member.CampaignId == null && member.Eloqua_Campaign_Id__c != null && campaignMap.containsKey(member.Eloqua_Campaign_Id__c)) {
                    member.CampaignId = campaignMap.get(member.Eloqua_Campaign_Id__c).Id;
                }
                if(member.CampaignId == null && member.CRM_Campaign_Id__c != null && campaignMap.containsKey(member.CRM_Campaign_Id__c)) {
                    member.CampaignId = campaignMap.get(member.CRM_Campaign_Id__c).Id;
                }
            }
        }
        return null;
    }
}