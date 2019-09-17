global class AutoConvertLeads {
    /***
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds) {
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(Id leadId: LeadIds) {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(leadId);                
            Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
            //Remove this line if you want to create an opportunity from Lead Conversion 
            Leadconvert.setDoNotCreateOpportunity(TRUE); 
            MassLeadconvert.add(Leadconvert);
        }
        
        if(!MassLeadconvert.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
        }
    }

    //@future
    public static void autoConvert(List<Id> LeadIds) {
        System.debug(LoggingLevel.INFO, '*** LeadIds: ' + LeadIds);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(Id leadId: LeadIds){
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(leadId);
            Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
            //Remove this line if you want to create an opportunity from Lead Conversion 
            //Leadconvert.setDoNotCreateOpportunity(TRUE); 
            MassLeadconvert.add(Leadconvert);
        }
        System.debug(LoggingLevel.INFO, '*** MassLeadconvert: ' + MassLeadconvert);
        if(!MassLeadconvert.isEmpty()){
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
        }
    }
    ***/
    @future
    public static void autoConvert(ID leadId, ID activityId, String reservedSession, String activityType, String productName) {

        Activity__c updatedActivity = new Activity__c(
            Id = activityId
        );

        Map<String, String> acctRTMap = InseadUtil.getObjectRecordType('Account');
        Lead theLead = [Select Id, FirstName, LastName, Email, Company, Country, Eloqua_Contact_ID__c, Program_Name__c, OwnerId, EDP_Marketing_Score__c From Lead Where Id =:leadId];
        if(activityType.containsIgnoreCase('Brochure') && ('B4' < theLead.EDP_Marketing_Score__c)) {
            return;
        }
        if(!((String)theLead.OwnerId).startsWith('005')) {
            theLead.OwnerId = UserInfo.getUserId();
            update theLead;
        }
        String firstName = theLead.FirstName, lastName = theLead.LastName, email = theLead.Email, eloquaContactId = theLead.Eloqua_Contact_ID__c;
        String company = theLead.Company, country = theLead.Country;
        System.debug(LoggingLevel.INFO, '*** leadId: ' + leadId);
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
        
        if(contactList != null && contactList.size() > 1) return;

        System.debug(LoggingLevel.INFO, '*** contactList: ' + contactList);
        Set<String> contIDSet = new Set<String>();
        Map<String, String> conAccMap = new Map<String, String>();
        for(Contact c : contactList) {
            contIDSet.add(c.Id);
            conAccMap.put(c.Id, c.AccountId);
        }
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        // List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        Set<String> oliOppIdSet = new Set<String>();
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(leadId);

        List<Product2> productList = new List<Product2>();
        String searchText = '%generic%';
        List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
        if(String.isBlank(reservedSession)) {
            productList = [Select Id From Product2 Where Programme__r.Name =: productName And Name LIKE: searchText];
            itemList = [Select OpportunityId, Product2Id From OpportunityLineItem Where Product2.Name LIKE: searchText AND Product2.Programme__r.Name =: productName];
        }else {
            productList = [Select Id From Product2 Where Name =: reservedSession];
            itemList = [Select OpportunityId, Product2Id From OpportunityLineItem Where Product2.Name =: reservedSession];
        }
        System.debug(LoggingLevel.INFO, '*** productList: ' + productList);
        System.debug(LoggingLevel.INFO, '*** itemList: ' + itemList);

        if(contactList.size() > 0) {
            //find opportunities from opportunity contact role according contact
            List<OpportunityContactRole> ocrList = [Select OpportunityId, ContactId From OpportunityContactRole Where ContactId IN: contIDSet];
            Map<String, String> ocrMap = new Map<String, String>();
            Set<String> ocrOppIdSet = new Set<String>();
            for(OpportunityContactRole ocr : ocrList) {
                ocrMap.put(ocr.OpportunityId, ocr.ContactId);
                ocrOppIdSet.add(ocr.OpportunityId);
            }
            System.debug(LoggingLevel.INFO, '*** ocrMap: ' + ocrMap);
            //find opportunities from opportunity product according product name
     
            
            // Set<String> oliOppIdSet = new Set<String>();
            for(OpportunityLineItem item : itemList) {
                oliOppIdSet.add(item.OpportunityId);
            }
            ocrOppIdSet.retainAll(oliOppIdSet);
            System.debug(LoggingLevel.INFO, '*** ocrOppIdSet: ' + ocrOppIdSet);
            if(ocrOppIdSet.size() > 0) {
                List<String> tmpList = new List<String>(ocrOppIdSet);
                Leadconvert.setContactId(ocrMap.get(tmpList[0]));
                Leadconvert.setOpportunityId(tmpList[0]);
                Leadconvert.setAccountId(conAccMap.get(Leadconvert.getContactId()));
            }else {
                Leadconvert.setContactId(contactList[0].Id);
                Leadconvert.setAccountId(conAccMap.get(contactList[0].Id));
            }
        }else {
            // if(String.isBlank(company)) company = firstName + lastName + 'Administrative Account';
            
            List<Account> acctList = [Select Id From Account Where Name =: company And BillingCountry =: country];
            System.debug(LoggingLevel.INFO, '*** acctList: ' + acctList);
            System.debug(LoggingLevel.INFO, '*** company: ' + company);
            System.debug(LoggingLevel.INFO, '*** country: ' + country);
            if(acctList.size() > 0) {
                Leadconvert.setAccountId(acctList[0].Id);
            }else {
                Account newAcct = new Account(Name = company);
                if(company.endsWithIgnoreCase('Administrative Account')) {
                    newAcct.RecordTypeId = acctRTMap.get('Administrative');
                }else {
                    newAcct.RecordTypeId = acctRTMap.get('Business_Organization');
                }
                insert newAcct;
                Leadconvert.setAccountId(newAcct.Id);
            }
        }
        if(Leadconvert.getOpportunityId() == null) {
            System.debug(LoggingLevel.INFO, '*** new opp: ');
            Leadconvert.setOpportunityName(firstName + ' ' + lastName + '  Opportunity');
        }else {
            System.debug(LoggingLevel.INFO, '*** exist opp: ' );
        }
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        //Remove this line if you want to create an opportunity from Lead Conversion 
        //Leadconvert.setDoNotCreateOpportunity(TRUE); 
        // MassLeadconvert.add(Leadconvert);
        // System.debug(LoggingLevel.INFO, '*** MassLeadconvert: ' + MassLeadconvert);
        Database.LeadConvertResult result = Database.convertLead(Leadconvert);
        System.debug(LoggingLevel.INFO, '*** result: ' + result);
        if(result.isSuccess()) {
            System.debug(LoggingLevel.INFO, '*** result.getContactId(): ' + result.getContactId());
            System.debug(LoggingLevel.INFO, '*** result.getOpportunityId(): ' + result.getOpportunityId());
            System.debug(LoggingLevel.INFO, '*** opp Id : ' + oliOppIdSet.contains(result.getOpportunityId()));
            System.debug(LoggingLevel.INFO, '*** oliOppIdSet: ' + oliOppIdSet);
            if(!oliOppIdSet.contains(result.getOpportunityId())) {
                addOpportunityLineItem(result.getOpportunityId(), productList);
            }
            updatedActivity.Contact__c = result.getContactId();
            updatedActivity.Opportunity__c = result.getOpportunityId();
            updatedActivity.Lead__c = null;
        }

        update updatedActivity;

    }

    public static void addOpportunityLineItem(String oppId, List<Product2> productList) {
        System.debug(LoggingLevel.INFO, '*** productList: ' + productList);
        List<Pricebook2> pricebookList = [Select Id, Name From Pricebook2 Where Name = '2019-2020 Price Book'];
        Opportunity opp = new Opportunity(
            Id = oppId,
            Pricebook2Id = pricebookList[0].Id
        );
        update opp;
        opp = [Select Id, Name, CurrencyIsoCode, Pricebook2Id From Opportunity Where Id =: opp.Id];
        // List<Product2> productList = [Select Id From Product2 Where Name =: productName];
        if(productList.size() > 0) {
            Decimal price = 0;
            List<PricebookEntry> entryList = [Select Id, UnitPrice From PricebookEntry Where Product2Id =: productList[0].Id And Pricebook2Id =: pricebookList[0].Id AND CurrencyIsoCode =: opp.CurrencyIsoCode];
            OpportunityLineItem newItem = new OpportunityLineItem();
            newItem.OpportunityId = oppId;
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
                customPriceEntry.CurrencyIsoCode = opp.CurrencyIsoCode;
                insert customPriceEntry;
                newItem.PricebookEntryId = customPriceEntry.Id;
                price = customPriceEntry.UnitPrice;
            }
            newItem.TotalPrice = newItem.Quantity * price;
            insert newItem;
        }
    }
}