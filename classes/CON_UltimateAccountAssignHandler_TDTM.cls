/******************************************************************
Class Name : CON_UltimateAccountAssignHandler_TDTM
Version : 1.0 
Created Date : 06/11/2019
Function : 1. when account parent account changed, current account and all child accounts the ultimate account need to assigned value
           2. when new ultimate account generated, and the old ultimate account parent account changed to new ultimate account, then update
              old ultimate account (is ultimate account = false) and all child ultimate parent account info of the old ultimate account
Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             07/04/2019               Version 1.0
********************************************************************/
global class CON_UltimateAccountAssignHandler_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        //get record type id : business organization account 
        ID typeId = GetRecordTypeId();
        System.debug(LoggingLevel.INFO, '*** typeId: ' + typeId);
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            System.debug(LoggingLevel.INFO, '*** 333: ' + 333);
            for(Account acct : (List<Account>)newlist) {
                System.debug(LoggingLevel.INFO, '*** acct.ParentId: ' + acct.ParentId);
                if(acct.RecordTypeId == typeId && acct.ParentId != null) {
                    System.debug(LoggingLevel.INFO, '*** 444: ' + 444);
                    setUpUltimateAccount(acct.Id);
                }
            }
        }
        
        if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            
            Map<Id, Account> oldAccountMap = new Map<Id, Account>();
            for(Account acct : (List<Account>)oldlist) {
                oldAccountMap.put(acct.Id, acct);
            }
            System.debug(LoggingLevel.INFO, '*** oldAccountMap: ' + oldAccountMap);
        
            for(Account acct : (List<Account>)newlist) {
                Account oldAcct = oldAccountMap.get(acct.Id);
                System.debug(LoggingLevel.INFO, '*** 111: ' + 111);
                System.debug(LoggingLevel.INFO, '*** acct.ParentId: ' + acct.ParentId);
                System.debug(LoggingLevel.INFO, '*** oldAcct.ParentId: ' + oldAcct.ParentId);
                if(acct.RecordTypeId == typeId && acct.ParentId != oldAcct.ParentId && (acct.ParentId != null  || acct.ParentId == null)) {
                    setUpUltimateAccount(acct.Id);
                }
            }
        }
        return null;
    }
    
    @future
    public static void setUpUltimateAccount(String currentAcctId) {
        System.debug(LoggingLevel.INFO, '*** currentAcctId: ' + currentAcctId);
        String topAcctId = GetUltimateAccountID(currentAcctId);
        System.debug(LoggingLevel.INFO, '*** topAcctId: ' + topAcctId);
        List<Account> clildAccounts = GetAllChildAccount(topAcctId);
        System.debug(LoggingLevel.INFO, '*** clildAccounts: ' + clildAccounts);
        List<Account> updatedAccounts = new List<Account>();

        for(Account acct : clildAccounts) {
            Account tmpAcct = new Account();
            tmpAcct.Id = acct.Id;
            tmpAcct.Ultimate_Parent_Account__c = topAcctId;
            updatedAccounts.add(tmpAcct);
        }
        update updatedAccounts;
        System.debug(LoggingLevel.INFO, '*** finish: ');
    }

    //get the ultimate account Id through account hierarchy
    public static String GetUltimateAccountID(String currentId) {
        Boolean isTopLevelAccount = false;
        while (!isTopLevelAccount) {
            Account acct = [select Id, ParentId From Account where Id =: currentId limit 1];
            if (acct.ParentId != null) {
                currentId = acct.ParentId;
            } else {
                isTopLevelAccount = true;
            }
        }
        return currentId;
    }
    
    //get all child account through account hierarchy
    public static List<Account> GetAllChildAccount (String currentId) {
        List<Account> childaccountlist = new List<Account>();
        //parent set
        Set<String> parentset = new Set<String>();
        parentset.add(currentId);
        Boolean endTraversing = false;

        while(!endTraversing) {
            //get child account
            List<Account> accountlist = [select Id,ParentId from Account where ParentId IN : parentset];
            Set<String> childset = new Set<String>();
            if(accountlist.size() > 0) {
                //clear old parent id
                parentset.clear();
                for(Account acct : accountlist) {
                    childaccountlist.add(acct);
                    //add new parent id
                    parentset.add(acct.Id);
                }
            } else {
                endTraversing=true;
            }
        }
        return childaccountlist;
    }
    
    //get record type id : business organization account 
    public static ID GetRecordTypeId () {
         ID recordtypeId = [SELECT Id FROM RecordType 
                                      WHERE DeveloperName = 'Business_Organization' AND SObjectType = 'Account' ].Id;
         return recordtypeId;
    }

    
}