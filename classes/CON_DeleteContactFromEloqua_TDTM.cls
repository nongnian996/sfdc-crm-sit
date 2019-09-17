/************************************************************************************
Class Name : CON_DeleteContactFromEloqua_TDTM
Version : 1.0 
Created Date : 08/13/2019
Function : delete sfdc contact from eloqua

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/13/2019               Version 1.0
*************************************************************************************/

global class CON_DeleteContactFromEloqua_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_DeleteContactFromEloqua_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.AfterDelete) {
            System.debug('CON_DeleteContactFromEloqua_TDTM Context: AfterDelete');
            for(Contact con : (list<Contact>)oldList) {
                // evnt.CRMoDId__c = con.Id;
                if(con.Email != null && con.Eloqua_Contact_ID__c != null) {
                    EloquaRestApiService.deleteEloquaContact(con.Email, con.Id, con.Eloqua_Contact_ID__c, con.MasterRecordId);
                }
            }
        }
        return null;
    }
}