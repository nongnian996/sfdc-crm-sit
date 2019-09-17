global class CON_FieldTransformationHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
       System.debug('Running CON_FieldTransformationHandler_TDTM....');
       
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            for(Contact cont : (list<Contact>)newlist) {
                if(cont.Program_Name__c != null && cont.Program_Name__c.containsIgnoreCase('ACG')) {
                    cont.ACG_Interest_Adv_Certificate_in_Gov__c = true;
                }
                cont.hed__Gender__c = 'F' == cont.hed__Gender__c? 'Female' : ('M' == cont.hed__Gender__c? 'Male' : cont.hed__Gender__c);
                if('Eloqua' == cont.Data_Source__c) {
                    cont.Opt_In__c = (cont.Opt_In_text__c == null || 'N' == cont.Opt_In_text__c)? false : true;
                    cont.Opt_Out__c = (cont.Opt_out_text__c == null || 'N' == cont.Opt_out_text__c)? false : true;

                    cont.DoNotCall = (cont.Do_Not_Call_text__c == null || 'N' == cont.Do_Not_Call_text__c)? false : true;
                    cont.hed__Do_Not_Contact__c = (cont.Do_Not_Contact_text__c == null || 'N' == cont.Do_Not_Contact_text__c)? false : true;
                    cont.Do_Not_Mail__c = (cont.Do_Not_Mail_text__c == null || 'N' == cont.Do_Not_Mail_text__c)? false : true;

                    cont.Subscribe_CCC__c = (cont.Subscribe_CCC_text__c == null || 'N' == cont.Subscribe_CCC_text__c)? false : true;
                    cont.Subscribe_EMBA__c = (cont.Subscribe_EMBA_text__c == null || 'N' == cont.Subscribe_EMBA_text__c)? false : true;
                    cont.Subscribe_EMC__c = (cont.Subscribe_EMC_text__c == null || 'N' == cont.Subscribe_EMC_text__c)? false : true;
                    cont.Subscribe_MBA__c = (cont.Subscribe_MBA_text__c == null || 'N' == cont.Subscribe_MBA_text__c)? false : true;
                    cont.Subscribe_MFin__c = (cont.Subscribe_MFin_text__c == null || 'N' == cont.Subscribe_MFin_text__c)? false : true;
                    cont.Subscribe_MiM__c = (cont.Subscribe_MIM_text__c == null || 'N' == cont.Subscribe_MIM_text__c)? false : true;
                    cont.Subscribe_OEP__c = (cont.Subscribe_OEP_text__c == null || 'N' == cont.Subscribe_OEP_text__c)? false : true;
                    cont.Subscribe_Online_Program__c = (cont.Subscribe_Online_Program_text__c == null || 'N' == cont.Subscribe_Online_Program_text__c)? false : true;


                    cont.Unsubscribe_CCC__c = (cont.Unsubscribe_CCC_text__c == null || 'N' == cont.Unsubscribe_CCC_text__c)? false : true;
                    cont.Unsubscribe_EMBA__c = (cont.Unsubscribe_EMBA_text__c == null || 'N' == cont.Unsubscribe_EMBA_text__c)? false : true;
                    cont.Unsubscribe_MBA__c = (cont.Unsubscribe_MBA_text__c == null || 'N' == cont.Unsubscribe_MBA_text__c)? false : true;
                    cont.Unsubscribe_MFin__c = (cont.Unsubscribe_MFin_text__c == null || 'N' == cont.Unsubscribe_MFin_text__c)? false : true;
                    cont.Unsubscribe_OEP__c = (cont.Unsubscribe_OEP_text__c == null || 'N' == cont.Unsubscribe_OEP_text__c)? false : true;
                    cont.CGM_Interest__c = (cont.CGM_Interest_text__c == null || 'N' == cont.CGM_Interest_text__c)? false : true;
                    cont.OOC_Interest__c = (cont.OOC_Interest_text__c == null || 'N' == cont.OOC_Interest_text__c)? false : true;
                }
            }
        }
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            Map<Id, Contact> oldContMap = new Map<Id, Contact>();
            for(Contact cont : (list<Contact>)oldlist) {
                oldContMap.put(cont.Id, cont);
            }
            for(Contact cont : (list<Contact>)newlist) {
                Contact oldCont = oldContMap.get(cont.Id);

                if(cont.Program_Name__c != oldCont.Program_Name__c && cont.Program_Name__c.containsIgnoreCase('ACG')) {
                    cont.ACG_Interest_Adv_Certificate_in_Gov__c = true;
                }
                
                if(cont.Opt_out_text__c != oldCont.Opt_out_text__c) {
                    cont.Opt_Out__c = (cont.Opt_out_text__c == null || 'N' == cont.Opt_out_text__c)? false : true;
                }
                if(cont.Opt_In_text__c != oldCont.Opt_In_text__c) {
                    cont.Opt_In__c = (cont.Opt_In_text__c == null || 'N' == cont.Opt_In_text__c)? false : true;
                }

                System.debug(LoggingLevel.INFO, '*** cont.Do_Not_Call_text__c: ' + cont.Do_Not_Call_text__c);
                System.debug(LoggingLevel.INFO, '*** oldCont.Do_Not_Call_text__c: ' + oldCont.Do_Not_Call_text__c);
                if(cont.Do_Not_Call_text__c != oldCont.Do_Not_Call_text__c) {
                    cont.DoNotCall = (cont.Do_Not_Call_text__c == null || 'N' == cont.Do_Not_Call_text__c)? false : true;
                }
                if(cont.Do_Not_Contact_text__c != oldCont.Do_Not_Contact_text__c) {
                    cont.hed__Do_Not_Contact__c = (cont.Do_Not_Contact_text__c == null || 'N' == cont.Do_Not_Contact_text__c)? false : true;
                }
                if(cont.Do_Not_Call_text__c != oldCont.Do_Not_Call_text__c) {
                    cont.Do_Not_Mail__c = (cont.Do_Not_Mail_text__c == null || 'N' == cont.Do_Not_Mail_text__c)? false : true;
                }

                if(cont.Subscribe_CCC_text__c != oldCont.Subscribe_CCC_text__c) {
                    cont.Subscribe_CCC__c = (cont.Subscribe_CCC_text__c == null || 'N' == cont.Subscribe_CCC_text__c)? false : true;
                }
                if(cont.Subscribe_EMBA_text__c != oldCont.Subscribe_EMBA_text__c) {
                    cont.Subscribe_EMBA__c = (cont.Subscribe_EMBA_text__c == null || 'N' == cont.Subscribe_EMBA_text__c)? false : true;
                }
                if(cont.Subscribe_EMC_text__c != oldCont.Subscribe_EMC_text__c) {
                    cont.Subscribe_EMC__c = (cont.Subscribe_EMC_text__c == null || 'N' == cont.Subscribe_EMC_text__c)? false : true;
                }
                if(cont.Subscribe_MBA_text__c != oldCont.Subscribe_MBA_text__c) {
                    cont.Subscribe_MBA__c = (cont.Subscribe_MBA_text__c == null || 'N' == cont.Subscribe_MBA_text__c)? false : true;
                }
                if(cont.Subscribe_MFin_text__c != oldCont.Subscribe_MFin_text__c) {
                    cont.Subscribe_MFin__c = (cont.Subscribe_MFin_text__c == null || 'N' == cont.Subscribe_MFin_text__c)? false : true;
                }
                if(cont.Subscribe_MIM_text__c != oldCont.Subscribe_MIM_text__c) {
                    cont.Subscribe_MiM__c = (cont.Subscribe_MIM_text__c == null || 'N' == cont.Subscribe_MIM_text__c)? false : true;
                }
                if(cont.Subscribe_OEP_text__c != oldCont.Subscribe_OEP_text__c) {
                    cont.Subscribe_OEP__c = (cont.Subscribe_OEP_text__c == null || 'N' == cont.Subscribe_OEP_text__c)? false : true;
                }

                if(cont.Subscribe_Online_Program_text__c != oldCont.Subscribe_Online_Program_text__c) {
                    cont.Subscribe_Online_Program__c = (cont.Subscribe_Online_Program_text__c == null || 'N' == cont.Subscribe_Online_Program_text__c)? false : true;
                }
                

                if(cont.Unsubscribe_CCC_text__c != oldCont.Unsubscribe_CCC_text__c) {
                    cont.Unsubscribe_CCC__c = (cont.Unsubscribe_CCC_text__c == null || 'N' == cont.Unsubscribe_CCC_text__c)? false : true;
                }
                if(cont.Unsubscribe_EMBA_text__c != oldCont.Unsubscribe_EMBA_text__c) {
                    cont.Unsubscribe_EMBA__c = (cont.Unsubscribe_EMBA_text__c == null || 'N' == cont.Unsubscribe_EMBA_text__c)? false : true;
                }
                if(cont.Unsubscribe_MBA_text__c != oldCont.Unsubscribe_MBA_text__c) {
                    cont.Unsubscribe_MBA__c = (cont.Unsubscribe_MBA_text__c == null || 'N' == cont.Unsubscribe_MBA_text__c)? false : true;
                }
                if(cont.Unsubscribe_MFin_text__c != oldCont.Unsubscribe_MFin_text__c) {
                    cont.Unsubscribe_MFin__c = (cont.Unsubscribe_MFin_text__c == null || 'N' == cont.Unsubscribe_MFin_text__c)? false : true;
                }
                if(cont.Unsubscribe_OEP_text__c != oldCont.Unsubscribe_OEP_text__c) {
                    cont.Unsubscribe_OEP__c = (cont.Unsubscribe_OEP_text__c == null || 'N' == cont.Unsubscribe_OEP_text__c)? false : true;
                }
                if(cont.CGM_Interest_text__c != oldCont.CGM_Interest_text__c) {
                    cont.CGM_Interest__c = (cont.CGM_Interest_text__c == null || 'N' == cont.CGM_Interest_text__c)? false : true;
                }
                if(cont.OOC_Interest_text__c != oldCont.OOC_Interest_text__c) {
                    cont.OOC_Interest__c = (cont.OOC_Interest_text__c == null || 'N' == cont.OOC_Interest_text__c)? false : true;
                }
                if(cont.hed__Gender__c != cont.hed__Gender__c) {
                    cont.hed__Gender__c = 'F' == cont.hed__Gender__c? 'Female' : ('M' == cont.hed__Gender__c? 'Male' : cont.hed__Gender__c);
                }
            }
        }
        return null;
    }
}