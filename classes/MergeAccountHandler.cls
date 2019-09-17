/************************************************************************************
Class Name : MergeAccountHandler
Version : 1.0 
Created Date : 08/01/2019
Function : Auto merger duplicate Account when data source = Eloqua

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                   08/01/2019               Version 1.0
*************************************************************************************/
global class MergeAccountHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            Set<String> nameSet = new Set<String>();
            Set<String> countrySet = new Set<String>();
            for(Account acct : (List<Account>)newlist) {
                nameSet.add(acct.Name);
                countrySet.add(acct.BillingCountry);
            }
            //query account list info
            List<Account> accountlist = [SELECT Id,Name,BillingCountry,CreatedDate FROM Account WHERE Name =: nameSet AND BillingCountry =: countrySet AND BillingCountry != null];
            System.debug('accountlist info: '+accountlist);

            if(accountlist.size() != 0) {
                Map<String,List<Account>> accountMap = new Map<String,List<Account>>();
                for(Account acct : accountlist) {
                    if(accountMap.containsKey(acct.Name+acct.BillingCountry)) {
                        accountMap.get(acct.Name+acct.BillingCountry).add(acct);
                    }
                    else {
                        accountMap.put(acct.Name+acct.BillingCountry,new List<Account>{acct});
                    }
                }

                // duplicate account reocrd merge
                for(String keys : accountMap.keySet()) {
                    System.debug('Merge Account&&&');
                    //greater than 1 record & less or equals to 3 records
                    if(accountMap.get(keys).size() > 1 && accountMap.get(keys).size() <=3) {
                        Account masterAccount;
                        List<Account> clist = accountMap.get(keys);
                        //masterAccount : created date greatest  -- Bubbling cycle
                        for(Integer i=0; i < clist.size(); i++) {
                            for(Integer j=1; j < clist.size(); j++) {
                                if(clist[i].CreatedDate > clist[j].CreatedDate) {
                                    masterAccount = clist[i];
                                    clist[i] = clist[j];
                                    clist[j] = masterAccount;
                                }
                            }
                        }
                        List<Account> mergelist = new List<Account>();
                        for(Integer i=0; i < clist.size()-1; i++ ) {
                            mergelist.add(clist[i]);
                        }
                        System.debug('111111111111111111111111');
                        doMerge(JSON.serialize(clist[clist.size()-1]),JSON.serialize(mergelist));
                    }
                    // greater than 3 records
                    else if(accountMap.get(keys).size() > 3) {

                    }
                } 
            }
        }
        return null;
    }

    @future
    public static void doMerge(String acctObj,String listObj) {
        Account masterAccount = (Account)JSON.deserialize(acctObj, Account.class);
        System.debug(LoggingLevel.INFO, '*** masterAccount: ' + masterAccount);
        List<Account> duplicateList = (List<Account>)JSON.deserialize(listObj, List<Account>.class);
        System.debug(LoggingLevel.INFO, '*** merge duplicateList: ' + duplicateList);

        Schema.FieldSet contFieldSet = Schema.SObjectType.Account.fieldSets.getMap().get('Duplicate_Merge');

        Set<ID> masterIdSet = new Set<ID>();
        masterIdSet.add(masterAccount.Id);
        String sqlquery = 'SELECT Id';
        for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
            sqlquery += ','+setmember.getFieldPath();
        }
        sqlquery += ' FROM Account WHERE Id IN : masterIdSet';
        System.debug('Query SQL: '+ sqlquery);
        List<Account> masteracctlist = Database.query(sqlquery);

        Set<ID> contIdSet = new Set<ID>();
        for(Account cont : duplicateList) {
            contIdSet.add(cont.Id);
        }
        String sqlquery1 = 'SELECT Id';
        for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
            sqlquery1 += ','+setmember.getFieldPath();
        }
        sqlquery1 += ',(SELECT Id,hed__Account__c FROM hed__Affl_Contacts__r),(SELECT Id,Account__c FROM Account_Plans__r) FROM Account WHERE Id IN : contIdSet';
        System.debug('Query SQL: '+ sqlquery1);
        //query the duplicate Account record
        List<Account> mergecontlist = Database.query(sqlquery1);
        
        // if duplicate record equals to 1
        if(mergecontlist.size() ==1) {
            for(Schema.FieldSetMember setmember : contFieldSet.getFields()) {
                if(masteracctlist[0].get(setmember.getFieldPath()) == null) {
                   masteracctlist[0].put(setmember.getFieldPath(),mergecontlist[0].get(setmember.getFieldPath()));
                }
                else if(masteracctlist[0].get(setmember.getFieldPath()) == false) {
                   masteracctlist[0].put(setmember.getFieldPath(),mergecontlist[0].get(setmember.getFieldPath()));
                }
            }
            if(mergecontlist[0].hed__Affl_Contacts__r.size() != 0) {
                List<hed__Affiliation__c> contlist = new List<hed__Affiliation__c>(); 
                for(hed__Affiliation__c cont : mergecontlist[0].hed__Affl_Contacts__r) {
                    cont.hed__Account__c = masteracctlist[0].Id;
                    contlist.add(cont);
                }
                update contlist;
            }

            if(mergecontlist[0].Account_Plans__r.size() != 0) {
                List<Account_Plan__c> contlist = new List<Account_Plan__c>(); 
                for(Account_Plan__c cont : mergecontlist[0].Account_Plans__r) {
                    cont.Account__c = masteracctlist[0].Id;
                    contlist.add(cont);
                }
                update contlist;
            }

            Database.MergeResult[] results = Database.merge(masteracctlist[0], mergecontlist,true);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
        }
        // if duplicate record equals to 2
        else {
            masteracctlist[0].Verification_Status__c = 'Raised for Potential Duplicate';
            masteracctlist[0].Potential_Duplicate_Account_1__c = mergecontlist[0].Id;
            masteracctlist[0].Potential_Duplicate_Account_2__c = mergecontlist[1].Id;
            update masteracctlist;
        }
    }
}