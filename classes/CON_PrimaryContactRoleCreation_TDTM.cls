/************************************************************************************
Class Name : CON_PrimaryContactRoleCreation_TDTM
Version : 1.0 
Created Date : 09/04/2019
Function : 1, create a primary contact role for opportunity when there is a primary contact populate
        2, auto create team member if account owner is not the same as opportunity owner.
Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                09/04/2019               Version 1.0
*************************************************************************************/

global class CON_PrimaryContactRoleCreation_TDTM extends hed.TDTM_Runnable {
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        System.debug('Running CON_PrimaryContactRoleCreation_TDTM....');
        
        Set<String> accountIdSet = new Set<String>();
        Map<String, String> accountOwnerMap = new Map<String, String>();

        Set<String> contIdSet = new Set<String>();
        Set<String> oldContIdSet = new Set<String>();
        Set<String> opptyIdSet = new Set<String>();
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            System.debug('CON_PrimaryContactRoleCreation_TDTM Context: AfterDelete');
            for(Opportunity oppty : (List<Opportunity>)newlist) {
                accountIdSet.add(oppty.AccountId);
                if(oppty.Primary_Contact__c != null) {
                    contIdSet.add(oppty.Primary_Contact__c);
                    opptyIdSet.add(oppty.Id);
                }
            }
            
        }
        if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            System.debug('CON_PrimaryContactRoleCreation_TDTM Context: AfterDelete');
            Map<Id, Opportunity> oldOpptyMap = new Map<Id, Opportunity>();
            for(Opportunity oppty : (List<Opportunity>)oldList) {
                oldOpptyMap.put(oppty.Id, oppty);
            }
            for(Opportunity oppty : (List<Opportunity>)newList) {
                Opportunity oldOppty = oldOpptyMap.get(oppty.Id);
                if(oppty.OwnerId != oldOppty.OwnerId) {
                    accountIdSet.add(oppty.AccountId);
                }

                opptyIdSet.add(oppty.Id);
                System.debug(LoggingLevel.INFO, '*** oppty.Primary_Contact__c: ' + oppty.Primary_Contact__c);
                System.debug(LoggingLevel.INFO, '*** oldOppty.Primary_Contact__c: ' + oldOppty.Primary_Contact__c);
                if(oppty.Primary_Contact__c == null && oldOppty.Primary_Contact__c != null) {
                    oldContIdSet.add(oldOppty.Primary_Contact__c);
                }
                if(oppty.Primary_Contact__c == null || oppty.Primary_Contact__c == oldOppty.Primary_Contact__c) {
                    continue;
                }
                if(oppty.Primary_Contact__c != null) {
                    contIdSet.add(oppty.Primary_Contact__c);
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** insert accountIdSet: ' + accountIdSet);
        for(Account acc : [Select Id, OwnerId From Account Where Id IN: accountIdSet]) {
            accountOwnerMap.put(acc.Id, acc.OwnerId);
        }

        if(accountIdSet.size() > 0) {
            createOpportunityTeamMember((List<Opportunity>)newlist, accountOwnerMap);
        }
        
        System.debug(LoggingLevel.INFO, '*** opptyIdSet: ' + opptyIdSet);
        System.debug(LoggingLevel.INFO, '*** contIdSet: ' + contIdSet);
        System.debug(LoggingLevel.INFO, '*** oldContIdSet: ' + oldContIdSet);
        List<OpportunityContactRole> primaryContactRoleList = new List<OpportunityContactRole>();
        
        if(contIdSet.size() > 0) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            for(Contact cont : [Select Id, Are_you_an_HR__c From Contact Where Id IN: contIdSet]) {
                contactMap.put(cont.Id, cont);
            }
            Map<String, OpportunityContactRole> existRoleMap = findOpportunityContactRole(opptyIdSet, contIdSet);
            
            System.debug(LoggingLevel.INFO, '*** existRoleMap: ' + existRoleMap);
            List<Opportunity> opptyList = new List<Opportunity>();
            for(Opportunity oppty : (List<Opportunity>)newlist) {
                if(oppty.Primary_Contact__c == null) {
                    continue;
                }
                String key = oppty.Id + ':' + oppty.Primary_Contact__c;
                if(existRoleMap.containsKey(key)) {
                    OpportunityContactRole contRole = existRoleMap.get(key);
                    contRole.IsPrimary = true;
                    contRole.Role = 'Participant';
                    if(contactMap.containsKey(oppty.Primary_Contact__c) && 'Yes' == contactMap.get(oppty.Primary_Contact__c).Are_you_an_HR__c) {
                        contRole.Role = 'HR Contact';
                    }
                    primaryContactRoleList.add(contRole);
                }else {
                    opptyList.add(oppty);
                }
            }
            if(opptyList.size() > 0) {
                createOpportunityContactRole(opptyList, contactMap);
            }
        }
        if(oldContIdSet.size() > 0) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            for(Contact cont : [Select Id, Are_you_an_HR__c From Contact Where Id IN: oldContIdSet]) {
                contactMap.put(cont.Id, cont);
            }
            Map<String, OpportunityContactRole> existRoleMap = findOpportunityContactRole(opptyIdSet, oldContIdSet);
            System.debug(LoggingLevel.INFO, '*** old existRoleMap: ' + existRoleMap);
            for(Opportunity oldOppty : (List<Opportunity>)oldlist) {
                if(oldOppty.Primary_Contact__c == null) {
                    continue;
                }
                String key = oldOppty.Id + ':' + oldOppty.Primary_Contact__c;
                if(existRoleMap.containsKey(key)) {
                    OpportunityContactRole contRole = existRoleMap.get(key);
                    contRole.IsPrimary = false;
                    primaryContactRoleList.add(contRole);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** primaryContactRoleList: ' + primaryContactRoleList);
        if(primaryContactRoleList.size() > 0) {
            update primaryContactRoleList;
        }
        return null;
    }

    public static void createOpportunityTeamMember(List<Opportunity> opptyList, Map<String, String> accountOwnerMap) {
        List<OpportunityTeamMember> memberList = new List<OpportunityTeamMember>();
        for(Opportunity oppty : opptyList) {
            if(!accountOwnerMap.containsKey(oppty.AccountId)) continue;
            String accOwnerId = accountOwnerMap.get(oppty.AccountId);
            if(oppty.OwnerId != accOwnerId) {
                OpportunityTeamMember member = new OpportunityTeamMember();
                member.OpportunityId = oppty.Id;
                member.UserId = accOwnerId;
                member.TeamMemberRole = 'Account Owner';
                member.OpportunityAccessLevel = 'Edit';
                memberList.add(member);
            }
        }
        if(memberList.size() > 0) {
            insert memberList;
        }
    }

    public static Map<String, OpportunityContactRole> findOpportunityContactRole(Set<String> opptyIdSet, Set<String> contIdSet) {
        Map<String, OpportunityContactRole> existRoleMap = new Map<String, OpportunityContactRole>();
        for(OpportunityContactRole contRole : [Select OpportunityId, ContactId, Role, IsPrimary From OpportunityContactRole Where OpportunityId IN: opptyIdSet And ContactId IN: contIdSet]) {
            String key = contRole.OpportunityId + ':' + contRole.ContactId;
            existRoleMap.put(key,contRole);
        }
        return existRoleMap;
    }

    public static void createOpportunityContactRole(List<Opportunity> opptyList, Map<Id, Contact> contactMap) {
        List<OpportunityContactRole> contRoleList = new List<OpportunityContactRole>();
        for(Opportunity oppty : opptyList) {
            OpportunityContactRole contRole = new OpportunityContactRole();
            contRole.OpportunityId = oppty.Id;
            contRole.ContactId = oppty.Primary_Contact__c;
            contRole.IsPrimary = true;
            contRole.Role = 'Participant';
            if(contactMap.containsKey(oppty.Primary_Contact__c) && 'Yes' == contactMap.get(oppty.Primary_Contact__c).Are_you_an_HR__c) {
                contRole.Role = 'HR Contact';
            }
            contRoleList.add(contRole);
        }
        System.debug(LoggingLevel.INFO, '*** contRoleList: ' + contRoleList);
        if(contRoleList.size() > 0) {
            insert contRoleList;
        }
    }
}