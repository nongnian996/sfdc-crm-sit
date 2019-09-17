/************************************************************************************
Class Name : HotActivity4LeadConversionHandler
Version : 1.0 
Created Date : 08/28/2019
Function : Auto convert lead to Account, Contact, Opportunity when there's a hot activity coming in salesforce

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                08/28/2019               Version 1.0
*************************************************************************************/
public with sharing class HotActivity4LeadConversionHandler {
    
    
    public static void autoConvertLead(Activity__c activity) {
        Lead theLead = [Select Id, FirstName, LastName, Email, Company, Country, Eloqua_Contact_ID__c, Program_Name__c, OwnerId, EDP_Marketing_Score__c From Lead Where Id =: activity.Lead__c];

        Activity__c tmpActivity = new Activity__c(Id = activity.Id);
        
        List<Product2> productList = findProductByName(activity);
        if(productList.size() < 1) {
            updateErrorMessage(tmpActivity, Label.No_session_available);
            return;
        }

        String firstName = theLead.FirstName, lastName = theLead.LastName, email = theLead.Email, eloquaContactId = theLead.Eloqua_Contact_ID__c;
        String company = theLead.Company, country = theLead.Country;
        List<Contact> contactList = new List<Contact>();
        if(String.isNotBlank(eloquaContactId)) {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId
                                            FROM Contact
                                            WHERE Eloqua_Contact_ID__c =: eloquaContactId
                                            OR (FirstName =: firstName 
                                                AND LastName =: lastName 
                                                AND (Email =: email OR hed__AlternateEmail__c =: email 
                                                    OR Home_Email__c =: email OR hed__Preferred_Email__c =: email
                                                    OR hed__WorkEmail__c =: email))];
        }else {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId
                                            FROM Contact
                                            WHERE FirstName =: firstName 
                                                AND LastName =: lastName 
                                                AND (Email =: email OR hed__AlternateEmail__c =: email 
                                                    OR Home_Email__c =: email OR hed__Preferred_Email__c =: email
                                                    OR hed__WorkEmail__c =: email)];
        }
        System.debug(LoggingLevel.INFO, '*** contactList: ' + contactList);
        if(contactList != null && contactList.size() > 1) {
            updateErrorMessage(tmpActivity, Label.Duplicate_contacts_found);
            return;
        }

        // List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(theLead.Id);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        if(contactList.size() == 1) {
            Opportunity oppty = autoTagOpportunity2Contact(activity, contactList[0].Id, false);
            if(oppty != null) {
                Leadconvert.setOpportunityId(oppty.Id);
            }else {
                return;
            }
            Leadconvert.setContactId(contactList[0].Id);
            Leadconvert.setAccountId(contactList[0].AccountId);
            Database.LeadConvertResult result = Database.convertLead(Leadconvert);
            if(result.isSuccess()) {
                transferActivities(theLead.Id, result.getContactId(), tmpActivity.Id);
                tmpActivity.Contact__c = result.getContactId();
                tmpActivity.Opportunity__c = result.getOpportunityId();
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Lead__c = null;
            }else {
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Verification_Error__c = Label.Conversion_Error;
            }

            update tmpActivity;

            oppty.Primary_Contact__c = contactList[0].Id;
            oppty.CampaignId = activity.Campaign__c;
            update oppty;

        }else if(contactList.size() < 1) {
            // if(String.isBlank(company)) company = firstName + lastName + 'Administrative Account';
            Map<String, String> acctRTMap = InseadUtil.getObjectRecordType('Account');
            String opptyName = activity.Reserved_Session__c == null? activity.Program_Name__c : activity.Reserved_Session__c;
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
            if(result.isSuccess()) {
                System.debug(LoggingLevel.INFO, '*** result.getContactId(): ' + result.getContactId());
                System.debug(LoggingLevel.INFO, '*** result.getOpportunityId(): ' + result.getOpportunityId());
                List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];
                try {
                    Opportunity oppty = [Select Id, CurrencyIsoCode From Opportunity Where Id =: result.getOpportunityId()];
                    oppty.Primary_Contact__c = result.getContactId();
                    oppty.CampaignId = activity.Campaign__c;
                    update oppty;

                    if(activity.Product_Interest_Type__c != null && activity.Product_Interest_Type__c.containsIgnoreCase('Reserve') && activity.Reserved_Session__c != null) {
                        List<Product2> specificProdList = [Select Id, Programme__c, Product_Type__c, Name From Product2 Where Name =: activity.Reserved_Session__c];
                        if(specificProdList.size() > 0) {
                            productList = specificProdList;
                        }
                    }
                    transferActivities(theLead.Id, result.getContactId(), tmpActivity.Id);
                    createOpportunityLineItem(oppty, productList[0].Id, pricebookList);
                    tmpActivity.Contact__c = result.getContactId();
                    tmpActivity.Opportunity__c = result.getOpportunityId();
                    tmpActivity.Processed_by_Lead2Oppy__c = true;
                    tmpActivity.Lead__c = null;
                }catch(Exception ex) {
                    updateErrorMessage(tmpActivity, ex.getMessage());
                }
            }else {
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Verification_Error__c = Label.Conversion_Error;
            }
            update tmpActivity;
        }
    }

    public static Opportunity autoTagOpportunity2Contact(Activity__c activity, String contactId, Boolean isConverted) {

        Contact cont = [Select ACG_Interest_Adv_Certificate_in_Gov__c, 
                            CGM_Interest__c, 
                            OOC_Interest__c, 
                            FirstName, 
                            LastName, 
                            AccountId,
                            Account.Name,
                            Account.RecordType.DeveloperName 
                        From Contact Where Id =: contactId];

        Activity__c tmpActivity = new Activity__c(Id = activity.Id);
        
        List<Product2> productList = findProductByName(activity);
        if(productList.size() < 1) {
            updateErrorMessage(tmpActivity, Label.No_session_available);
            return null;
        }

        List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> openItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> closedItemList = new List<OpportunityLineItem>();
        if('Certificate' == activity.Programme_Family__c) {
            // String productName = activity.Program_Name__c;
            // String searchText = '%certificate%';
            // if('GC' == productName) productName = 'CGM';
            // if('OOC' == productName) productName = 'OCLTW';
            // if('ICD' == productName) productName = 'ACG';
            // System.debug(LoggingLevel.INFO, '*** searchText: ' + searchText);
            itemList = [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate, Product_Type__c From OpportunityLineItem Where Product2Id =: productList[0].Id And Product2.Product_Type__c = 'Certificate' And Opportunity.RecordType.DeveloperName = 'OEP_Certificate'];
        }else {
            itemList = [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate, Product_Type__c From OpportunityLineItem Where Product2Id =: productList[0].Id And Product2.Product_Type__c != 'Certificate' And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
        }
        System.debug(LoggingLevel.INFO, '*** itemList: ' + itemList);
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
        if(activity.Product_Interest_Type__c != null && activity.Product_Interest_Type__c.containsIgnoreCase('Reserve') && activity.Reserved_Session__c != null) {
            for(OpportunityLineItem item : [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate 
                                            From OpportunityLineItem 
                                            Where Product2.Name =: activity.Reserved_Session__c 
                                            And Product2.Product_Type__c != 'Certificate' 
                                            And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')]) {
                if(item.Opportunity.IsClosed && item.Opportunity.CloseDate > compareDate) {
                    closedItemList.add(item);
                    closedOpptyItemIdSet1.add(item.OpportunityId);
                }else {
                    openItemList.add(item);
                    openOpptyItemIdSet1.add(item.OpportunityId);
                } 
            }
        }
        

        List<OpportunityContactRole> contRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> openContRoleList = new List<OpportunityContactRole>();
        List<OpportunityContactRole> closedContRoleList = new List<OpportunityContactRole>();
        if('Certificate' == activity.Programme_Family__c) {
            contRoleList = [Select OpportunityId, ContactId, Opportunity.IsClosed, Opportunity.CloseDate From OpportunityContactRole Where ContactId =: contactId And Opportunity.RecordType.DeveloperName = 'OEP_Certificate'];
        }else {
            contRoleList = [Select OpportunityId, ContactId, Opportunity.IsClosed, Opportunity.CloseDate From OpportunityContactRole Where ContactId =: contactId And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
        }
        
        // List<OpportunityContactRole> closedOpptyList = [Select OpportunityId, ContactId From OpportunityContactRole Where ContactId =: contactId And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
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
        System.debug(LoggingLevel.INFO, '*** activity.Product_Interest_Type__c: ' + activity.Product_Interest_Type__c);
        List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name =: Label.Price_Book_Name];
        if(openOpptyItemIdSet1.size() > 0 || closedOpptyItemIdSet1.size() > 0) {
            if(openOpptyItemIdSet1.size() == 1 && activity.Product_Interest_Type__c != null && activity.Product_Interest_Type__c.containsIgnoreCase('Reserve')) {
                return replaceAndCreateSession(activity, productList, itemList, openOpptyItemIdSet1, pricebookList);
            }

            if(openOpptyItemIdSet1.size() != 1 && closedOpptyItemIdSet1.size() == 1 && activity.Product_Interest_Type__c != null && activity.Product_Interest_Type__c.containsIgnoreCase('Reserve')) {
                return replaceAndCreateSession(activity, productList, itemList, closedOpptyItemIdSet1, pricebookList);
            }

            if((openOpptyItemIdSet1.size() > 1 || closedOpptyItemIdSet1.size() > 1) && activity.Product_Interest_Type__c != null && !activity.Product_Interest_Type__c.containsIgnoreCase('Reserve')) {
                //update activity information
                updateErrorMessage(tmpActivity, Label.Open_opportunites_Error);
                return null;
            }

            if(activity.Product_Interest_Type__c != null && !activity.Product_Interest_Type__c.containsIgnoreCase('Reserve')) {
                List<String> opptyIdList = new List<String>(openOpptyItemIdSet1);
                System.debug(LoggingLevel.INFO, '*** opptyIdList: ' + opptyIdList);
                //update activity information
                // tmpActivity.Opportunity__c = opptyIdList[0];
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Opportunity__c = opptyIdList[0];
                update tmpActivity;
                Opportunity tmpOppty = new Opportunity(Id = opptyIdList[0]);
                if(isConverted) {
                    tmpOppty.Primary_Contact__c = contactId;
                    tmpOppty.ACG_Interest__c = cont.ACG_Interest_Adv_Certificate_in_Gov__c;
                    tmpOppty.CGM_Interest__c = cont.CGM_Interest__c;
                    tmpOppty.OOC_Interest__c = cont.OOC_Interest__c;
                }
                tmpOppty.CampaignId = activity.Campaign__c;
                update tmpOppty;
                return tmpOppty;
            }
        }else {
            //create opportunity and opportunity line item
            if(activity.Product_Interest_Type__c != null && activity.Product_Interest_Type__c.containsIgnoreCase('Reserve') && activity.Reserved_Session__c != null) {
                List<Product2> specificProdList = [Select Id, Programme__c, Product_Type__c, Name From Product2 Where Name =: activity.Reserved_Session__c];
                if(specificProdList.size() > 0) {
                    productList = specificProdList;
                }else {
                    updateErrorMessage(tmpActivity, Label.No_session_available);
                    return null;
                }
            }
            Map<String, String> opptyRTMap = InseadUtil.getObjectRecordType('Opportunity');
            String recordTypeId = 'Yes' == activity.Are_you_a_HR__c? opptyRTMap.get('OEP_Online') : opptyRTMap.get('OEP_F2F');
            if('Certificate' == activity.Programme_Family__c) {
                recordTypeId = opptyRTMap.get('OEP_Certificate');
            }
            System.debug(LoggingLevel.INFO, '*** recordTypeId: ' + recordTypeId);
            String pricebookId = pricebookList[0].Id;
            // List<Campaign> campaignList = [Select Id From Campaign Where Id =: activity.CRMCampaignId__c];
            try {
                String seesionName = productList[0].Name;
                Opportunity oppty = createOpportunity(cont, pricebookId, recordTypeId, activity.Campaign__c, true, seesionName);
                System.debug(LoggingLevel.INFO, '*** : ' + [Select Id, CurrencyIsoCode From Opportunity Where Id =: oppty.Id]);
                oppty = [Select Id, Name, CurrencyIsoCode, Pricebook2Id From Opportunity Where Id =: oppty.Id];
                createOpportunityLineItem(oppty, productList[0].Id, pricebookList);
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Opportunity__c = oppty.Id;
                tmpActivity.Processed_by_Lead2Oppy__c = true;
                tmpActivity.Contact__c = cont.Id;
                update tmpActivity;
                return oppty;
            }catch(Exception ex) {
                updateErrorMessage(tmpActivity, ex.getMessage());
                return null;
            }
            
        }
        System.debug(LoggingLevel.INFO, '*** productList: ' + productList);
        return null;
    }

    public static void transferActivities(String leadId, String contactId, String activityId) {
        List<Activity__c> activityList = new List<Activity__c>();
        for(Activity__c activity : [Select Id, Lead__c, Contact__c From Activity__c Where Id !=: activityId And Lead__c =: leadId]) {
            activity.Contact__c = contactId;
            activity.Lead__c = null;
            activityList.add(activity);
        }
        if(activityList.size() > 0) update activityList;
    }

    public static Activity__c updateErrorMessage(Activity__c activity, String message) {
        activity.Processed_by_Lead2Oppy__c = true;
        activity.Verification_Error__c = message;
        update activity;
        return null;
    }

    public static List<Product2> findProductByName(Activity__c activity) {
        String programmeFamily = activity.Programme_Family__c;
        String productName = activity.Program_Name__c;
        String searchText = '%generic%';
        if('Certificate' == programmeFamily) {
            searchText = '%certificate%';
            if('GC' == productName) productName = 'CGM';
            if('OOC' == productName) productName = 'OCLTW';
            if('ICD' == productName) productName = 'ACG';
        }
        System.debug(LoggingLevel.INFO, '*** searchText: ' + searchText);
        List<Product2> productList = [Select Id, Product_Type__c, Name From Product2 Where Programme__r.Name =: productName And Name LIKE: searchText];
        // if(productList.size() < 1) {
        //     productList = [Select Id, Name From Product2 Where Name =: productName];
        // }
        System.debug(LoggingLevel.INFO, '*** productList: ' + productList);
        return productList;
    }

    public static Opportunity replaceAndCreateSession(Activity__c activity, List<Product2> productList,List<OpportunityLineItem> itemList, Set<String> openOpptyItemIdSet, List<Pricebook2> pricebookList) {
        Activity__c tmpActivity = new Activity__c(Id = activity.Id);
        List<Product2> specificProdList = [Select Id, Programme__c, Product_Type__c, Name From Product2 Where Name =: activity.Reserved_Session__c];
        if(specificProdList.size() < 1) {
            updateErrorMessage(tmpActivity, Label.No_session_available);
            return null;
        }
        Product2 specificeProd = specificProdList[0];
        List<String> opptyIdList = new List<String>(openOpptyItemIdSet);

        List<OpportunityLineItem> specificItemList = [Select OpportunityId, Product2Id, Opportunity.IsClosed, Opportunity.CloseDate, Product_Type__c From OpportunityLineItem Where Product2Id =: specificeProd.Id And Product2.Product_Type__c != 'Certificate' And (Opportunity.RecordType.DeveloperName = 'OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online') And OpportunityId =: opptyIdList[0]];

        Opportunity tmpOppty = [Select Id, Name, CurrencyIsoCode, Pricebook2Id From Opportunity Where Id =: opptyIdList[0]];
        if(activity.Campaign__c != null) {
            tmpOppty.CampaignId = activity.Campaign__c;
            update tmpOppty;
        }
        List<OpportunityLineItem> removeList = new List<OpportunityLineItem>();
        //remove generic opportunity line item
        for(OpportunityLineItem item : itemList) {
            if(item.OpportunityId == opptyIdList[0] && item.Product2Id == productList[0].Id && productList[0].Product_Type__c == 'Generic') {
                removeList.add(item);
            }
            // if(item.OpportunityId == opptyIdList[0] && item.Product2Id == specificProdList[0].Id) {
            //     specificItemList.add(item);
            // }
        }
        if(removeList.size() > 0) delete removeList;
        //create opportunity line item with specific session from activity
        if(specificItemList.size() < 1) {
            createOpportunityLineItem(tmpOppty, specificProdList[0].Id, pricebookList);
        }
        tmpActivity.Processed_by_Lead2Oppy__c = true;
        // tmpActivity.Opportunity__c = tmpOppty.Id;
        update tmpActivity;
        return tmpOppty;
    }

    public static Opportunity createOpportunity(Contact cont, String pricebookId, String recordTypeId, String campaignId, Boolean isConverted, String sessionName) {
        System.debug(LoggingLevel.INFO, '*** recordTypeId: ' + recordTypeId);
        Opportunity oppty = new Opportunity();
        // oppty.Name = cont.FirstName + ' ' + cont.LastName + ' Opportunity';
        oppty.Name = sessionName;
        if(cont.account.RecordType.DeveloperName == 'Business_Organization') {
            oppty.Name += ' - ' + cont.Account.Name;
        }
        oppty.Name += ' - ' + cont.FirstName + ' ' + cont.LastName;
        oppty.AccountId = cont.AccountId;
        // oppty.Pricebook2Id = pricebookId;
        oppty.StageName = 'New';
        oppty.RecordTypeId = recordTypeId;
        oppty.CloseDate = System.today().addDays(30);
        oppty.CampaignId = campaignId;
        if(isConverted) {
            oppty.Primary_Contact__c = cont.Id;
            oppty.ACG_Interest__c = cont.ACG_Interest_Adv_Certificate_in_Gov__c;
            oppty.CGM_Interest__c = cont.CGM_Interest__c;
            oppty.OOC_Interest__c = cont.OOC_Interest__c;
        }
        System.debug(LoggingLevel.INFO, '*** oppty: ' + oppty);
        insert oppty;
        return oppty;
    }

    public static void createOpportunityLineItem(Opportunity oppty, String porductId, List<Pricebook2> pricebookList) {
        Decimal price = 0;
        List<PricebookEntry> entryList = [Select Id, UnitPrice, CurrencyIsoCode From PricebookEntry Where Product2Id =: porductId And Pricebook2Id =: pricebookList[0].Id AND CurrencyIsoCode =: oppty.CurrencyIsoCode];
        System.debug(LoggingLevel.INFO, '*** entryList: ' + entryList);
        OpportunityLineItem newItem = new OpportunityLineItem();
        newItem.OpportunityId = oppty.Id;
        newItem.Product2Id = porductId;
        newItem.Quantity = 1;
        if(entryList.size() > 0) {
            newItem.PricebookEntryId = entryList[0].Id;
            price = entryList[0].UnitPrice;
        }else {
            // Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
            // PricebookEntry standardPrice = new PricebookEntry(
            //     Pricebook2Id = stdPriceBook.Id, 
            //     Product2Id = porductId, 
            //     UnitPrice = 12000, 
            //     IsActive = true
            // );

            // insert standardPrice;

            System.debug(LoggingLevel.INFO, '*** custom price book entry: ' );
            PricebookEntry customPriceEntry = new PricebookEntry(
                Pricebook2Id = pricebookList[0].Id, 
                Product2Id = porductId, 
                UnitPrice = 12000, 
                IsActive = true
            );
            customPriceEntry.CurrencyIsoCode = oppty.CurrencyIsoCode;
            insert customPriceEntry;
            newItem.PricebookEntryId = customPriceEntry.Id;
            price = customPriceEntry.UnitPrice;
        }
        newItem.TotalPrice = newItem.Quantity * price;
        insert newItem;
    }

    // public static Activity__c tagActivity2Opportunity(String activityId, String opptyId) {
    //     Activity__c tmpActivity = new Activity__c(
    //         Id = activityId,
    //         Opportunity__c = opptyId
    //     );
    //     update tmpActivity;
    //     return tmpActivity;
    // }
}