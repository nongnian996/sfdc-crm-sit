/**************************************************************************************
Class Name:  AccountTeamAutomaticallyAddHandler
Version     : 1.0 
Created Date    : 08/01/2019
Function    : when account created, automatically add a account team

Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                   08/01/2019                Version 1.0
*************************************************************************************/
global class AccountTeamAutomaticallyAddHandler extends hed.TDTM_Runnable{
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
       hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        if(triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            List<AccountTeamMember> memberlist = new List<AccountTeamMember>();
            for(Account acct : (List<Account>)newlist) {
                AccountTeamMember member = new AccountTeamMember();
                member.AccountId = acct.Id;
                member.UserId = acct.OwnerId;
                member.TeamMemberRole = 'Account Owner';
                memberlist.add(member);
            }
            if(memberlist.size() > 0 && memberlist.size() < 10000) {
                insert memberlist;
            }
        }
        return null;
    }
}