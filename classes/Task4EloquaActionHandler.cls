/************************************************************************************
Class Name : Task4EloquaActionHandler
Version : 1.0 
Created Date : 07/26/2019
Function : 1, Tag activity to Contact if there's an new eloqua activity coming
           2, Auto convert lead if there's an new submit a form/reserve a seat/download a brochure
           3, Create an new opportunity for DP contact if there's an new submit a form/reserve a seat/download a brochure

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/26/2019               Version 1.0
*************************************************************************************/
public without sharing class Task4EloquaActionHandler implements Triggers.Handler {

    public void handle() {
        Map<String, String> rtMap = InseadUtil.getObjectRecordType('Task');
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> leadIdSet = new Set<String>();
        Set<String> eloquaIdSet = new Set<String>();
        if(Trigger.isBefore) {
            for(Task t : (List<Task>) Trigger.new) {
                System.debug(LoggingLevel.INFO, '*** txxxxxxxxxxx: ' + t);
                if(t.ActivityDate == null) t.ActivityDate = System.today().addDays(7);

                if(!t.Is_Eloqua_Task__c || String.isBlank(t.Email_Address__c)) continue;
                System.debug(LoggingLevel.INFO, '*** eloqua task: ' + t);
                t.WhoId = t.WhoId != null? t.WhoId : (t.SFDC_Contact_ID__c == null? (t.SFDC_Lead_ID__c == null? null : t.SFDC_Lead_ID__c) : t.SFDC_Contact_ID__c);
                System.debug(LoggingLevel.INFO, '*** t.WhoId: ' + t.WhoId);
                // t.Program_Type__c
                
                if(t.WhoId != null && t.WhoId.getSobjectType().getDescribe().getName() == 'Lead') {
                    leadIdSet.add(t.WhoId);
                }
                if(t.Program_Type__c != null && t.Program_Type__c.containsIgnoreCase('Application')) t.RecordTypeId = rtMap.get('Submit_a_form');
                if(t.Program_Type__c != null && t.Program_Type__c.containsIgnoreCase('Reserve')) t.RecordTypeId = rtMap.get('Reserve_a_seat');
                if(t.Program_Type__c != null && t.Program_Type__c.containsIgnoreCase('Brochure')) t.RecordTypeId = rtMap.get('Download_a_brochure');

                if(t.WhoId == null) {
                    if(t.First_Name__c != null) firstNameSet.add(t.First_Name__c);
                    lastNameSet.add(t.Last_Name__c);
                    if(t.Email_Address__c != null) emailSet.add(t.Email_Address__c);
                    if(t.Eloqua_Contact_ID__c != null) eloquaIdSet.add(t.Eloqua_Contact_ID__c);
                }

            }
            Map<String, Lead> convertedLeadMap = new Map<String, Lead>();
            for(Lead ld : [Select Id, ConvertedContactId From Lead Where Id IN: leadIdSet And IsConverted = true]) {
                convertedLeadMap.put(ld.Id, ld);
            }
            Map<String, String> recordMap = findMatchingRecord(firstNameSet, lastNameSet, emailSet, eloquaIdSet);
            System.debug(LoggingLevel.INFO, '*** recordMap: ' + recordMap);
            Set<String> companySet = new Set<String>();
            Set<String> countrySet = new Set<String>();
            Map<String, String> companyCountryMap = new Map<String, String>();
            List<Task> noWhoIdTaskList = new List<Task>();
            //update whoid if the lead was concerted
            for(Task t : (List<Task>)Trigger.new) {
                if(!t.Is_Eloqua_Task__c || String.isBlank(t.Email_Address__c)) continue;
                // String key = t.First_Name__c + t.Last_Name__c + t.Email_Address__c;
                String key = t.First_Name__c + t.Last_Name__c;
                key = t.Email_Address__c != null? key += t.Email_Address__c: key;
                key = t.Work_Email__c != null? key += t.Work_Email__c: key;
                key = t.Home_Email__c != null? key += t.Home_Email__c: key;
                if(convertedLeadMap.containsKey(t.WhoId)) {
                    t.WhoId = convertedLeadMap.get(t.WhoId).ConvertedContactId;
                }
                if(t.WhoId == null && recordMap.containsKey(key)) {
                    t.WhoId = recordMap.get(key);
                }
                if(t.WhoId == null) {
                    System.debug(LoggingLevel.INFO, '*** t.First_Name__c: ' + t.First_Name__c);
                    if(t.Company__c != null) companySet.add(t.Company__c);
                    countrySet.add(t.Work_Country__c);
                    if(t.Company__c != null) companyCountryMap.put(t.Company__c + ':' + t.Work_Country__c, t.Company__c + ':' + t.Work_Country__c);
                    noWhoIdTaskList.add(t);
                }

            }
            System.debug(LoggingLevel.INFO, '*** companySet: ' + companySet);
            System.debug(LoggingLevel.INFO, '*** countrySet: ' + countrySet);
            System.debug(LoggingLevel.INFO, '*** companyCountryMap: ' + companyCountryMap);
            //create new lead and build the relationship with Task
            System.debug(LoggingLevel.INFO, '*** noWhoIdTaskList: ' + noWhoIdTaskList);

            Map<String, Lead> newLeadMap = createLead(noWhoIdTaskList);
            Map<String, Contact> newContact = createContact(noWhoIdTaskList, companySet, countrySet, companyCountryMap);
            for(Task t : (List<Task>) Trigger.new) {
                if(!t.Is_Eloqua_Task__c || String.isBlank(t.Email_Address__c) || !String.isBlank(t.WhoId)) continue;

                String key = t.First_Name__c + t.Last_Name__c;
                key = t.Email_Address__c != null? key += t.Email_Address__c: key;
                key = t.Work_Email__c != null? key += t.Work_Email__c: key;
                key = t.Home_Email__c != null? key += t.Home_Email__c: key;

                System.debug(LoggingLevel.INFO, '*** newkey: ' + key);
                if(newContact.containsKey(key)) {
                    t.WhoId = newContact.get(key).Id;
                }
                if(String.isBlank(t.WhoId) && newLeadMap.containsKey(key)) {
                    t.WhoId = newLeadMap.get(key).Id;
                }
            }

            /***
            for(Task t : (List<Task>) Trigger.new) {

                if(!t.Is_Eloqua_Task__c || String.isBlank(t.Email_Address__c)) continue;

                if(t.Program_Type__c != null && (t.Program_Type__c.containsIgnoreCase('Application') || t.Program_Type__c.containsIgnoreCase('Reserve') || t.Program_Type__c.containsIgnoreCase('Brochure'))) {
                    if(t.WhoId != null && t.WhoId.getSobjectType().getDescribe().getName() == 'Contact') {
                        autoTagOpportunity2Contact(t.WhoId, t.Program_Name__c);
                    }
                    if(t.WhoId != null && t.WhoId.getSobjectType().getDescribe().getName() == 'Lead') {
                        System.debug(LoggingLevel.INFO, '*** t.WhoId: ' + t.WhoId);
                        AutoConvertLeads.autoConvert(t.WhoId);
                    }
                }
            }
            ***/
        }
        /***
        if(Trigger.isAfter) {
            System.debug(LoggingLevel.INFO, '*** after trigger: ');
            for(Task t : (List<Task>) Trigger.new) {

                if(!t.Is_Eloqua_Task__c || String.isBlank(t.Email_Address__c)) continue;

                if(t.Program_Type__c != null && (t.Program_Type__c.containsIgnoreCase('Application') || t.Program_Type__c.containsIgnoreCase('Reserve') || t.Program_Type__c.containsIgnoreCase('Brochure'))) {
                    if(t.WhoId != null && t.WhoId.getSobjectType().getDescribe().getName() == 'Contact') {
                        autoTagOpportunity2Contact(t.WhoId, t.Program_Name__c, t.Id);
                    }
                    if(t.WhoId != null && t.WhoId.getSobjectType().getDescribe().getName() == 'Lead') {
                        System.debug(LoggingLevel.INFO, '*** t.WhoId: ' + t.WhoId);
                        // AutoConvertLeads.autoConvert(t.WhoId);
                    }
                }
            }
        }
        ***/
    }

    public static Map<String, Id> findMatchingRecord(Set<String> firstNameSet, Set<String> lastNameSet, Set<String> emailSet, Set<String> eloquaIdSet) {
        //key: firstName + lastName + email
        Map<String, Id> recordMap = new Map<String, Id>();
        // for(Contact con : [Select Id, FirstName, LastName, Email From Contact Where Data_Source__c = 'Eloqua' And FirstName IN: firstNameSet And LastName IN: lastNameSet And Email IN: emailSet]) {
        //     String key = con.FirstName + con.LastName + con.Email;
        //     if(recordMap.containsKey(key)) continue;
        //     recordMap.put(key, con.Id);
        // }
        List<Contact> contactList = new List<Contact>();
        System.debug(LoggingLevel.INFO, '*** eloquaIdSet: ' + eloquaIdSet);
        if(eloquaIdSet.size() > 0) {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Eloqua_Contact_ID__c, hed__AlternateEmail__c, Home_Email__c, hed__WorkEmail__c, hed__Preferred_Email__c
                                FROM Contact
                                WHERE Eloqua_Contact_ID__c IN: eloquaIdSet
                                OR (FirstName IN: firstNameSet 
                                    AND LastName IN: lastNameSet 
                                    AND (Email IN: emailSet OR hed__AlternateEmail__c IN: emailSet 
                                        OR Home_Email__c IN: emailSet OR hed__Preferred_Email__c IN: emailSet
                                        OR hed__WorkEmail__c IN: emailSet))];
        }else {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Eloqua_Contact_ID__c, hed__AlternateEmail__c, Home_Email__c, hed__WorkEmail__c, hed__Preferred_Email__c
                            FROM Contact
                            WHERE FirstName IN: firstNameSet 
                                AND LastName IN: lastNameSet 
                                AND (Email IN: emailSet OR hed__AlternateEmail__c IN: emailSet 
                                    OR Home_Email__c IN: emailSet OR hed__Preferred_Email__c IN: emailSet
                                    OR hed__WorkEmail__c IN: emailSet)];
        }

        for(Contact cont : contactList) {
            if(cont.Eloqua_Contact_ID__c != null) recordMap.put(cont.Eloqua_Contact_ID__c, cont.Id);
            String key = cont.FirstName + cont.LastName;
            key = cont.Email != null? key += cont.Email: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__AlternateEmail__c != null? key += cont.hed__AlternateEmail__c: key;
            recordMap.put(key, cont.Id);
            key = cont.Home_Email__c != null? key += cont.Home_Email__c: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__Preferred_Email__c != null? key += cont.hed__Preferred_Email__c: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__WorkEmail__c != null? key += cont.hed__WorkEmail__c: key;
            recordMap.put(key, cont.Id);
        }
        List<Lead> leadList = new List<Lead>();
        if(eloquaIdSet.size() > 0) {
            leadList = [SELECT Id, FirstName, LastName, Email, Eloqua_Contact_ID__c, Home_Email__c, Work_Email__c, ConvertedContactId 
                                            FROM Lead
                                            WHERE Eloqua_Contact_ID__c IN: eloquaIdSet
                                            OR (FirstName IN: firstNameSet 
                                                AND LastName IN: lastNameSet 
                                                AND (Email IN: emailSet 
                                                    OR Home_Email__c IN: emailSet 
                                                    OR Work_Email__c IN: emailSet))];
        }else {
            leadList = [SELECT Id, FirstName, LastName, Email, Eloqua_Contact_ID__c, Home_Email__c, Work_Email__c, ConvertedContactId 
                                            FROM Lead
                                            WHERE FirstName IN: firstNameSet 
                                                AND LastName IN: lastNameSet 
                                                AND (Email IN: emailSet 
                                                    OR Home_Email__c IN: emailSet
                                                    OR Work_Email__c IN: emailSet)];
        }
        for(lead lead : leadList) {

            String recordId = String.isBlank(lead.ConvertedContactId)? lead.Id : lead.ConvertedContactId;

            if(lead.Eloqua_Contact_ID__c != null && !recordMap.containsKey(lead.Eloqua_Contact_ID__c)) recordMap.put(lead.Eloqua_Contact_ID__c, recordId);
            
            String key = lead.FirstName + lead.LastName;
            key = lead.Email != null? key += lead.Email: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            key = lead.Home_Email__c != null? key += lead.Home_Email__c: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            key = lead.Work_Email__c != null? key += lead.Work_Email__c: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            
        }
        return recordMap;
    }

    public static Map<String, Lead> createLead(List<Task> taskList) {
        Map<String, Lead> leadMap = new Map<String, Lead>();
        for(Task t : taskList) {
            if(t.Eloqua_Lead_Type__c != 'OEP') continue;
            System.debug(LoggingLevel.INFO, '*** t.Company__c: ' + t.Company__c);
            System.debug(LoggingLevel.INFO, '*** t.Last_Name__c: ' + t.Last_Name__c);
            Lead newLead = new Lead();
            newLead.Company = t.Company__c;
            newLead.LastName = t.Last_Name__c;
            newLead.FirstName = t.First_Name__c;
            newLead.Email = t.Email_Address__c;
            newLead.GA_Campaign__c = t.GA_Campaign__c;
            newLead.GA_Keywords__c = t.GA_Keywords__c;
            newLead.GA_Medium__c = t.GA_Medium__c;
            newLead.GA_Source__c = t.GA_Source__c;
            newLead.GA_Ad_Content__c = t.GA_Ad_Content__c;
            newLead.Havas_Site_Id__c = t.Havas_Site_Id__c;
            newLead.Havas_u4__c = t.Havas_u4__c;
            newLead.Havas_Cat__c = t.Havas_Cat__c;
            newLead.Havas_Type__c = t.Havas_Type__c;
            newLead.Havas_u3__c = t.Havas_u3__c;
            newLead.Havas_u6__c = t.Havas_u6__c;
            newLead.City = t.City__c;
            newlead.Country = t.Work_Country__c;
            newLead.MobilePhone = t.Mobile__c;
            newLead.Title = t.Title__c;
            newLead.EDP_Marketing_Score__c = t.EDP_Marketing_Score__c;
            newLead.Date_of_Birth__c = t.Date_of_Birth__c;
            newLead.Origin_of_Data_Source__c = t.Origin_Of_Data_Source__c;
            newLead.Years_of_Work_Experience__c = t.Work_Experience__c;
            newLead.Eloqua_Lead_Type__c = t.Eloqua_Lead_Type__c;
            newLead.Program_Name__c = t.Program_Name__c;
            newLead.Program_Type__c = t.Program_Type__c;
            newLead.Product_Interest_Type__c = t.Product_Interest_Type__c;
            newLead.Home_Email__c = t.Home_Email__c;
            newLead.Work_Email__c = t.Work_Email__c;
            newLead.Data_Source__c = 'Eloqua';

            String key = t.First_Name__c + t.Last_Name__c;
            key = t.Email_Address__c != null? key += t.Email_Address__c: key;
            key = t.Work_Email__c != null? key += t.Work_Email__c: key;
            key = t.Home_Email__c != null? key += t.Home_Email__c: key;

            leadMap.put(t.First_Name__c + t.Last_Name__c + t.Email_Address__c, newLead);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        if(leadMap.size() > 0) Database.insert(leadMap.values(), dml); 
        // if(leadMap.size() > 0) insert leadMap.values();
        System.debug(LoggingLevel.INFO, '*** new leadMap: ' + leadMap);
        return leadMap;
    }

    public static Map<String, Contact> createContact(List<Task> taskList, Set<String> companySet, Set<String> countrySet, Map<String, String> companyCountryMap) {

        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account acct : [Select Id, Name, BillingCountry From Account Where Name IN:companySet And BillingCountry IN: countrySet]) {
            accountMap.put(acct.Name + ':' + acct.BillingCountry, acct);
        }
        System.debug(LoggingLevel.INFO, '*** accountMap: ' + accountMap);
        Set<String> tmpSet1 = companyCountryMap.keySet();
        Set<String> tmpSet2 = accountMap.keySet();
        System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + tmpSet1);
        System.debug(LoggingLevel.INFO, '*** tmpSet2: ' + tmpSet2);
        tmpSet1.removeAll(tmpSet2);
        System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + tmpSet1);
        Map<String, String> acctRTMap = new Map<String, String>();
        if(tmpSet1.size() > 0) {
            acctRTMap = InseadUtil.getObjectRecordType('Account');
        }
        Map<String, Account> newAcctMap = new Map<String, Account>();
        for(String s : tmpSet1) {
            System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + s);
            String company = s.split(':')[0], country = s.split(':')[1];
            Account acct = new Account();
            acct.Name = company;
            if(!String.isBlank(country) && country != 'null') acct.BillingCountry = country;
            acct.RecordTypeId = acctRTMap.get('Business_Organization');
            newAcctMap.put(s, acct);
        }
        System.debug(LoggingLevel.INFO, '*** newAcctMap: ' + newAcctMap);
        if(newAcctMap.size() > 0) insert newAcctMap.values();

        Map<String, Contact> contactMap = new Map<String, Contact>();
        for(Task t : taskList) {
            if('OEP' == t.Eloqua_Lead_Type__c) continue;
            System.debug(LoggingLevel.INFO, '*** t.Company__c: ' + t.Company__c);
            System.debug(LoggingLevel.INFO, '*** t.Last_Name__c: ' + t.Last_Name__c);
            Contact newContact = new Contact();
            if(t.Company__c != null && accountMap.containsKey(t.Company__c + ':' + t.Work_Country__c)) {
                newContact.AccountId = accountMap.get(t.Company__c + ':' + t.Work_Country__c).Id;
            }else if(t.Company__c != null && newAcctMap.containsKey(t.Company__c + ':' + t.Work_Country__c)) {
                newContact.AccountId = newAcctMap.get(t.Company__c + ':' + t.Work_Country__c).Id;
            }

            newContact.Company__c = t.Company__c;
            newContact.LastName = t.Last_Name__c;
            newContact.FirstName = t.First_Name__c;
            newContact.Email = t.Email_Address__c;
            newContact.GA_Campaign__c = t.GA_Campaign__c;
            newContact.GA_Keywords__c = t.GA_Keywords__c;
            newContact.GA_Medium__c = t.GA_Medium__c;
            newContact.GA_Source__c = t.GA_Source__c;
            newContact.GA_Ad_Content__c = t.GA_Ad_Content__c;
            newContact.Havas_Site_Id__c = t.Havas_Site_Id__c;
            newContact.Havas_u4__c = t.Havas_u4__c;
            newContact.Havas_Cat__c = t.Havas_Cat__c;
            newContact.Havas_Type__c = t.Havas_Type__c;
            newContact.Havas_u3__c = t.Havas_u3__c;
            newContact.Havas_u6__c = t.Havas_u6__c;
            newContact.MailingCity = t.City__c;
            newContact.MailingCountry = t.Work_Country__c;
            newContact.MobilePhone = t.Mobile__c;
            newContact.Title = t.Title__c;
            newContact.EDP_Marketing_Score__c = t.EDP_Marketing_Score__c;
            // newContact.Date_of_Birth__c = t.Date_of_Birth__c;
            newContact.Origin_of_Data_Source__c = t.Origin_Of_Data_Source__c;
            newContact.Years_of_work_experience__c = t.Work_Experience__c;
            newContact.Eloqua_Lead_Type__c = t.Eloqua_Lead_Type__c;
            newContact.Program_Name__c = t.Program_Name__c;
            newContact.Program_Type__c = t.Program_Type__c;
            newContact.Product_Interest_Type_1__c = t.Product_Interest_Type__c;
            newContact.Data_Source__c = 'Eloqua';
            newContact.Home_Email__c = t.Home_Email__c;
            newContact.hed__WorkEmail__c = t.Work_Email__c;

            String key = t.First_Name__c + t.Last_Name__c;
            key = t.Email_Address__c != null? key += t.Email_Address__c: key;
            key = t.Work_Email__c != null? key += t.Work_Email__c: key;
            key = t.Home_Email__c != null? key += t.Home_Email__c: key;

            contactMap.put(t.First_Name__c + t.Last_Name__c + t.Email_Address__c, newContact);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        if(contactMap.size() > 0) Database.insert(contactMap.values(), dml); 
        // if(contactMap.size() > 0) insert contactMap.values();
        System.debug(LoggingLevel.INFO, '*** new contactMap: ' + contactMap);
        return contactMap;
    }

    //create a new opportunity and tag to contact
    @future
    public static void autoTagOpportunity2Contact(String contId, String productName, STring taskId) {

        System.debug(LoggingLevel.INFO, '*** taskId: ' + taskId);
        Contact cont = [Select FirstName, LastName, AccountId From Contact Where Id =:contId];
        Set<String> oliOppIdSet = new Set<String>();
        List<OpportunityContactRole> ocrList = [Select OpportunityId, ContactId From OpportunityContactRole Where ContactId =: contId];
        Map<String, String> ocrMap = new Map<String, String>();
        Set<String> ocrOppIdSet = new Set<String>();
        for(OpportunityContactRole ocr : ocrList) {
            ocrMap.put(ocr.OpportunityId, ocr.ContactId);
            ocrOppIdSet.add(ocr.OpportunityId);
        }
        System.debug(LoggingLevel.INFO, '*** ocrMap: ' + ocrMap);
        //find opportunities from opportunity product according product name
        List<OpportunityLineItem> itemList = [Select OpportunityId, Product2Id From OpportunityLineItem Where Product2.Name =: productName];
        System.debug(LoggingLevel.INFO, '*** itemList: ' + itemList);
        // Set<String> oliOppIdSet = new Set<String>();
        for(OpportunityLineItem item : itemList) {
            oliOppIdSet.add(item.OpportunityId);
        }
        ocrOppIdSet.retainAll(oliOppIdSet);

        if(ocrOppIdSet.size() > 0) {
            List<String> tmpList = new List<String>();
            tmpList.addAll(ocrOppIdSet);
            tagTask2Opportunity(taskId, tmpList[0]);
            return;
        }

        
        List<Pricebook2> pricebookList = [Select Id, Name, CurrencyIsoCode From Pricebook2 Where Name = '2019-2020 Price Book'];
        // System.debug(LoggingLevel.INFO, '*** pricebookList: ' + pricebookList);
        System.debug(LoggingLevel.INFO, '*** pricebookList: ' + pricebookList);
        if(pricebookList.size() < 1) return;

        Map<String, String> opptyRTMap = InseadUtil.getObjectRecordType('Opportunity');
        Opportunity oppty = new Opportunity();
        oppty.Name = cont.FirstName + ' ' + cont.LastName + ' Opportunity';
        oppty.AccountId = cont.AccountId;
        oppty.Pricebook2Id = pricebookList[0].Id;
        oppty.StageName = 'New';
        oppty.RecordTypeId = opptyRTMap.get('OEP_Online');
        oppty.CloseDate = System.today().addDays(30);
        insert oppty;

        tagTask2Opportunity(taskId, oppty.Id);
        

        System.debug(LoggingLevel.INFO, '*** : ' + [Select Id, CurrencyIsoCode From Opportunity Where Id =: oppty.Id]);
        oppty = [Select Id, Name, CurrencyIsoCode, Pricebook2Id From Opportunity Where Id =: oppty.Id];
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = contId;
        insert ocr;

        List<Product2> productList = [Select Id From Product2 Where Name =: productName];
        System.debug(LoggingLevel.INFO, '*** productList: ' + productList);
        if(productList.size() > 0) {
            Decimal price = 0;
            List<PricebookEntry> entryList = [Select Id, UnitPrice, CurrencyIsoCode From PricebookEntry Where Product2Id =: productList[0].Id And Pricebook2Id =: pricebookList[0].Id AND CurrencyIsoCode =: oppty.CurrencyIsoCode];
            System.debug(LoggingLevel.INFO, '*** entryList: ' + entryList);
            OpportunityLineItem newItem = new OpportunityLineItem();
            newItem.OpportunityId = oppty.Id;
            newItem.Product2Id = productList[0].Id;
            newItem.Quantity = 1;
            if(entryList.size() > 0) {
                newItem.PricebookEntryId = entryList[0].Id;
                price = entryList[0].UnitPrice;
            }else {
                Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
                PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = stdPriceBook.Id, 
                    Product2Id = productList[0].Id, 
                    UnitPrice = 12000, 
                    IsActive = true
                );

                insert standardPrice;

                System.debug(LoggingLevel.INFO, '*** custom price book entry: ' );
                PricebookEntry customPriceEntry = new PricebookEntry(
                    Pricebook2Id = pricebookList[0].Id, 
                    Product2Id = productList[0].Id, 
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
    }

    public static Task tagTask2Opportunity(String taskId, String opptyId) {
        Task updateTask = new Task(
            Id = taskId,
            WhatId = opptyId
        );
        update updateTask;
        return updateTask;
    }
}