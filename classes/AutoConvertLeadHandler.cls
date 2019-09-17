/************************************************************************************
Class Name : AutoConvertLeadHandler
Version : 1.0 
Created Date : 07/10/2019
Function : Auto convert lead to Account, Contact, Opportunity

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/10/2019               Version 1.0
*************************************************************************************/
public without sharing class AutoConvertLeadHandler implements Triggers.Handler {
    public void handle() {
        List<Id> leadIdList = new List<Id>();
        Map<String, String> rtMap = InseadUtil.getObjectRecordType('Lead');
        if(Trigger.isBefore && Trigger.isInsert) {
            for(Lead ld : (List<Lead>) Trigger.new) {
                
                if(ld.LastName == null) ld.LastName = '<Individual>';
                if(ld.Company == null) {
                    ld.Company = ld.FirstName + ' ' + ld.LastName + ' ' + 'Administrative Account';
                }
                ld.Company_Temporary__c = ld.Company;
                if('Eloqua' == ld.Data_Source__c && 'OEP' == ld.Lead_Type__c) {
                    ld.RecordTypeId = ('Yes' == ld.Are_you_an_HR__c)? rtMap.get('OEP_Corporate_Lead') : rtMap.get('OEP_Individual_Lead');
                }
                
                if(ld.Program_Name__c != null && ld.Program_Name__c.containsIgnoreCase('ACG')) {
                    ld.ACG_Interest__c = true;
                }

                ld.Gender__c = 'F' == ld.Gender__c? 'Female' : ('M' == ld.Gender__c? 'Male' : ld.Gender__c);

                if('Eloqua' == ld.Data_Source__c) {
                    ld.Opt_In__c = (ld.Opt_In_text__c == null || 'N' == ld.Opt_In_text__c)? false : true;
                    ld.Opt_Out__c = (ld.Opt_out_text__c == null || 'N' == ld.Opt_out_text__c)? false : true;

                    ld.DoNotCall = (ld.Do_Not_Call_text__c == null || 'N' == ld.Do_Not_Call_text__c)? false : true;
                    ld.Do_Not_Contact__c = (ld.Do_Not_Contact_text__c == null || 'N' == ld.Do_Not_Contact_text__c)? false : true;
                    ld.Do_Not_Mail__c = (ld.Do_Not_Mail_text__c == null || 'N' == ld.Do_Not_Mail_text__c)? false : true;

                    ld.Subscribe_CCC__c = (ld.Subscribe_CCC_text__c == null || 'N' == ld.Subscribe_CCC_text__c)? false : true;
                    ld.Subscribe_EMBA__c = (ld.Subscribe_EMBA_text__c == null || 'N' == ld.Subscribe_EMBA_text__c)? false : true;
                    ld.Subscribe_EMC__c = (ld.Subscribe_EMC_text__c == null || 'N' == ld.Subscribe_EMC_text__c)? false : true;
                    ld.Subscribe_MBA__c = (ld.Subscribe_MBA_text__c == null || 'N' == ld.Subscribe_MBA_text__c)? false : true;
                    ld.Subscribe_MFin__c = (ld.Subscribe_MFin_text__c == null || 'N' == ld.Subscribe_MFin_text__c)? false : true;
                    ld.Subscribe_MiM__c = (ld.Subscribe_MIM_text__c == null || 'N' == ld.Subscribe_MIM_text__c)? false : true;
                    ld.Subscribe_OEP__c = (ld.Subscribe_OEP_text__c == null || 'N' == ld.Subscribe_OEP_text__c)? false : true;
                    ld.Subscribe_Online_Program__c = (ld.Subscribe_Online_Program_text__c == null || 'N' == ld.Subscribe_Online_Program_text__c)? false : true;

                    ld.Unsubscribe_CCC__c = (ld.Unsubscribe_CCC_text__c == null || 'N' == ld.Unsubscribe_CCC_text__c)? false : true;
                    ld.Unsubscribe_EMBA__c = (ld.Unsubscribe_EMBA_text__c == null || 'N' == ld.Unsubscribe_EMBA_text__c)? false : true;
                    ld.Unsubscribe_MBA__c = (ld.Unsubscribe_MBA_text__c == null || 'N' == ld.Unsubscribe_MBA_text__c)? false : true;
                    ld.Unsubscribe_MFin__c = (ld.Unsubscribe_MFin_text__c == null || 'N' == ld.Unsubscribe_MFin_text__c)? false : true;
                    ld.Unsubscribe_OEP__c = (ld.Unsubscribe_OEP_text__c == null || 'N' == ld.Unsubscribe_OEP_text__c)? false : true;

                    ld.CGM_Interest__c = (ld.CGM_Interest_text__c == null || 'N' == ld.CGM_Interest_text__c)? false : true;
                    ld.OOC_Interest__c = (ld.OOC_Interest_text__c == null || 'N' == ld.OOC_Interest_text__c)? false : true;

                }
                System.debug(LoggingLevel.INFO, '*** ld.Opt_In__c: ' + ld.Opt_In__c);
                if(ld.Opt_In__c) {
                    if(ld.Opt_In_Date__c == null) {
                        ld.Opt_In_Date__c = Date.today();
                    }
                    ld.Opt_Out__c = false;
                    System.debug(LoggingLevel.INFO, '*** ld.Opt_In_Date__c: ' + ld.Opt_In_Date__c);
                }else if(ld.Opt_Out__c) {
                    if(ld.Opt_out_Date__c == null) {
                          ld.Opt_out_Date__c = Date.today();
                    }
                    ld.Opt_In__c = false;
                }
            }
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            for(Lead ld : (List<Lead>) Trigger.new) {
                Map<Id, Lead> oldLeadMap = (Map<Id, Lead>)trigger.oldMap;
                Lead oldLead = oldLeadMap.get(ld.Id);

                if(ld.Program_Name__c != oldLead.Program_Name__c && ld.Program_Name__c.containsIgnoreCase('ACG')) {
                    ld.ACG_Interest__c = true;
                }
                
                if(ld.Opt_out_text__c != oldLead.Opt_out_text__c) {
                    ld.Opt_Out__c = (ld.Opt_out_text__c == null || 'N' == ld.Opt_out_text__c)? false : true;
                }
                if(ld.Do_Not_Contact_text__c != oldLead.Do_Not_Contact_text__c) {
                    ld.Do_Not_Contact__c = (ld.Do_Not_Contact_text__c == null || 'N' == ld.Do_Not_Contact_text__c)? false : true;
                }

                if(ld.Do_Not_Call_text__c != oldLead.Do_Not_Call_text__c) {
                    ld.DoNotCall = (ld.Do_Not_Call_text__c == null || 'N' == ld.Do_Not_Call_text__c)? false : true;
                }
                if(ld.Do_Not_Contact_text__c != oldLead.Do_Not_Contact_text__c) {
                    ld.Do_Not_Contact__c = (ld.Do_Not_Contact_text__c == null || 'N' == ld.Do_Not_Contact_text__c)? false : true;
                }
                if(ld.Do_Not_Mail_text__c != oldLead.Do_Not_Mail_text__c) {
                    ld.Do_Not_Mail__c = (ld.Do_Not_Mail_text__c == null || 'N' == ld.Do_Not_Mail_text__c)? false : true;
                }


                if(ld.Subscribe_CCC_text__c != oldLead.Subscribe_CCC_text__c) {
                    ld.Subscribe_CCC__c = (ld.Subscribe_CCC_text__c == null || 'N' == ld.Subscribe_CCC_text__c)? false : true;
                }
                if(ld.Subscribe_EMBA_text__c != oldLead.Subscribe_EMBA_text__c) {
                    ld.Subscribe_EMBA__c = (ld.Subscribe_EMBA_text__c == null || 'N' == ld.Subscribe_EMBA_text__c)? false : true;
                }
                if(ld.Subscribe_EMC_text__c != oldLead.Subscribe_EMC_text__c) {
                    ld.Subscribe_EMC__c = (ld.Subscribe_EMC_text__c == null || 'N' == ld.Subscribe_EMC_text__c)? false : true;
                }
                if(ld.Subscribe_MBA_text__c != oldLead.Subscribe_MBA_text__c) {
                    ld.Subscribe_MBA__c = (ld.Subscribe_MBA_text__c == null || 'N' == ld.Subscribe_MBA_text__c)? false : true;
                }
                if(ld.Subscribe_MFin_text__c != oldLead.Subscribe_MFin_text__c) {
                    ld.Subscribe_MFin__c = (ld.Subscribe_MFin_text__c == null || 'N' == ld.Subscribe_MFin_text__c)? false : true;
                }
                if(ld.Subscribe_MIM_text__c != oldLead.Subscribe_MIM_text__c) {
                    ld.Subscribe_MiM__c = (ld.Subscribe_MIM_text__c == null || 'N' == ld.Subscribe_MIM_text__c)? false : true;
                }
                if(ld.Subscribe_OEP_text__c != oldLead.Subscribe_OEP_text__c) {
                    ld.Subscribe_OEP__c = (ld.Subscribe_OEP_text__c == null || 'N' == ld.Subscribe_OEP_text__c)? false : true;
                }
                if(ld.Subscribe_Online_Program_text__c != oldLead.Subscribe_Online_Program_text__c) {
                    ld.Subscribe_Online_Program__c = (ld.Subscribe_Online_Program_text__c == null || 'N' == ld.Subscribe_Online_Program_text__c)? false : true;
                }

                if(ld.Unsubscribe_CCC_text__c != oldLead.Unsubscribe_CCC_text__c) {
                    ld.Unsubscribe_CCC__c = (ld.Unsubscribe_CCC_text__c == null || 'N' == ld.Unsubscribe_CCC_text__c)? false : true;
                }
                if(ld.Unsubscribe_EMBA_text__c != oldLead.Unsubscribe_EMBA_text__c) {
                    ld.Unsubscribe_EMBA__c = (ld.Unsubscribe_EMBA_text__c == null || 'N' == ld.Unsubscribe_EMBA_text__c)? false : true;
                }
                if(ld.Unsubscribe_MBA_text__c != oldLead.Unsubscribe_MBA_text__c) {
                    ld.Unsubscribe_MBA__c = (ld.Unsubscribe_MBA_text__c == null || 'N' == ld.Unsubscribe_MBA_text__c)? false : true;
                }
                if(ld.Unsubscribe_MFin_text__c != oldLead.Unsubscribe_MFin_text__c) {
                    ld.Unsubscribe_MFin__c = (ld.Unsubscribe_MFin_text__c == null || 'N' == ld.Unsubscribe_MFin_text__c)? false : true;
                }
                if(ld.Unsubscribe_OEP_text__c != oldLead.Unsubscribe_OEP_text__c) {
                    ld.Unsubscribe_OEP__c = (ld.Unsubscribe_OEP_text__c == null || 'N' == ld.Unsubscribe_OEP_text__c)? false : true;
                }
                if(ld.CGM_Interest_text__c != oldLead.CGM_Interest_text__c) {
                    ld.CGM_Interest__c = (ld.CGM_Interest_text__c == null || 'N' == ld.CGM_Interest_text__c)? false : true;
                }
                if(ld.OOC_Interest_text__c != oldLead.OOC_Interest_text__c) {
                    ld.OOC_Interest__c = (ld.OOC_Interest_text__c == null || 'N' == ld.OOC_Interest_text__c)? false : true;
                }
                if(ld.Gender__c != oldLead.Gender__c) {
                    ld.Gender__c = 'F' == ld.Gender__c? 'Female' : ('M' == ld.Gender__c? 'Male' : ld.Gender__c);
                }


                //if any of this field is checked, Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC, Subscribe Online Program, Subscribe OEP
                //then Opt-in field and check Marketable Contact field
                if(((ld.Subscribe_CCC__c && !oldLead.Subscribe_CCC__c)
                   || (ld.Subscribe_EMBA__c && !oldLead.Subscribe_EMBA__c)
                   || (ld.Subscribe_MBA__c && !oldLead.Subscribe_MBA__c)
                   || (ld.Subscribe_MFin__c && !oldLead.Subscribe_MFin__c)
                   || (ld.Subscribe_OEP__c && !oldLead.Subscribe_OEP__c)
                   || (ld.Subscribe_Online_Program__c && !oldLead.Subscribe_Online_Program__c))
                   && (!oldLead.Opt_In__c || !oldLead.Marketable_Contact__c)) {
                    ld.Opt_In__c = true;
                    ld.Marketable_Contact__c = true;
                }
                //If(Subscribe OEP or Subscribe Online Program is uncheck) && (one of Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC is uncheck)
                //if(Do not email is check)
                //All Subscribe MBA, Subscribe EMBA, Subscribe Mfin, Subscribe CCC are unchecked
                //Do not Contact is checked
                if((ld.Do_Not_Contact__c && !oldLead.Do_Not_Contact__c)
                    || (ld.Do_Not_Email__c && !oldLead.Do_Not_Email__c)
                    || ((!ld.Subscribe_EMBA__c && oldLead.Subscribe_EMBA__c) && (!ld.Subscribe_MBA__c && oldLead.Subscribe_MBA__c) && (!ld.Subscribe_MFin__c && oldLead.Subscribe_MFin__c) && (!ld.Subscribe_CCC__c && oldLead.Subscribe_CCC__c))
                    || (((!ld.Subscribe_OEP__c && oldLead.Subscribe_OEP__c) || (!ld.Subscribe_Online_Program__c && oldLead.Subscribe_Online_Program__c)) && ((ld.Subscribe_CCC__c && !oldLead.Subscribe_CCC__c) || (ld.Subscribe_EMBA__c && !oldLead.Subscribe_EMBA__c) || (ld.Subscribe_MBA__c && !oldLead.Subscribe_MBA__c) || (ld.Subscribe_MFin__c && !oldLead.Subscribe_MFin__c)))
                    ) {
                    ld.Opt_Out__c = true;
                }
                //marketable contact changed
                if(ld.Marketable_Contact__c != oldLead.Marketable_Contact__c) {
                    ld.Marketable_Contact_Modified_date__c = Date.today();
                }

                //Uncheck Opt-out when Opt-in check
                if(ld.Opt_In__c && ld.Opt_In__c != oldLead.Opt_In__c) {
                   ld.Opt_In_Date__c = Date.today();
                   ld.Opt_Out__c = false;
                }
                //Uncheck Opt-in when Opt-out check
                else if(ld.Opt_Out__c && ld.Opt_Out__c != oldLead.Opt_Out__c) {
                   ld.Opt_out_Date__c = Date.today();
                   ld.Opt_In__c = false;
                }
                
            }
            
        }
        // if(Trigger.isAfter && Trigger.isInsert) {
        //     for(Lead ld : (List<Lead>) Trigger.new) {
                
        //     }
        // }
        // if(Trigger.isAfter && Trigger.isUpdate) {
        //     for(Lead newLead : (List<Lead>) Trigger.new) {
        //         Lead oldLead = (Lead)Trigger.oldMap.get(newLead.Id);
        //     }
        // }
        // System.debug(LoggingLevel.INFO, '*** leadIdList: ' + leadIdList);
        // if(leadIdList.size() > 0) {
        //     AutoConvertLeads.autoConvert(leadIdList);
        // }
    }
}