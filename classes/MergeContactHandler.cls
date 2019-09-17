/************************************************************************************
Class Name : MergeContactHandler
Version : 1.0 
Created Date : 07/26/2019
Function : Auto merger duplicate contact when data source = Eloqua

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/26/2019               Version 1.0
*************************************************************************************/
global class MergeContactHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            //before insert
            Set<String> firstNameSet = new Set<String>();
            Set<String> lastNameSet = new Set<String>();
            Set<String> emailSet = new Set<String>();
            Set<String> workemailSet = new Set<String>();
            Set<String> homeemailSet = new Set<String>();
            for(Contact cont : (List<Contact>) newlist) {
                firstNameSet.add(cont.FirstName);
                lastnameSet.add(cont.LastName);
                emailSet.add(cont.Email);
                workemailSet.add(cont.hed__WorkEmail__c);
                homeemailSet.add(cont.Home_Email__c);
            }
            //query the duplicate contact record
            List<Contact> contlist = [SELECT Id,Name,AccountId,FirstName,LastName,Email,Home_Email__c,hed__WorkEmail__c FROM Contact 
                                                WHERE FirstName =: firstNameSet AND LastName =: lastnameSet 
                                                AND ((Email =: emailSet AND Email != null ) 
                                                OR (hed__WorkEmail__c =: workemailSet AND hed__WorkEmail__c != null) 
                                                OR (Home_Email__c =: homeemailSet AND Home_Email__c != null))];
            System.debug('duplicate contlist info: '+contlist);
            System.debug('duplicate contlist info size: '+contlist.size());

            if(contlist.size() != 0) {
                //if existed same contact record , then the new contact accountId equals to existed record accountId
                //match filter : lastname + firstname + any email
                for(Contact newcont : (List<Contact>) newlist) {
                    for(Contact existedcont : contlist) {
                        if(newcont.LastName == existedcont.LastName && newcont.FirstName == existedcont.FirstName) {
                            if(newcont.Email == existedcont.Email) {
                                newcont.AccountId = existedcont.AccountId;
                                break;
                            }
                            else if(newcont.hed__WorkEmail__c == existedcont.hed__WorkEmail__c) {
                                newcont.AccountId = existedcont.AccountId;
                                break;
                            }
                            else if(newcont.Home_Email__c == existedcont.Home_Email__c) {
                                newcont.AccountId = existedcont.AccountId;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            //after insert
            Set<String> firstNameSet1 = new Set<String>();
            Set<String> lastNameSet1 = new Set<String>();
            Set<String> emailSet1 = new Set<String>();
            Set<String> workemailSet1 = new Set<String>();
            Set<String> homeemailSet1 = new Set<String>();
            for(Contact cont : (List<Contact>) newlist) {
                firstNameSet1.add(cont.FirstName);
                lastnameSet1.add(cont.LastName);
                emailSet1.add(cont.Email);
                workemailSet1.add(cont.hed__WorkEmail__c);
                homeemailSet1.add(cont.Home_Email__c);
            }

            Schema.FieldSet contFieldSet = Schema.SObjectType.Contact.fieldSets.getMap().get('GDPR_Contact_Fields');
            String sqlquery = 'SELECT Id,AccountId, LastName, FirstName,CreatedDate';
            sqlquery += ' FROM Contact WHERE FirstName IN : firstNameSet1  AND LastName IN : lastnameSet1  AND ((Email IN : emailSet1  AND Email != null ) OR (hed__WorkEmail__c IN : workemailSet1 AND hed__WorkEmail__c != null) OR (Home_Email__c IN : homeemailSet1 AND Home_Email__c != null))';
            System.debug('Query SQL: '+ sqlquery);

            //query the duplicate contact record
            List<Contact> contlist = Database.query(sqlquery);
            System.debug('duplicate contlist info size: '+contlist.size());

            //key : firstname + lastname + accountId, value : List<Contact> 
            Map<String,List<Contact>> contMap = new Map<String,List<Contact>>();
            for(Contact cont : contlist) {
                String keys = cont.FirstName+cont.LastName+cont.AccountId;
                if(contMap.containsKey(keys)) {
                    contMap.get(keys).add(cont);
                }
                else {
                    contMap.put(keys,new List<Contact>{cont});
                }
            }

            // duplicate contact reocrd merge
            for(String keys : contMap.keySet()) {
                //greater than 1 record & less or equals to 3 records
                if(contMap.get(keys).size() > 1 && contMap.get(keys).size() <=3) {
                    Contact masterContact;
                    List<Contact> clist = contMap.get(keys);
                    //mastercontact : created date greatest  -- Bubbling cycle
                    for(Integer i=0; i < clist.size(); i++) {
                        for(Integer j=1; j < clist.size(); j++) {
                            if(clist[i].CreatedDate > clist[j].CreatedDate) {
                                masterContact = clist[i];
                                clist[i] = clist[j];
                                clist[j] = masterContact;
                            }
                        }
                    }
                    List<Contact> mergelist = new List<Contact>();
                    for(Integer i=0; i < clist.size()-1; i++ ) {
                        mergelist.add(clist[i]);
                    }
                    doMerge(JSON.serialize(clist[clist.size()-1]),JSON.serialize(mergelist));
                }
                // greater than 3 records
                else if(contMap.get(keys).size() > 3) {

                }
            } 
        }
        return null;
    }
        

    @future
    public static void doMerge(String contObj,String listObj) {
        Contact masterContact = (Contact)JSON.deserialize(contObj, Contact.class);
        System.debug(LoggingLevel.INFO, '*** masterContact: ' + masterContact);
        List<Contact> duplicateList = (List<Contact>)JSON.deserialize(listObj, List<Contact>.class);
        System.debug(LoggingLevel.INFO, '*** merge duplicateList: ' + duplicateList);

        Schema.FieldSet contFieldSet = Schema.SObjectType.Contact.fieldSets.getMap().get('GDPR_Contact_Fields');

        Set<ID> masterIdSet = new Set<ID>();
        masterIdSet.add(masterContact.Id);
        String sqlquery = 'SELECT Id';
        for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
            sqlquery += ','+setmember.getFieldPath();
        }
        sqlquery += ' FROM Contact WHERE Id IN : masterIdSet';
        System.debug('Query SQL: '+ sqlquery);
        List<Contact> mastercontlist = Database.query(sqlquery);

        Set<ID> contIdSet = new Set<ID>();
        for(Contact cont : duplicateList) {
            contIdSet.add(cont.Id);
        }

        String sqlquery1 = 'SELECT Id';
        for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
            sqlquery1 += ','+setmember.getFieldPath();
        }
        sqlquery1 += ' FROM Contact WHERE Id IN : contIdSet';
        System.debug('Query SQL: '+ sqlquery1);
        //query the duplicate contact record
        List<Contact> mergecontlist = Database.query(sqlquery1);

        //query affiliation info by contact id
        List<hed__Affiliation__c> affilist = [SELECT Id,hed__Contact__c FROM hed__Affiliation__c WHERE hed__Contact__c =: contIdSet];
        if(affilist.size() != 0) {
            for(hed__Affiliation__c affil : affilist) {
                affil.hed__Contact__c = mastercontlist[0].Id;
            }
            update affilist;
        }
        // if duplicate record equals to 1
        if(mergecontlist.size() == 1) {
            for(Contact cont : mergecontlist) {
                for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
                    if(mastercontlist[0].get(setmember.getFieldPath()) == null) {
                       mastercontlist[0].put(setmember.getFieldPath(),cont.get(setmember.getFieldPath()));
                    }
                    else if(mastercontlist[0].get(setmember.getFieldPath()) == false) {
                       mastercontlist[0].put(setmember.getFieldPath(),cont.get(setmember.getFieldPath()));
                    }
                }
            }
            Database.MergeResult[] results = Database.merge(mastercontlist[0], mergecontlist,true);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
        }
        // if duplicate record equals to 2
        else {
            mastercontlist[0].Verification_Status__c = 'Raised for Potential Duplicate';
            mastercontlist[0].Potential_Duplicate_Contact_1__c = mergecontlist[0].Id;
            mastercontlist[0].Potential_Duplicate_Contact_2__c = mergecontlist[1].Id;
            update mastercontlist;
        }
    }
}