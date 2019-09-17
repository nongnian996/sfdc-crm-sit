/**************************************************************************************
Class Name:  GDPR_ContactOptOutInChangeHandler
Version     : 1.0 
Created Date    : 08/23/2019
Function  : contact some fields assignment

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/23/2019              Original Version
*************************************************************************************/
global class GDPR_ContactOptOutInChangeHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
              if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
                     for(Contact cont : (List<Contact>)newlist) {
                            if(cont.Opt_In__c) {
                                   if(cont.Opt_In_Date__c == null) {
                                          cont.Opt_In_Date__c = Date.today();
                                   }
                                   cont.Opt_Out__c = false;
                            }
                            else if(cont.Opt_Out__c) {
                                   if(cont.Opt_out_Date__c == null) {
                                          cont.Opt_out_Date__c = Date.today();
                                   }
                                   cont.Opt_In__c = false;
                            }
                     }
              }

       	if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
       		Map<ID,Contact> oldMap = new Map<ID,Contact>();
       		for(Contact oldcont : (List<Contact>)oldlist) {
       			oldMap.put(oldcont.Id,oldcont);
       		}

       		for(Contact cont : (List<Contact>)newlist) {
       			//if any of this field is checked, Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC, Subscribe Online Program, Subscribe OEP
 				//then Opt-in field and check Marketable Contact field
       			if(((cont.Subscribe_CCC__c && !oldMap.get(cont.Id).Subscribe_CCC__c)
       			   || (cont.Subscribe_EMBA__c && !oldMap.get(cont.Id).Subscribe_EMBA__c)
       			   || (cont.Subscribe_MBA__c && !oldMap.get(cont.Id).Subscribe_MBA__c)
       			   || (cont.Subscribe_MFin__c && !oldMap.get(cont.Id).Subscribe_MFin__c)
       			   || (cont.Subscribe_OEP__c && !oldMap.get(cont.Id).Subscribe_OEP__c)
       			   || (cont.Subscribe_Online_Program__c && !oldMap.get(cont.Id).Subscribe_Online_Program__c))
       			   && (!oldMap.get(cont.Id).Opt_In__c || !oldMap.get(cont.Id).Marketable_Contact__c)) {
       			   	cont.Opt_In__c = true;
       			   	cont.Marketable_Contact__c = true;
       			}
       			//If(Subscribe OEP or Subscribe Online Program is uncheck) && (one of Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC is uncheck)
       			//if(Do not email is check)
                            //All Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC are unchecked
       			//Do not Contact is checked
       			if((cont.hed__Do_Not_Contact__c && !oldMap.get(cont.Id).hed__Do_Not_Contact__c)
                                   || (cont.Do_Not_Email__c && !oldMap.get(cont.Id).Do_Not_Email__c)
       				|| ((!cont.Subscribe_EMBA__c && oldMap.get(cont.Id).Subscribe_EMBA__c) && (!cont.Subscribe_MBA__c && oldMap.get(cont.Id).Subscribe_MBA__c) && (!cont.Subscribe_MFin__c && oldMap.get(cont.Id).Subscribe_MFin__c) && (!cont.Subscribe_CCC__c && oldMap.get(cont.Id).Subscribe_CCC__c))
       				|| (((!cont.Subscribe_OEP__c && oldMap.get(cont.Id).Subscribe_OEP__c) || (!cont.Subscribe_Online_Program__c && oldMap.get(cont.Id).Subscribe_Online_Program__c) ) && ((cont.Subscribe_CCC__c && !oldMap.get(cont.Id).Subscribe_CCC__c) || (cont.Subscribe_EMBA__c && !oldMap.get(cont.Id).Subscribe_EMBA__c) || (cont.Subscribe_MBA__c && !oldMap.get(cont.Id).Subscribe_MBA__c) || (cont.Subscribe_MFin__c && !oldMap.get(cont.Id).Subscribe_MFin__c)))
       				) {
       				cont.Opt_Out__c = true;
       			}

                            //marketable contact changed
                            if(cont.Marketable_Contact__c != oldMap.get(cont.Id).Marketable_Contact__c) {
                                   cont.Marketable_Contact_Modified_date__c = Date.today();
                            }

                            //Uncheck Opt-out when Opt-in check
                            if(cont.Opt_In__c && cont.Opt_In__c != oldMap.get(cont.Id).Opt_In__c) {
                                   cont.Opt_In_Date__c = Date.today();
                                   cont.Opt_Out__c = false;
                            }
                            //Uncheck Opt-in when Opt-out check
                            else if(cont.Opt_Out__c && cont.Opt_Out__c != oldMap.get(cont.Id).Opt_Out__c) {
                                   cont.Opt_out_Date__c = Date.today();
                                   cont.Opt_In__c = false;
                            }
       		}
       	}
       	return null;
       }
}