public without sharing class RelationshipMapExt {
    
    public Account acct { get; set; }
    
    public String dataJson { get; set; }

    public String parentId { get; set; }

    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public RelationshipMapExt(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
        dataJson = buildOrgTreeInformation(this.acct.Id);
    }

    public RelationshipMapExt() {

    }

    @AuraEnabled
    public static String buildOrgTreeInformation(String recordId) {
        String dataJson = '{}';
        System.debug(LoggingLevel.INFO, '*** dataJson: ' + dataJson);
        Account acct = [Select Id, Name, ParentId From Account Where Id =: recordId];
        // System.debug(LoggingLevel.INFO, '*** acct.ParentId: ' + acct.ParentId);
        // parentId = Account acct.ParentId == null? recordId : Account acct.ParentId;
        String parentId = String.isBlank(acct.ParentId)? null : acct.ParentId;
        System.debug(LoggingLevel.INFO, '*** 111: ' + parentId);
        if(!String.isBlank(parentId)) {
            System.debug(LoggingLevel.INFO, '*** parentId: ' + parentId);

            Account parentAcc = findRelateInformation(parentId);
            String grandpaId = String.isBlank(parentAcc.ParentId)? null : parentAcc.ParentId;
            System.debug(LoggingLevel.INFO, '*** grandpaId: ' + grandpaId);
            if(!String.isBlank(grandpaId)) {
                Account grandpaAcc = findRelateInformation(grandpaId);
                ParentObject parentObj = setupParentAccountHierarchy(parentAcc, recordId, true);
                GrandpaObject grandpaObj = new GrandpaObject();
                grandpaObj.name = grandpaAcc.name;
                // grandpaObj.title = grandpaAcc.Type;
                grandpaObj.title = '';
                grandpaObj.type = 'Account';
                grandpaObj.nodeId = grandpaAcc.Id;
                grandpaObj.className = 'node';
                grandpaObj.isActive = grandpaAcc.Is_Active__c? 'Y' : 'N';
                List<ParentObject> parentObjList = new List<ParentObject>();
                parentObjList.add(parentObj);
                for(hed__Affiliation__c affi : grandpaAcc.hed__Affl_Contacts__r) {
                    ParentObject o = new ParentObject();
                    o.name = affi.hed__Contact__r.Name;
                    o.title = affi.Contact_Role__c;
                    o.type = 'Contact';
                    o.nodeId = affi.hed__Contact__r.Id;
                    o.className = 'middle-level';
                    o.isActive = 'N';
                    parentObjList.add(o);
                }

                grandpaObj.children = parentObjList;
                dataJson = System.JSON.serialize(grandpaObj);
            }else {
                ParentObject obj = setupParentAccountHierarchy(parentAcc, recordId, false);
                dataJson = System.JSON.serialize(obj);
            }
            
        }else {
            dataJson = System.JSON.serialize(setupCurrentAccountHierarchy(recordId));
        }
        System.debug(LoggingLevel.INFO, '*** dataJson: ' + dataJson);
        return dataJson;
    }

    public static ParentObject setupParentAccountHierarchy(Account parentAcc, String currentAccId, Boolean hasParent) {
        System.debug(LoggingLevel.INFO, '*** hasParent: ' + hasParent);
        Relationship currentAccHierarchy = setupCurrentAccountHierarchy(currentAccId);
        List<Relationship> relationshipList = new List<Relationship>();
        relationshipList.add(currentAccHierarchy);
        ParentObject obj = new ParentObject();
        obj.name = parentAcc.name;
        // obj.title = parentAcc.Type;
        obj.title = '';
        obj.type = 'Account';
        obj.nodeId = parentAcc.Id;
        obj.className = 'node';
        obj.isActive = parentAcc.Is_Active__c? 'Y' : 'N';
        // if(hasParent) {
            Set<String> secLevelAccIdSet = new Set<String>();
            for(Account theAcc : parentAcc.ChildAccounts) {
                if(theAcc.Id == currentAccId) continue;
                secLevelAccIdSet.add(theAcc.Id);
            }
            List<Account> secLevelAccountList = findRelateInformationByIds(secLevelAccIdSet);
            Map<String, Account> secLevelAccountMap = new Map<String, Account>();
            for(Account acc : secLevelAccountList) {
                secLevelAccountMap.put(acc.Id, acc);
            }

            for(Account theAcc : parentAcc.ChildAccounts) {
                if(theAcc.Id == currentAccId) continue;
                Relationship r = new Relationship();
                List<Relationship.Children_X> childrenXList = new List<Relationship.Children_X>();
                r.name = theAcc.name;
                // r.title = theAcc.Type;
                r.title = '';
                r.type = 'Account';
                r.nodeId = theAcc.Id;
                r.className = 'node';
                r.isActive = theAcc.Is_Active__c? 'Y' : 'N';
                if(secLevelAccountMap.containsKey(theAcc.Id)) {
                    for(hed__Affiliation__c affi : secLevelAccountMap.get(theAcc.Id).hed__Affl_Contacts__r) {
                        Relationship.Children_X childrenX = setupChildren_X(affi.hed__Contact__r.Id, affi.hed__Contact__r.Name, affi.Contact_Role__c, 'Contact', 'N');
                        childrenXList.add(childrenX);
                    }
                }
                r.children = childrenXList;
                relationshipList.add(r);
            }
        // }
        for(hed__Affiliation__c affi : parentAcc.hed__Affl_Contacts__r) {
            Relationship r = new Relationship();
            r.name = affi.hed__Contact__r.Name;
            r.title = affi.Contact_Role__c;
            r.type = 'Contact';
            r.nodeId = affi.hed__Contact__r.Id;
            r.className = 'middle-level';
            r.isActive = 'N';
            relationshipList.add(r);
        }
        obj.children = relationshipList;
        return obj;
    }

    public static Relationship setupCurrentAccountHierarchy(String queryAccId) {
        // String json = '';
        Account selectedAccount = findRelateInformation(queryAccId);
        List<Relationship.Children_X> childrenXList = new List<Relationship.Children_X>();
        Relationship ship = setupNode(selectedAccount);
        for(hed__Affiliation__c affi : selectedAccount.hed__Affl_Contacts__r) {
            Relationship.Children_X childrenX = setupChildren_X(affi.hed__Contact__r.Id, affi.hed__Contact__r.Name, affi.Contact_Role__c, 'Contact', 'N');
            childrenXList.add(childrenX);
        }
        ship.children = childrenXList;
        Set<String> firstLevelAccIdSet = new Set<String>();
        for(Account acc : selectedAccount.ChildAccounts) {
            if(acc.Id == queryAccId) continue;
            firstLevelAccIdSet.add(acc.Id);
        }
        List<Account> secLevelAccountList = findRelateInformationByIds(firstLevelAccIdSet);
        Map<String, Account> secLevelAccountMap = new Map<String, Account>();
        Set<String> secLevelAccIdSet = new Set<String>();
        for(Account acc : secLevelAccountList) {
            secLevelAccountMap.put(acc.Id, acc);
            secLevelAccIdSet.add(acc.Id);
        }
        Map<String, Relationship.Children_X> secLevelNodeMap = new Map<String, Relationship.Children_X>();
        for(Account acc : selectedAccount.ChildAccounts) {
            String isActive = acc.Is_Active__c? 'Y' : 'N';
            Relationship.Children_X childrenX = setupChildren_X(acc.Id, acc.Name, acc.Type, 'Account', isActive);
            if(secLevelAccountMap.containsKey(acc.Id)) {
                List<Relationship.Children_Y> childrenYList = new List<Relationship.Children_Y>();
                for(hed__Affiliation__c affi : secLevelAccountMap.get(acc.Id).hed__Affl_Contacts__r) {
                    Relationship.Children_Y childrenY = setupChildren_Y(affi.hed__Contact__r.Id, affi.hed__Contact__r.Name, affi.Contact_Role__c, 'Contact', 'N');
                    childrenYList.add(childrenY);
                }
                childrenX.children = childrenYList;
            }
            secLevelNodeMap.put(acc.Id, childrenX);
            childrenXList.add(childrenX);
        }


        // List<Relationship.Children_X> thirdChildrenXList = new List<Relationship.Children_X>();
        System.debug(LoggingLevel.INFO, '*** secLevelAccIdSet: ' + secLevelAccIdSet);
        List<Account> thirdLevelAccountList = findRelateInformationByIds(secLevelAccIdSet);
        Map<String, Account> thirdLevelAccountMap = new Map<String, Account>();
        Set<String> thirdLevelAccIdSet = new Set<String>();
        for(Account theAcc : thirdLevelAccountList) {
            for(Account acc : theAcc.ChildAccounts) {
                thirdLevelAccIdSet.add(acc.Id);
            }
        }
        System.debug(LoggingLevel.INFO, '*** thirdLevelAccIdSet: ' + thirdLevelAccIdSet);
        Map<String, List<hed__Affiliation__c>> affiMap = findAffiliationsByAccountIds(thirdLevelAccIdSet);
        for(Account theAcc : thirdLevelAccountList) {
            System.debug(LoggingLevel.INFO, '*** theAcc.ChildAccounts: ' + theAcc.ChildAccounts);
            for(Account acc : theAcc.ChildAccounts) {
                // Relationship.Children_Y childrenY = new Relationship.Children_Y();
                // childrenY.nodeId = acc.Id;
                // childrenY.name = acc.Name;
                // childrenY.title = acc.Type;
                // childrenY.type = 'Account';
                // childrenY.className = 'node';
                String isActive = acc.Is_Active__c? 'Y' : 'N';
                Relationship.Children_Y childrenY = setupChildren_Y(acc.Id, acc.Name, acc.Type, 'Account', isActive);
                if(affiMap.containsKey(acc.Id)) {
                    List<Relationship.Children> childrenList = new List<Relationship.Children>();
                    for(hed__Affiliation__c affi : affiMap.get(acc.Id)) {
                        Relationship.Children children = new Relationship.Children();
                        children.nodeId = affi.hed__Contact__r.Id;
                        children.name = affi.hed__Contact__r.Name;
                        children.title = affi.Contact_Role__c;
                        children.type = 'Contact';
                        children.className = 'middle-level';
                        children.isActive = 'N';
                        childrenList.add(children);
                    }
                    childrenY.children = childrenList;
                }
                if(secLevelNodeMap.containsKey(theAcc.Id)) {
                    System.debug(LoggingLevel.INFO, '*** theAcc.Id: ' + theAcc.Id);
                    secLevelNodeMap.get(theAcc.Id).children.add(childrenY);
                }
            }
        }
        return ship;
    }

    public static Relationship setupNode(Account selectedAccount) {
        Relationship root = new Relationship();
        root.nodeId = selectedAccount.Id;
        root.name = selectedAccount.Name;
        // root.title = selectedAccount.Type;
        root.title = '';
        root.type = 'Account';
        root.isActive = selectedAccount.Is_Active__c? 'Y' : 'N';
        return root;
    }

    public static Relationship.Children_X setupChildren_X(String nodeId, String name, String title, String type, String isActive) {
        Relationship.Children_X childrenX = new Relationship.Children_X();
        childrenX.nodeId = nodeId;
        childrenX.name = name;
        childrenX.title = type == 'Account'? '' : title;
        childrenX.type = type;
        childrenX.isActive = isActive;
        childrenX.className = type == 'Account'? 'node' : 'middle-level';

        return childrenX;
    }

    public static Relationship.Children_Y setupChildren_Y(String nodeId, String name, String title, String type, String isActive) {
        Relationship.Children_Y childrenY = new Relationship.Children_Y();
        childrenY.nodeId = nodeId;
        childrenY.name = name;
        // childrenY.title = title;
        childrenY.title = type == 'Account'? '' : title;
        childrenY.type = type;
        childrenY.className = type == 'Account'? 'node' : 'middle-level';
        childrenY.isActive = isActive;
        return childrenY;
    }

    public static Account findRelateInformation(String parentAccId) {
        Account selectedAccount = [Select Id, Name, Type, ParentId, Is_Active__c, 
        (Select Id, hed__Contact__r.Name, Contact_Role__c, hed__Account__c From hed__Affl_Contacts__r),
        (Select Id, Name, Type, Is_Active__c From ChildAccounts)
        From Account Where Id =: parentAccId];
        return selectedAccount;
    }


    public static List<Account> findRelateInformationByIds(Set<String> accIdSet) {
        List<Account> accountList = [Select Id, Name, Type, ParentId, Is_Active__c, 
        (Select Id, hed__Contact__r.Name, Contact_Role__c, hed__Account__c From hed__Affl_Contacts__r),
        (Select Id, Name, Type, Is_Active__c From ChildAccounts)
        From Account Where Id =: accIdSet];
        return accountList;
    }

    // public Map<String, List<hed__Affiliation__c>> prepareAffiMap(Account acc) {
    //     Map<String, List<hed__Affiliation__c>> affiMap = new Map<String, List<hed__Affiliation__c>>();
    //     for(hed__Affiliation__c affi : acc.hed__Affl_Contacts__r) {
    //         if(affiMap.containsKey(affi.hed__Account__c)) {
    //             affiMap.get(affi.hed__Account__c).add(affi);
    //         }else {
    //             List<hed__Affiliation__c> affiList = new List<hed__Affiliation__c>{affi};
    //             affiMap.put(affi.hed__Account__c, affiList);
    //         }
    //     }
    //     return affiMap;
    // }

    public static Map<String, List<hed__Affiliation__c>> findAffiliationsByAccountIds(Set<String> accIdSet) {
        Map<String, List<hed__Affiliation__c>> affiMap = new Map<String, List<hed__Affiliation__c>>();
        for(hed__Affiliation__c affi : [Select Id, hed__Account__c, 
                                            hed__Contact__r.Name, 
                                            Contact_Role__c 
                                            From hed__Affiliation__c 
                                            Where hed__Account__c In: accIdSet]) {
            
            if(affiMap.containsKey(affi.hed__Account__c)) {
                affiMap.get(affi.hed__Account__c).add(affi);
            }else {
                List<hed__Affiliation__c> affiList = new List<hed__Affiliation__c>{affi};
                affiMap.put(affi.hed__Account__c, affiList);
            }
        }
        return affiMap;
    }
}