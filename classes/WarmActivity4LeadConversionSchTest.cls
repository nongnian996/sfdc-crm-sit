@isTest
private class WarmActivity4LeadConversionSchTest {
    static testMethod void testMethod1() {
        //create campaign
        Campaign camp = new Campaign();
        camp.Name = 'test campaign';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().addDays(15);
        insert camp;
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'AAP';
        insert prod;
        
        //create custom price book
      	Pricebook2 book2 = new Pricebook2();
     	book2.Name = System.Label.Price_Book_Name;
      	book2.IsActive = true;
      	insert book2;
        
        PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod.Id;
     	entry.Pricebook2Id = Test.getStandardPricebookId();
     	entry.UnitPrice = 1200;
     	entry.IsActive = true;
     	insert entry;
        
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.Program_Name__c = 'AAP';
        leads.Eloqua_Contact_ID__c = 'testeloquacontactid';
        leads.Country = 'China';
        insert leads;
        
        //create sales activity
        Activity__c act = new Activity__c();
        act.Lead__c = leads.Id;
        act.Product_Interest_Type__c = 'Brochure';
        act.Program_Type__c = 'test 1';
        act.Qualifier_for_Opportunity__c = true;
        act.Processed_by_Lead2Oppy__c = false;
        act.Lead_Type__c = 'OEP';
        act.Rating__c = 'Warm';
        act.Program_Name__c = 'AAP';
        insert act;
        
        Activity__c act2 = new Activity__c();
        act2.Lead__c = leads.Id;
        act2.Product_Interest_Type__c = 'Brochure';
        act2.Program_Type__c = 'test 11';
        act2.Lead_Status__c = 'Qualifying';
        act2.Processed_by_Lead2Oppy__c = false;
        act2.Lead_Type__c = 'OEP';
        act2.Rating__c = 'Warm';
        act2.EDP_Marketing_Score__c = 'B2';
        act2.Program_Name__c = 'AAP';
        act.Campaign__c = camp.Id;
        insert act2;

        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
     static testMethod void testMethod2() {
        //create campaign
        Campaign camp = new Campaign();
        camp.Name = 'test campaign';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().addDays(15);
        insert camp;
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'AAP';
        insert prod;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'AAP generic';
        prod2.Programme__c = prod.Id;
        insert prod2;
         
        //create cont
        Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'contacts';
        cont.Email = '1234567@test.com';
        cont.Eloqua_Contact_ID__c = 'testeloquacontactid';
        insert cont;
         
        //create custom price book
    	Pricebook2 book2 = new Pricebook2();
    	book2.Name = System.Label.Price_Book_Name;
    	book2.IsActive = true;
    	insert book2;

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod2.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = prod2.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;
         
        //create opportunity
    	Opportunity oppty = new Opportunity();
    	oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today().addDays(5);
    	oppty.Pricebook2Id = book2.Id;
        oppty.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_F2F'].Id;
    	insert oppty;
         
        //create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = prod2.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
    	insert lineitem;
         
        //create contact role
    	OpportunityContactRole role = new OpportunityContactRole();
    	role.OpportunityId = oppty.Id;
    	role.ContactId = cont.Id;
    	insert role;
        
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.Program_Name__c = 'AAP';
        leads.Eloqua_Contact_ID__c = 'testeloquacontactid';
        leads.Country = 'China';
        insert leads;
        
        //create sales activity
        Activity__c act = new Activity__c();
        act.Lead__c = leads.Id;
        act.Product_Interest_Type__c = 'Brochure';
        act.Program_Type__c = 'test 1';
        act.Qualifier_for_Opportunity__c = true;
        act.Processed_by_Lead2Oppy__c = false;
        act.Lead_Type__c = 'OEP';
        act.Rating__c = 'Warm';
        act.Program_Name__c = 'AAP';
        act.Campaign__c = camp.Id;
        insert act;

        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
    static testMethod void testMethod3() {
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'AAP';
        insert prod;
        
        //create custom price book
      	Pricebook2 book2 = new Pricebook2();
     	book2.Name = System.Label.Price_Book_Name;
      	book2.IsActive = true;
      	insert book2;
        
        PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod.Id;
     	entry.Pricebook2Id = Test.getStandardPricebookId();
     	entry.UnitPrice = 1200;
     	entry.IsActive = true;
     	insert entry;
        //create cont
        Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'leads';
        cont.Email = '1234567@test.com';
        insert cont;
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.Program_Name__c = 'AAP';
        leads.Country = 'China';
        insert leads;
        
        //create sales activity
        Activity__c act = new Activity__c();
        act.Lead__c = leads.Id;
        act.Product_Interest_Type__c = 'Brochure';
        act.Program_Type__c = 'test 1';
        act.Qualifier_for_Opportunity__c = true;
        act.Processed_by_Lead2Oppy__c = false;
        act.Lead_Type__c = 'OEP';
        act.Rating__c = 'Warm';
        act.Program_Name__c = 'AAP';
        insert act;
        
        Activity__c act2 = new Activity__c();
        act2.Lead__c = leads.Id;
        act2.Product_Interest_Type__c = 'Brochure';
        act2.Program_Type__c = 'test 11';
        act2.Lead_Status__c = 'Qualifying';
        act2.Processed_by_Lead2Oppy__c = false;
        act2.Lead_Type__c = 'OEP';
        act2.Rating__c = 'Warm';
        act2.EDP_Marketing_Score__c = 'B2';
        act2.Program_Name__c = 'AAP';
        insert act2;

        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
    static testMethod void testMethod4() {
        //create campaign
        Campaign camp = new Campaign();
        camp.Name = 'test campaign';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().addDays(15);
        insert camp;
        
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'MMP';
        insert prod;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'MMP generic';
        prod2.Programme__c = prod.Id;
        insert prod2;
        
        //create custom price book
        Pricebook2 book2 = new Pricebook2();
        book2.Name = System.Label.Price_Book_Name;
        book2.IsActive = true;
        insert book2;
        
        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = prod2.Id;
        entry.Pricebook2Id = Test.getStandardPricebookId();
        entry.UnitPrice = 1200;
        entry.IsActive = true;
        insert entry;
        
        PricebookEntry entry1 = new PricebookEntry();
        entry1.Product2Id = prod2.Id;
        entry1.Pricebook2Id = book2.Id;
        entry1.UnitPrice = 1200;
        entry1.IsActive = true;
        insert entry1;
         
        //create opportunity
        Opportunity oppty = new Opportunity();
        oppty.Name = 'test Opportunity';
        oppty.StageName = 'New';
        Oppty.CloseDate = Date.today().addDays(5);
        oppty.Pricebook2Id = book2.Id;
        oppty.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_F2F'].Id;
        insert oppty;
         
        //create opportunity product
        OpportunityLineItem lineitem = new OpportunityLineItem();
        lineitem.OpportunityId = oppty.Id;
        lineitem.Product2Id = prod2.Id;
        lineitem.PricebookEntryId = entry1.Id;
        lineitem.Quantity = 1;
        lineitem.UnitPrice = 1000;
        insert lineitem;
        
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.Program_Name__c = 'MMP';
        leads.Work_Country__c = 'China';
        insert leads;
        
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(leads.Id);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        Database.LeadConvertResult result = Database.convertLead(Leadconvert);
        if(result.isSuccess()) {
            //create sales activity
            Activity__c act = new Activity__c();
            act.Product_Interest_Type__c = 'Brochure';
            act.Program_Type__c = 'test 1';
            act.Qualifier_for_Opportunity__c = true;
            act.Processed_by_Lead2Oppy__c = false;
            act.Lead_Type__c = 'OEP';
            act.Contact__c = result.getContactId();
            act.Rating__c = 'Warm';
            act.Program_Name__c = 'MMP';
            act.Campaign__c = camp.Id;
            insert act;
            
            //create contact role
            OpportunityContactRole role = new OpportunityContactRole();
            role.OpportunityId = oppty.Id;
            role.ContactId = result.getContactId();
            insert role;
        }
        
        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
    static testMethod void testMethod5() {
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'MMP';
        insert prod;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'MMP generic';
        prod2.Programme__c = prod.Id;
        insert prod2;
        
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.EDP_Marketing_Score__c = 'C4';
        leads.Program_Name__c = 'MMP';
        leads.Work_Country__c = 'China';
        insert leads;
        
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(leads.Id);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        Database.LeadConvertResult result = Database.convertLead(Leadconvert);
        if(result.isSuccess()) {
            //create sales activity
            Activity__c act = new Activity__c();
            act.Product_Interest_Type__c = 'Brochure';
            act.Program_Type__c = 'test 1';
            act.Qualifier_for_Opportunity__c = true;
            act.Processed_by_Lead2Oppy__c = false;
            act.Lead_Type__c = 'OEP';
            act.Lead_Status__c= 'Qualifying';
            act.Contact__c = result.getContactId();
            act.Rating__c = 'Warm';
            act.EDP_Marketing_Score__c = 'C4';
            act.Program_Name__c = 'MMP';
            insert act;
            
            Activity__c act1 = new Activity__c();
            act1.Product_Interest_Type__c = 'Brochure';
            act1.Program_Type__c = 'test 222';
            act1.Processed_by_Lead2Oppy__c = false;
            act1.Lead_Type__c = 'OEP';
            act1.Lead_Status__c= 'Qualifying';
            act1.Contact__c = result.getContactId();
            act1.Rating__c = 'Warm';
            act1.EDP_Marketing_Score__c = 'C4';
            act1.Program_Name__c = 'MMP';
            act1.Reserved_Session__c = 'SUB MMP';
            insert act1;
        }
        
        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
    static testMethod void testMethod6() {
        //create product 
        Product2 prod = new Product2();
        prod.Name = 'MMP';
        insert prod;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'MMP generic';
        prod2.Programme__c = prod.Id;
        insert prod2;
        
        //create custom price book
     	Pricebook2 book2 = new Pricebook2();
     	book2.Name = System.Label.Price_Book_Name;
     	book2.IsActive = true;
     	insert book2;
        
       	PricebookEntry entry = new PricebookEntry();
     	entry.Product2Id = prod2.Id;
     	entry.Pricebook2Id = Test.getStandardPricebookId();
    	    entry.UnitPrice = 1200;
     	entry.IsActive = true;
     	insert entry;
        
    	//create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        leads.Status= 'New';
        leads.EDP_Marketing_Score__c = 'C4';
        leads.Program_Name__c = 'MMP';
        leads.Work_Country__c = 'China';
        insert leads;
        
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(leads.Id);
        LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
        Database.LeadConvertResult result = Database.convertLead(Leadconvert);
        if(result.isSuccess()) {
            //create sales activity
            Activity__c act = new Activity__c();
            act.Product_Interest_Type__c = 'Brochure';
            act.Program_Type__c = 'test 1';
            act.Qualifier_for_Opportunity__c = true;
            act.Processed_by_Lead2Oppy__c = false;
            act.Lead_Type__c = 'OEP';
            act.Lead_Status__c= 'Qualifying';
            act.Contact__c = result.getContactId();
            act.Rating__c = 'Warm';
            act.EDP_Marketing_Score__c = 'B2';
            act.Program_Name__c = 'MMP';
            insert act;
            
            Activity__c act1 = new Activity__c();
            act1.Product_Interest_Type__c = 'Brochure';
            act1.Program_Type__c = 'test 222';
            act1.Processed_by_Lead2Oppy__c = false;
            act1.Lead_Type__c = 'OEP';
            act1.Lead_Status__c= 'Qualifying';
            act1.Contact__c = result.getContactId();
            act1.Rating__c = 'Warm';
            act1.EDP_Marketing_Score__c = 'C4';
            act1.Program_Name__c = 'MMP';
            act1.Reserved_Session__c = 'SUB MMP';
            insert act1;
        }
        
        System.Test.startTest();
        System.schedule('test warm activity conversion job','0 0 10 * * ?', new WarmActivity4LeadConversionSch());
        System.Test.stopTest();
    }
}