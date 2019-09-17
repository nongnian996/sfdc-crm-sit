/**************************************************************************************
Class Name:  AccountOperationHandler
Version     : 1.0 
Created Date    : 06/03/2019
Function    : create a team member when there is an update on Account's Owner

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Terry             06/03/2019              Original Version
*************************************************************************************/
global class AccountOperationHandler extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Set<String> accountIdSet = new Set<String>();
            List<OpportunityTeamMember> memberList = new List<OpportunityTeamMember>();
            Map<Id, Account> oldMap = new Map<Id,Account>();
            for(Account acct : (List<Account>)oldlist) {
                oldMap.put(acct.Id,acct);
            }
            for(Account acc : (List<Account>) newlist) {
                Account oldAcc = (Account)oldMap.get(acc.Id);
                if(acc.OwnerId != oldAcc.OwnerId) {
                    accountIdSet.add(acc.Id);
                }
            }
            System.debug(LoggingLevel.INFO, '*** update accountIdSet: ' + accountIdSet);

            if(accountIdSet.size() < 1) return null;

            System.debug(LoggingLevel.INFO, '*** insert accountIdSet: ' + accountIdSet);
            List<Account> updatedAccList = new List<Account>();
            Set<String> oppIdSet = new Set<String>();
            Map<String, Set<String>> oppUserIdMap = new Map<String, Set<String>>();
            for(Account acc : [Select Id, OwnerId, (Select Id, OwnerId From Opportunities) From Account Where Id IN: accountIdSet]) {
                updatedAccList.add(acc);
                for(Opportunity opp : acc.Opportunities) {
                    oppIdSet.add(opp.Id);
                }
            }
            //get exist opportunity team member, and setup opportunity and user map
            for(OpportunityTeamMember tm : [Select Id, OpportunityId, UserId From OpportunityTeamMember Where OpportunityId IN: oppIdSet]) {
                if(!oppUserIdMap.containsKey(tm.OpportunityId)) {
                    oppUserIdMap.put(tm.OpportunityId, new Set<String>());
                }
                // if(oppUserIdMap.containsKey(tm.OpportunityId)) {

                // }
                oppUserIdMap.get(tm.OpportunityId).add(tm.UserId);
            }
            System.debug(LoggingLevel.INFO, '*** oppUserIdMap: ' + oppUserIdMap);
            for(Account acc : updatedAccList) {

                for(Opportunity opp : acc.Opportunities) {
                    // System.debug(LoggingLevel.INFO, '*** xx: ' + oppUserIdMap.containsKey(opp.Id));
                    // System.debug(LoggingLevel.INFO, '*** zz: ' + (opp.OwnerId != acc.OwnerId));
                    if(opp.OwnerId != acc.OwnerId && (!oppUserIdMap.containsKey(opp.Id) || (oppUserIdMap.containsKey(opp.Id) && !oppUserIdMap.get(opp.Id).contains(acc.OwnerId)))) {
                        OpportunityTeamMember member = new OpportunityTeamMember();
                        member.OpportunityId = opp.Id;
                        member.UserId = acc.OwnerId;
                        member.TeamMemberRole = 'Account Owner';
                        member.OpportunityAccessLevel = 'Edit';
                        memberList.add(member);
                    }
                }
            }
            if(memberList.size() > 0) insert memberList;
        }
        return null;
    }

    // public void handle() {
    //     Set<String> accountIdSet = new Set<String>();
    //     List<OpportunityTeamMember> memberList = new List<OpportunityTeamMember>();
    //     if(Trigger.isAfter && Trigger.isUpdate) {
    //         for(Account acc : (List<Account>) Trigger.new) {
    //             Account oldAcc = ((Map<Id, Account>)Trigger.oldMap).get(acc.Id);
    //             if(acc.OwnerId != oldAcc.OwnerId) {
    //                 accountIdSet.add(acc.Id);
    //             }
    //         }
    //         System.debug(LoggingLevel.INFO, '*** update accountIdSet: ' + accountIdSet);
    //     }

    //     if(accountIdSet.size() < 1) return;

    //     System.debug(LoggingLevel.INFO, '*** insert accountIdSet: ' + accountIdSet);
    //     List<Account> updatedAccList = new List<Account>();
    //     Set<String> oppIdSet = new Set<String>();
    //     Map<String, Set<String>> oppUserIdMap = new Map<String, Set<String>>();
    //     for(Account acc : [Select Id, OwnerId, (Select Id, OwnerId From Opportunities) From Account Where Id IN: accountIdSet]) {
    //         updatedAccList.add(acc);
    //         for(Opportunity opp : acc.Opportunities) {
    //             oppIdSet.add(opp.Id);
    //         }
    //     }
    //     //get exist opportunity team member, and setup opportunity and user map
    //     for(OpportunityTeamMember tm : [Select Id, OpportunityId, UserId From OpportunityTeamMember Where OpportunityId IN: oppIdSet]) {
    //         if(!oppUserIdMap.containsKey(tm.OpportunityId)) {
    //             oppUserIdMap.put(tm.OpportunityId, new Set<String>());
    //         }
    //         // if(oppUserIdMap.containsKey(tm.OpportunityId)) {

    //         // }
    //         oppUserIdMap.get(tm.OpportunityId).add(tm.UserId);
    //     }
    //     System.debug(LoggingLevel.INFO, '*** oppUserIdMap: ' + oppUserIdMap);
    //     for(Account acc : updatedAccList) {

    //         for(Opportunity opp : acc.Opportunities) {
    //             // System.debug(LoggingLevel.INFO, '*** xx: ' + oppUserIdMap.containsKey(opp.Id));
    //             // System.debug(LoggingLevel.INFO, '*** zz: ' + (opp.OwnerId != acc.OwnerId));
    //             if(opp.OwnerId != acc.OwnerId && (!oppUserIdMap.containsKey(opp.Id) || (oppUserIdMap.containsKey(opp.Id) && !oppUserIdMap.get(opp.Id).contains(acc.OwnerId)))) {
    //                 OpportunityTeamMember member = new OpportunityTeamMember();
    //                 member.OpportunityId = opp.Id;
    //                 member.UserId = acc.OwnerId;
    //                 member.TeamMemberRole = 'Account Owner';
    //                 member.OpportunityAccessLevel = 'Edit';
    //                 memberList.add(member);
    //             }
    //         }
    //     }
    //     if(memberList.size() > 0) insert memberList;
    // }
}