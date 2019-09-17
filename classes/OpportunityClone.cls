/************************************************************************
Class Name : OpportunityClone
Version : 1.0
CreatedDate : 06/14/2019
Function : clone opportunity info with related opportunity info : opportunity product , opportunity team , opportunity contact role

Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             06/14/2019               Version 1.0
*************************************************************************/
public class OpportunityClone {
    //clone opportunity info with related opportunity product info
    @AuraEnabled
    public static string CloneOpportunityAndRelation(String recordId,String opportunityname,Date closedate) {
        String result = '';
        //query the opportunity info
        Opportunity oldoppoty = [SELECT AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, 
                                        ForecastCategoryName, CurrencyIsoCode, CampaignId, Pricebook2Id, OwnerId, ContractId, Primary_Group__c, Sales_Person__c, 
                                        Contract_Validity_Date__c, Product_Interest__c, Account_Plan__c,Territory2Id, 
                                        Winning_Likelihood__c, Lead_Description__c, MyFlag__c, Action_Taken_Date__c, Sponsor_Company__c, 
                                        Invoicing_Company__c, External_Unique_ID__c, CSP_Parent_Opportunity__c, 
                                        Row_ID__c, Distributor__c, Dealer__c, Referred_By__c, Integration_ID__c, Primary_Contact__c, Primary_Contact_External_ID__c, 
                                        Session_Change_Error__c, Program_Director_1__c, Program_Director_2__c, Opportunity_Origin__c, 
                                        Priority_Account__c, Prime_Account__c, Owner_Account__c, Session__c, Session_End_Date__c, Session_Start_Date__c, 
                                        CSO_Source_Record_ID__c, Session_Status__c, Has_APOL__c, APOL_Created_Date__c, APOL_Modified_Date__c, Completion_Percentage__c, 
                                        APOL_Status__c, Programme_Director_Rating__c, Programme_Rating__c, Refer_Type__c, EDP_Marketing_Score__c, Primary_PA__c, 
                                        Sales_Seat_Stage__c, Action_Taken__c, Action_Planned__c, Opportunity_Create_Reason__c, Product_Interest_Type__c, Priority__c, 
                                        EMBA_Product_of_Interest__c, Personal_Data__c, Academic_Degree__c, Professional_Background__c, Yourself_Your_Organization__c, 
                                        Sponsoring_Invoicing__c, References__c, Reason_Lost__c, Competitor_Lost_To__c, Secondary_PA__c,Child_Delivered__c, 
                                        Sponsor_HR_Rating__c, Expected_Contract_Revenue__c, Profile__c, Budget__c, Authority__c, Timing__c, Intermediary_Company__c,RecordType.DeveloperName,
                                        (SELECT OpportunityId, PricebookEntryId, Product2Id, Quantity, TotalPrice, UnitPrice, ServiceDate, 
                                                Description, Change_Reason__c, Delivered__c, Delivery_Mode__c, Prep_Days__c, Standard_Delivery_Days__c, 
                                                Start_Date__c, End_Date__c, Delivery_Site__c,Financial_Location__c,Coaching_Days__c,Coaching_Rate__c, 
                                                Follow_up_Project_action_learning_revenu__c, Follow_up_coaching_project_support_reven__c, 
                                                Virtual_Online_Learning_Webinar_revenue__c, Any_other_additional_revenue__c, Additional_description__c, 
                                                Delivery_Rate__c, Prep_Daily_Rate__c, Total_Number_of_Seats__c, Number_of_Enrolments__c, 
                                                Number_of_Reserved_Seats__c, Number_of_Available_Seats__c, Manual_Price__c,Discount 
                                                FROM OpportunityLineItems),
                                        (SELECT OpportunityId, UserId, TeamMemberRole, CurrencyIsoCode,OpportunityAccessLevel FROM OpportunityTeamMembers),
                                        (SELECT OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRoles)
                                        FROM Opportunity 
                                        WHERE Id =: recordId];
        System.debug(LoggingLevel.INFO,'Old oppty Info : '+oldoppoty);
        Savepoint sp = Database.setSavepoint();
        try {
            // system clone method
            Opportunity newoppty = oldoppoty.clone(false,false,false,false);
            insert newoppty;

            Opportunity newopptys = [SELECT Id,CloseDate,Name FROM Opportunity WHERE Id=: newoppty.Id];
            newopptys.CloseDate = closedate;
            newopptys.Name = opportunityname;
            if(oldoppoty.RecordType.DeveloperName.contains('OEP') && oldoppoty.RecordType.DeveloperName.contains('B2B')) {
                newopptys.StageName = 'Discover';
            }
            else if(oldoppoty.RecordType.DeveloperName.contains('OEP') && !oldoppoty.RecordType.DeveloperName.contains('B2B')){
                newopptys.StageName = 'New';
            }
            else if(oldoppoty.RecordType.DeveloperName.contains('CSP')){
                newopptys.StageName = 'Nurturing';
            }
            update newopptys;

            //if opportunity product list not empty
            if(oldoppoty.OpportunityLineItems.size() > 0) {
                List<OpportunityLineItem> newopptitemlist = new List<OpportunityLineItem>();
                for(OpportunityLineItem olditem : oldoppoty.OpportunityLineItems) {
                    OpportunityLineItem newitem = new OpportunityLineItem();
                    newitem.OpportunityId = newopptys.Id;
                    newitem.Product2Id = olditem.Product2Id;
                    newitem.Change_Reason__c = olditem.Change_Reason__c;
                    newitem.PricebookEntryId = olditem.PricebookEntryId;
                    newitem.Quantity = olditem.Quantity;
                    newitem.UnitPrice = olditem.UnitPrice;
                    newitem.Description = olditem.Description;
                    newitem.Additional_description__c = olditem.Additional_description__c;
                    newitem.Any_other_additional_revenue__c = olditem.Any_other_additional_revenue__c;
                    newitem.Coaching_Rate__c = olditem.Coaching_Rate__c;
                    newitem.Coaching_Days__c = olditem.Coaching_Days__c;
                    newitem.ServiceDate = olditem.ServiceDate;
                    newitem.Delivered__c = olditem.Delivered__c;
                    newitem.Delivery_Mode__c = olditem.Delivery_Mode__c;
                    newitem.Delivery_Rate__c = olditem.Delivery_Rate__c;
                    newitem.Delivery_Site__c = olditem.Delivery_Site__c;
                    newitem.Discount = olditem.Discount;
                    newitem.Financial_Location__c = olditem.Financial_Location__c;
                    newitem.Follow_up_Project_action_learning_revenu__c = olditem.Follow_up_Project_action_learning_revenu__c;
                    newitem.Manual_Price__c = olditem.Manual_Price__c;
                    newitem.Number_of_Available_Seats__c = olditem.Number_of_Available_Seats__c;
                    newitem.Number_of_Enrolments__c = olditem.Number_of_Enrolments__c;
                    newitem.Number_of_Reserved_Seats__c = olditem.Number_of_Reserved_Seats__c;
                    newitem.Prep_Daily_Rate__c = olditem.Prep_Daily_Rate__c;
                    newitem.Prep_Days__c = olditem.Prep_Days__c;
                    newitem.Standard_Delivery_Days__c = olditem.Standard_Delivery_Days__c;
                    newitem.Total_Number_of_Seats__c = olditem.Total_Number_of_Seats__c;
                    newitem.Virtual_Online_Learning_Webinar_revenue__c = olditem.Virtual_Online_Learning_Webinar_revenue__c;
                    newopptitemlist.add(newitem);
                }
                insert newopptitemlist;
            }
            //if opportuniy team member list not empty
            if(oldoppoty.OpportunityTeamMembers.size() > 0) {
                List<OpportunityTeamMember> teammemberlist = new List<OpportunityTeamMember>();
                for(OpportunityTeamMember teamer : oldoppoty.OpportunityTeamMembers) {
                    OpportunityTeamMember member = new OpportunityTeamMember();
                    member.OpportunityId = newopptys.Id;
                    member.TeamMemberRole = teamer.TeamMemberRole;
                    member.UserId = teamer.UserId;
                    member.CurrencyIsoCode = teamer.CurrencyIsoCode;
                    teammemberlist.add(member);
                }
                insert teammemberlist;
            }
            //if opportunity contact role not empty
            if(oldoppoty.OpportunityContactRoles.size() > 0) {
                List<OpportunityContactRole> rolelist = new List<OpportunityContactRole>();
                for(OpportunityContactRole role : oldoppoty.OpportunityContactRoles) {
                    if(oldoppoty.Primary_Contact__c != null && role.ContactId == oldoppoty.Primary_Contact__c) {
                        continue;
                    }
                    OpportunityContactRole roles = new OpportunityContactRole();
                    roles.ContactId = role.ContactId;
                    roles.Role = role.Role;
                    roles.IsPrimary = role.IsPrimary;
                    roles.OpportunityId = newopptys.Id;
                    rolelist.add(roles);
                }
                insert rolelist;
            }
            result = 'Success,new oppty record Id:'+newoppty.Id;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO,'exception message : ' + e.getMessage());
            result = e.getMessage();
            Database.rollback(sp);
        }
        return result;
    }
}