/************************************************************************************
Class Name : WarmActivity4LeadConversionHandler
Version : 1.0 
Created Date : 08/28/2019
Function : Auto convert lead to Account, Contact, Opportunity when there's a warm activity coming in salesforce

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/28/2019               Version 1.0
*************************************************************************************/
public with sharing class WarmActivity4LeadConversionHandler {
    
    public static Set<String> sessionSet = new Set<String>{'AMP', 'TGM', 'MAP'};
    public static void autoConvertLead(Activity__c activity) {
        String productName = activity.Program_Name__c;
        Activity__c tmpActivity = [Select Id, Processed_by_Lead2Oppy__c From Activity__c Where Id =: activity.Id];

        if(tmpActivity.Processed_by_Lead2Oppy__c) {
            return;
        }
        // if(activity.EDP_Marketing_Score__c == null || activity.EDP_Marketing_Score__c > 'B4') {
        //     tmpActivity.Verification_Error__c = Label.Min_leadscore_error;
        //     tmpActivity.Processed_by_Lead2Oppy__c = true;
        //     update tmpActivity;
        // }
        Lead theLead = [Select Id, FirstName, LastName, Email, Company, Country, 
                                Eloqua_Contact_ID__c, 
                                Program_Name__c, 
                                OwnerId,
                                Current_Job_Function__c,
                                Work_Country__c,
                                Job_Title__c,
                                EDP_Marketing_Score__c,
                                Reserved_Session__c,
                                Job_Function_Verification__c,
                                Job_Level_Verification_AMP__c,
                                Job_Level_Verification_TGM__c,
                                Job_Level_Verification_MAP__c,
                                Work_Country_Verification__c
                        From Lead Where Id =: activity.Lead__c];
        if(sessionSet.contains(theLead.Program_Name__c) && !theLead.Work_Country_Verification__c) {
            updateErrorMessage(tmpActivity, Label.Work_Country_mismatch);
            return;
        }
        if(('AMP' == theLead.Program_Name__c && !theLead.Job_Level_Verification_AMP__c) || ('MAP' == theLead.Program_Name__c && !theLead.Job_Level_Verification_MAP__c) || ('TGM' == theLead.Program_Name__c && !theLead.Job_Level_Verification_TGM__c)) {
            updateErrorMessage(tmpActivity, Label.Job_level_mismatch);
            return;
        }
        if('AMP' == theLead.Program_Name__c && !theLead.Job_Function_Verification__c) {
            updateErrorMessage(tmpActivity, Label.Job_Function_mismatch);
            return;
        }
        tmpActivity = new Activity__c(Id = activity.Id);
        List<Product2> productList = HotActivity4LeadConversionHandler.findProductByName(activity);
        // List<Product2> specificProductList = [Select Id From Product2 Where Name =: reservedSession];
        if(productList.size() < 1) {
            updateErrorMessage(tmpActivity, Label.No_session_available);
            return;
        }

        String firstName = theLead.FirstName, lastName = theLead.LastName, email = theLead.Email, eloquaContactId = theLead.Eloqua_Contact_ID__c;
        String company = theLead.Company, country = theLead.Country;
        List<Contact> contactList = new List<Contact>();
        if(String.isNotBlank(eloquaContactId)) {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Account.Name, Account.RecordType.DeveloperName 
                                            FROM Contact
                                            WHERE Eloqua_Contact_ID__c =: eloquaContactId
                                            OR (FirstName =: firstName 
                                                AND LastName =: lastName 
                                                AND (Email =: email OR hed__AlternateEmail__c =: email 
                                                    OR Home_Email__c =: email OR hed__Preferred_Email__c =: email
                                                    OR hed__WorkEmail__c =: email))];
        }else {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Account.Name, Account.RecordType.DeveloperName 
                                            FROM Contact
                                            WHERE FirstName =: firstName 
                                                AND LastName =: lastName 
                                                AND (Email =: email OR hed__AlternateEmail__c =: email 
                                                    OR Home_Email__c =: email OR hed__Preferred_Email__c =: email
                                                    OR hed__WorkEmail__c =: email)];
        }
        System.debug(LoggingLevel.INFO, '*** contactList: ' + contactList);
        if(contactList != null && contactList.size() > 1) {
            // tmpActivity.Verification_Error__c = 'More than one duplicate contacts found error';
            // tmpActivity.Processed_by_Lead2Oppy__c = true;
            // update tmpActivity;
            updateErrorMessage(tmpActivity, Label.Duplicate_contacts_found);
            return;
        }
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(theLead.Id);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        if(contactList.size() == 1) {
            System.debug(LoggingLevel.INFO, '*** : did not find matching contact ');
            List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> openItemList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> closedItemList = new List<OpportunityLineItem>();
            
            itemList = [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate 
                    From OpportunityLineItem 
                    Where Product2Id =: productList[0].Id 
                    And Product2.Product_Type__c != 'Certificate' 
                    And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
            Date compareDate = System.today().addDays(-90);
            Set<String> openOpptyItemIdSet1 = new Set<String>();
            Set<String> closedOpptyItemIdSet1 = new Set<String>();
            for(OpportunityLineItem item : itemList) {
                if(item.Opportunity.IsClosed && item.Opportunity.CloseDate > compareDate) {
                    closedItemList.add(item);
                    closedOpptyItemIdSet1.add(item.OpportunityId);
                }else {
                    openItemList.add(item);
                    openOpptyItemIdSet1.add(item.OpportunityId);
                } 
            }
            
            List<OpportunityContactRole> contRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> openContRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> closedContRoleList = new List<OpportunityContactRole>();

            contRoleList = [Select OpportunityId, ContactId, Opportunity.IsClosed, Opportunity.CloseDate From OpportunityContactRole Where ContactId =: contactList[0].Id And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
            Set<String> openOpptyContIdSet1 = new Set<String>();
            Set<String> closedOpptyContIdSet1 = new Set<String>();
            for(OpportunityContactRole item : contRoleList) {
                if(item.Opportunity.IsClosed && item.Opportunity.CloseDate > compareDate) {
                    closedContRoleList.add(item);
                    closedOpptyContIdSet1.add(item.OpportunityId);
                }else {
                    openContRoleList.add(item);
                    openOpptyContIdSet1.add(item.OpportunityId);
                } 
            }
            openOpptyItemIdSet1.retainAll(openOpptyContIdSet1);
            closedOpptyItemIdSet1.retainAll(closedOpptyContIdSet1);
            List<String> openOppIdList = new List<String>(openOpptyItemIdSet1);
            List<String> closedOppIdList = new List<String>(closedOpptyContIdSet1);
            if(openOppIdList.size() == 1 || closedOppIdList.size() == 1) {
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Contact__c = contactList[0].Id;
                // tmpActivity.Opportunity__c = openOppIdList.size() == 1? openOppIdList[0] : closedOppIdList[0];
                update tmpActivity;
                if(activity.Campaign__c != null) {
                    Opportunity tmpOppty = new Opportunity();
                    tmpOppty.Id = openOppIdList.size() == 1? openOppIdList[0] : closedOppIdList[0];
                    tmpOppty.CampaignId = activity.Campaign__c;
                    update tmpOppty;
                }
                
                return;
            }

            if(openOppIdList.size() > 1 || closedOppIdList.size() > 1) {
                updateErrorMessage(tmpActivity, Label.Open_opportunites_Error);
                return;
            }
            Activity__c chooseActivity = checkValidateActivity(theLead.Id, activity, 'Lead');
            if(chooseActivity == null) return;
            //Match the participant profile 
            productName = chooseActivity.Program_Name__c;
            //create opportunity
            // List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];

            // Database.LeadConvert Leadconvert = new Database.LeadConvert();
            // Leadconvert.setLeadId(theLead.Id);
            Leadconvert.setContactId(contactList[0].Id);
            Leadconvert.setAccountId(contactList[0].AccountId);
            Database.LeadConvertResult result = Database.convertLead(Leadconvert);
            String opptyName = activity.Reserved_Session__c == null? activity.Program_Name__c : activity.Reserved_Session__c;
            if(contactList[0].Account.RecordType.DeveloperName == 'Business_Organization') {
                opptyName += ' - ' + contactList[0].Account.Name;
            }
            opptyName += ' - ' + contactList[0].FirstName + ' ' + contactList[0].LastName;
            Leadconvert.setOpportunityName(opptyName);

            if(result.isSuccess()) {
                // OpportunityContactRole ocr = new OpportunityContactRole();
                // ocr.OpportunityId = result.getOpportunityId();
                // ocr.ContactId = result.getContactId();
                // ocr.Role = 'Participant';
                // insert ocr;

                System.debug(LoggingLevel.INFO, '*** result.getContactId(): ' + result.getContactId());
                System.debug(LoggingLevel.INFO, '*** result.getOpportunityId(): ' + result.getOpportunityId());
                List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];
                Opportunity oppty = [Select Id, CurrencyIsoCode From Opportunity Where Id =: result.getOpportunityId()];
                if(chooseActivity.Campaign__c != null) {
                    oppty.CampaignId = chooseActivity.Campaign__c;
                }
                oppty.Primary_Contact__c = result.getContactId();
                update oppty;
                productList = HotActivity4LeadConversionHandler.findProductByName(chooseActivity);
                HotActivity4LeadConversionHandler.transferActivities(theLead.Id, result.getContactId(), chooseActivity.Id);
                HotActivity4LeadConversionHandler.createOpportunityLineItem(oppty, productList[0].Id, pricebookList);
                chooseActivity.Contact__c = result.getContactId();
                chooseActivity.Opportunity__c = result.getOpportunityId();
                chooseActivity.Processed_by_Lead2Oppy__c = true;
                chooseActivity.Lead__c = null;
            }else {
                chooseActivity.Processed_by_Lead2Oppy__c = true;
                chooseActivity.Verification_Error__c = Label.Conversion_Error;
            }
            update chooseActivity;
        }else if(contactList.size() < 1) {
            System.debug(LoggingLevel.INFO, '*** : did not find matching contact ');
            Activity__c chooseActivity = checkValidateActivity(theLead.Id, activity, 'Lead');
            System.debug(LoggingLevel.INFO, '*** chooseActivity: ' + chooseActivity);
            if(chooseActivity == null) return;
            //Match the participant profile 
            productName = chooseActivity.Program_Name__c;
            //create opportunity
            String opptyName = chooseActivity.Reserved_Session__c == null? chooseActivity.Program_Name__c : chooseActivity.Reserved_Session__c;
            Map<String, String> acctRTMap = InseadUtil.getObjectRecordType('Account');
            if(!company.containsIgnoreCase('Administrative Account')) {
                List<Account> acctList = [Select Id From Account Where Name =: company And BillingCountry =: country];
                if(acctList.size() > 0) {
                    Leadconvert.setAccountId(acctList[0].Id);
                }else {
                    Account newAcct = new Account(Name = company);
                    newAcct.RecordTypeId = acctRTMap.get('Business_Organization');
                    insert newAcct;
                    Leadconvert.setAccountId(newAcct.Id);
                }
                opptyName += ' - ' + company;
            }
            opptyName += ' - ' + firstName + ' ' + lastName;
            Leadconvert.setOpportunityName(opptyName);
            Database.LeadConvertResult result = Database.convertLead(Leadconvert);
            // String searchText = '%generic%';
            if(result.isSuccess()) {
                // OpportunityContactRole ocr = new OpportunityContactRole();
                // ocr.OpportunityId = result.getOpportunityId();
                // ocr.ContactId = result.getContactId();
                // ocr.Role = 'Participant';
                // insert ocr;

                System.debug(LoggingLevel.INFO, '*** result.getContactId(): ' + result.getContactId());
                System.debug(LoggingLevel.INFO, '*** result.getOpportunityId(): ' + result.getOpportunityId());
                List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];
                Opportunity oppty = [Select Id, CurrencyIsoCode From Opportunity Where Id =: result.getOpportunityId()];
                if(chooseActivity.Campaign__c != null) {
                    oppty.CampaignId = chooseActivity.Campaign__c;
                }
                oppty.Primary_Contact__c = result.getContactId();
                update oppty;
                System.debug(LoggingLevel.INFO, '*** chooseActivity: ' + chooseActivity);
                if(chooseActivity.Reserved_Session__c != null) {
                    productList = [Select Id, Name From Product2 Where Name =: chooseActivity.Program_Name__c];
                }else {
                    productList = HotActivity4LeadConversionHandler.findProductByName(chooseActivity);
                    if(productList.size() < 1) {
                        productList = [Select Id, Name From Product2 Where Name =: chooseActivity.Program_Name__c];
                    }
                }
                HotActivity4LeadConversionHandler.transferActivities(theLead.Id, result.getContactId(), chooseActivity.Id);
                HotActivity4LeadConversionHandler.createOpportunityLineItem(oppty, productList[0].Id, pricebookList);
                chooseActivity.Contact__c = result.getContactId();
                chooseActivity.Opportunity__c = result.getOpportunityId();
                chooseActivity.Processed_by_Lead2Oppy__c = true;
                chooseActivity.Lead__c = null;
            }else {
                chooseActivity.Processed_by_Lead2Oppy__c = true;
                chooseActivity.Verification_Error__c = Label.Conversion_Error;
            }
            System.debug(LoggingLevel.INFO, '*** update chooseActivity: ' + chooseActivity);
            update chooseActivity;
        }
    }

    public static void autoCreateOpportunity4Contact(Activity__c activity, String contactId) {
        Activity__c tmpActivity = [Select Id, Processed_by_Lead2Oppy__c From Activity__c Where Id =: activity.Id];

        if(tmpActivity.Processed_by_Lead2Oppy__c) {
            return;
        }
        // if(activity.EDP_Marketing_Score__c == null || activity.EDP_Marketing_Score__c > 'B4') {
        //     tmpActivity.Verification_Error__c = Label.Min_leadscore_error;
        //     tmpActivity.Processed_by_Lead2Oppy__c = true;
        //     update tmpActivity;
        // }
        // Contact cont = [Select FirstName, LastName, AccountId From Contact Where Id =: contactId];
        Contact cont = [Select Id, FirstName, LastName, Email, Company__c, AccountId, 
                                Eloqua_Contact_ID__c, 
                                Program_Name__c, 
                                OwnerId,
                                Current_Job_Function__c,
                                Work_Country__c,
                                Job_Title__c,
                                EDP_Marketing_Score__c,
                                Reserved_Session__c,
                                Job_Function_Verification__c,
                                Job_Level_Verification_AMP__c,
                                Job_Level_Verification_TGM__c,
                                Job_Level_Verification_MAP__c,
                                Work_Country_Verification__c,
                                ACG_Interest_Adv_Certificate_in_Gov__c,
                                CGM_Interest__c,
                                OOC_Interest__c,
                                Account.Name,
                                Account.RecordType.DeveloperName  
                        From Contact Where Id =: contactId];

        tmpActivity = new Activity__c(Id = activity.Id);
        if(sessionSet.contains(cont.Program_Name__c) && !cont.Work_Country_Verification__c) {
            updateErrorMessage(tmpActivity, Label.Work_Country_mismatch);
            return;
        }

        if(('AMP' == cont.Program_Name__c && !cont.Job_Level_Verification_AMP__c) || ('MAP' == cont.Program_Name__c && !cont.Job_Level_Verification_MAP__c) || ('TGM' == cont.Program_Name__c && !cont.Job_Level_Verification_TGM__c)) {
            updateErrorMessage(tmpActivity, Label.Job_level_mismatch);
            return;
        }
        if('AMP' == cont.Program_Name__c && !cont.Job_Function_Verification__c) {
            updateErrorMessage(tmpActivity, Label.Job_Function_mismatch);
            return;
        }
        
        List<Product2> productList = HotActivity4LeadConversionHandler.findProductByName(activity);
        // List<Product2> specificProductList = [Select Id From Product2 Where Name =: reservedSession];
        if(productList.size() < 1) {
            updateErrorMessage(tmpActivity, Label.No_session_available);
            return;
        }
        
        List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> openItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> closedItemList = new List<OpportunityLineItem>();
        itemList = [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate 
                    From OpportunityLineItem 
                    Where Product2Id =: productList[0].Id 
                    And Product2.Product_Type__c != 'Certificate' 
                    And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
        Date compareDate = System.today().addDays(-90);
        Set<String> openOpptyItemIdSet1 = new Set<String>();
        Set<String> closedOpptyItemIdSet1 = new Set<String>();
        for(OpportunityLineItem item : itemList) {
            if(item.Opportunity.IsClosed && item.Opportunity.CloseDate > compareDate) {
                closedItemList.add(item);
                closedOpptyItemIdSet1.add(item.OpportunityId);
            }else {
                openItemList.add(item);
                openOpptyItemIdSet1.add(item.OpportunityId);
            } 
        }
        
        List<OpportunityContactRole> contRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> openContRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> closedContRoleList = new List<OpportunityContactRole>();

        contRoleList = [Select OpportunityId, ContactId, Opportunity.IsClosed, Opportunity.CloseDate From OpportunityContactRole Where ContactId =: cont.Id And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
        Set<String> openOpptyContIdSet1 = new Set<String>();
        Set<String> closedOpptyContIdSet1 = new Set<String>();
        for(OpportunityContactRole item : contRoleList) {
            if(item.Opportunity.IsClosed && item.Opportunity.CloseDate > compareDate) {
                closedContRoleList.add(item);
                closedOpptyContIdSet1.add(item.OpportunityId);
            }else {
                openContRoleList.add(item);
                openOpptyContIdSet1.add(item.OpportunityId);
            } 
        }
        openOpptyItemIdSet1.retainAll(openOpptyContIdSet1);
        closedOpptyItemIdSet1.retainAll(closedOpptyContIdSet1);
        System.debug(LoggingLevel.INFO, '*** openOpptyItemIdSet1: ' + openOpptyItemIdSet1);
        System.debug(LoggingLevel.INFO, '*** closedOpptyItemIdSet1: ' + closedOpptyItemIdSet1);
        List<String> openOppIdList = new List<String>(openOpptyItemIdSet1);
        List<String> closedOppIdList = new List<String>(closedOpptyContIdSet1);
        if(openOppIdList.size() == 1 || closedOppIdList.size() == 1) {
            tmpActivity.Processed_by_Lead2Oppy__c = true;
            // tmpActivity.Opportunity__c = openOppIdList.size() == 1? openOppIdList[0] : closedOppIdList[0];
            tmpActivity.Contact__c = cont.Id;
            update tmpActivity;
            if(activity.Campaign__c != null) {
                Opportunity tmpOppty = new Opportunity();
                tmpOppty.Id = openOppIdList.size() == 1? openOppIdList[0] : closedOppIdList[0];
                tmpOppty.CampaignId = activity.Campaign__c;
                update tmpOppty;
            }
            return;
        }

        if(openOppIdList.size() > 1 || closedOppIdList.size() > 1) {
            // tmpActivity.Processed_by_Lead2Oppy__c = true;
            // tmpActivity.Verification_Error__c = 'Exist opportunities error';
            // update tmpActivity;
            updateErrorMessage(tmpActivity, Label.Open_opportunites_Error);
            return;
        }
        Activity__c chooseActivity = checkValidateActivity(cont.Id, activity, 'Contact');
        if(chooseActivity == null) return;

        //create opportunity and opportunity line item
        try {
            List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];
            Map<String, String> opptyRTMap = InseadUtil.getObjectRecordType('Opportunity');
            String recordTypeId = 'Yes' == chooseActivity.Are_you_a_HR__c? opptyRTMap.get('OEP_Online') : opptyRTMap.get('OEP_F2F');
            String pricebookId = pricebookList[0].Id;
            String sessionName = chooseActivity.Reserved_Session__c == null? chooseActivity.Program_Name__c : chooseActivity.Reserved_Session__c;
            Opportunity oppty = HotActivity4LeadConversionHandler.createOpportunity(cont, recordTypeId, pricebookId, chooseActivity.Campaign__c, true, sessionName);
            System.debug(LoggingLevel.INFO, '*** : ' + [Select Id, CurrencyIsoCode From Opportunity Where Id =: oppty.Id]);
            oppty = [Select Id, Name, CurrencyIsoCode, Pricebook2Id From Opportunity Where Id =: oppty.Id];
            HotActivity4LeadConversionHandler.createOpportunityLineItem(oppty, productList[0].Id, pricebookList);
            //create opportunity contact role
            // OpportunityContactRole ocr = new OpportunityContactRole();
            // ocr.OpportunityId = oppty.Id;
            // ocr.ContactId = cont.Id;
            // ocr.Role = 'Participant';
            // insert ocr;

            chooseActivity.Opportunity__c = oppty.Id;
            chooseActivity.Processed_by_Lead2Oppy__c = true;
            chooseActivity.Contact__c = cont.Id;
            chooseActivity.Lead__c = null;
            update chooseActivity;
        }catch(Exception ex) {
            updateErrorMessage(chooseActivity, ex.getMessage());
        }
    }



    public static Activity__c checkValidateActivity(String pId, Activity__c activity, String type) {
        Activity__c tmpActivity = new Activity__c(Id = activity.Id);
        Activity__c chooseActivity = null;
        List<Activity__c> activityList = findActivitiesByParentId(pId, activity.Id, type);
        if(activityList.size() > 0) {
            Boolean flag = false;
            Activity__c relateAcitivity = activityList[0];
            if(activity.EDP_Marketing_Score__c != null && activity.EDP_Marketing_Score__c < relateAcitivity.EDP_Marketing_Score__c) {
                chooseActivity = activity;
                // return chooseActivity;
                if(activity.EDP_Marketing_Score__c > 'B4') {
                    activity.Verification_Error__c = Label.Not_a_valid_lead_score;
                    flag = true;
                }
            }else {
                chooseActivity = relateAcitivity;
                if(relateAcitivity.EDP_Marketing_Score__c > 'B4') {
                    flag = true;
                    relateAcitivity.Verification_Error__c = Label.Not_a_valid_lead_score;
                }
            }
            activityList.add(activity);
            List<Activity__c> updateList = new List<Activity__c>();
            for(Activity__c act : activityList) {
                Activity__c tmpAct = new Activity__c(Id = act.Id);
                tmpAct.Processed_by_Lead2Oppy__c = true;
                tmpAct.Verification_Error__c = tmpAct.Verification_Error__c == null? Label.Min_leadscore_error : tmpAct.Verification_Error__c;
                if(act.EDP_Marketing_Score__c > 'B4') {
                    tmpAct.Verification_Error__c = Label.Not_a_valid_lead_score;
                }
                updateList.add(tmpAct);
            }
            update updateList;
            if(flag) {
                return null;
            }
        }else {
            System.debug(LoggingLevel.INFO, '*** :2222 ');
            if(activity.EDP_Marketing_Score__c == null || activity.EDP_Marketing_Score__c > 'B4') {
                return updateErrorMessage(tmpActivity, Label.Not_a_valid_lead_score);
            }
            chooseActivity = activity;
        }
        System.debug(LoggingLevel.INFO, '*** chooseActivity: ' + chooseActivity);
        return chooseActivity;
    }

    public static Activity__c updateErrorMessage(Activity__c activity, String message) {
        activity.Processed_by_Lead2Oppy__c = true;
        activity.Verification_Error__c = message;
        update activity;
        return null;
    }

    public static List<Activity__c> findActivitiesByParentId(String pId, String activityId, String type) {
        
        String query = InseadUtil.prepareQuery('Activity__c');
        query += ' Where Id != \'' + activityId + '\'';
        query += ' And Processed_by_Lead2Oppy__c = false';
        query += ' And Lead_Type__c = \'OEP\'';
        query += ' And Lead_Status__c = \'Qualifying\'';
        query += ' And Product_Interest_Type__c != null';
        query += ' And Product_Interest_Type__c Like \'%Brochure%\'';
        if(type == 'Lead') {
            query += ' And Lead__c = \'' + pId + '\'';
        }
        if(type == 'Contact') {
            query += ' And Contact__c = \'' + pId + '\'';
        }
        query += ' And EDP_Marketing_Score__c != null';
        query += ' And Rating__c = \'Warm\'';

        Datetime today = System.now();
        String startDatetime = today.addDays(Integer.valueOf(Label.START_DAY_NUMBER)).format('YYYY-MM-dd') + 'T23:59:59Z';
        // System.debug(LoggingLevel.INFO, '*** startDate: ' + startDate);
        // Datetime endDate = today.addDays(Integer.valueOf(Label.END_DAY_NUMBER));
        String endDatetime = today.addDays(Integer.valueOf(Label.END_DAY_NUMBER)).format('YYYY-MM-dd') + 'T00:00:00Z';
        query += ' And CreatedDate <= ' + startDatetime;
        query += ' And CreatedDate >= ' + endDatetime;

        query += ' Order by EDP_Marketing_Score__c DESC NULLS LAST, CreatedDate DESC';
        System.debug(LoggingLevel.INFO, '*** query: ' + query);
        List<Activity__c> activityList = (List<Activity__c>)Database.query(query);
        System.debug(LoggingLevel.INFO, '*** activityList: ' + activityList);
        return activityList;
    }
}