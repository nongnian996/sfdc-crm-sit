/************************************************************************************
Class Name : CON_DeleteAccountFromEloqua_TDTM
Version : 1.0 
Created Date : 08/13/2019
Function : delete sfdc Account from eloqua

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/13/2019               Version 1.0
*************************************************************************************/

global class CON_DeleteAccountFromEloqua_TDTM extends hed.TDTM_Runnable {
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_DeleteAccountFromEloqua_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.AfterDelete) {
            System.debug('CON_DeleteAccountFromEloqua_TDTM Context: AfterDelete');
            for(Account acct : (list<Account>)oldList) {
                EloquaRestApiService.deleteEloquaAccount(acct.Id);
            }
        }
        return null;
    }
}