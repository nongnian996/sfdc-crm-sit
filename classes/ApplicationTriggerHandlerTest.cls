@isTest(SeeAllData=true)
private class ApplicationTriggerHandlerTest {
    static testMethod void testMethod1() {
        Product2 childprod = new Product2();
        childprod.Name = 'child product';
        childprod.Academic_Sub_Plan__c = 'subplan';
        childprod.Term__c = 'term';
        childprod.Campus__c = 'campus';
        childprod.Academic_Plan__c = 'academicplan';
        insert childprod;

        //create account data
        Account acct = new Account();
        acct.Name = 'testcompany';
        acct.BillingCountry = 'China';
        insert acct;
        
        //create lead data
        Lead leads = new Lead();
        leads.LastName = 'application';
        leads.FirstName = 'test';
        leads.Email = '123456@test.com';
        insert leads;
        
        //create application data
        Application__c applic = new Application__c();
        applic.Applicant_FirstName__c = 'test';
        applic.Applicant_LastName__c = 'application';
        applic.Applicant_EloquaID__c = 'testcontacteloquaId';
        applic.Applicant_Email__c = '123456@test.com';
        applic.Company_Name__c = 'testcompany';
        applic.Applicant_Nationality__c = 'China';
        applic.Application_Subplan__c = 'subplan';
        applic.Application_AdmitTerm__c = 'term';
        applic.Application_Campus__c = 'campus';
        applic.Application_Plan__c = 'academicplan';
        insert applic;
    }
    static testMethod void testMethod2() {
        Product2 childprod = new Product2();
        childprod.Name = 'child product';
        childprod.Academic_Sub_Plan__c = 'subplan';
        childprod.Term__c = 'term';
        childprod.Campus__c = 'campus';
        childprod.Academic_Plan__c = 'academicplan';
        insert childprod;

        //create application data
        Application__c applic = new Application__c();
        applic.Applicant_FirstName__c = 'test';
        applic.Applicant_LastName__c = 'application';
        applic.Applicant_EloquaID__c = 'testcontacteloquaId';
        applic.Applicant_Email__c = '123456@test.com';
        applic.Company_Name__c = 'testcompany';
        applic.Applicant_Nationality__c = 'China';
        applic.Application_Subplan__c = 'subplan';
        applic.Application_AdmitTerm__c = 'term';
        applic.Application_Campus__c = 'campus';
        applic.Application_Plan__c = 'academicplan';
        insert applic;
    }
    static testMethod void testMethod3() {
        //create product data
        Product2 parentprod = new Product2();
        parentprod.Name = 'programme product';
        parentprod.Is_Programme__c = true;
        insert parentprod;
        
        Product2 childprod = new Product2();
        childprod.Name = 'child product';
        childprod.Programme__c = parentprod.Id;
        childprod.Academic_Sub_Plan__c = 'subplan';
        childprod.Term__c = 'term';
        childprod.Campus__c = 'campus';
        childprod.Academic_Plan__c = 'academicplan';
        insert childprod;
        
        //create custom price book
        String custompricebook = System.Label.Price_Book_Name;
    	Pricebook2 book2 = [select Id from Pricebook2 where Name =:custompricebook];

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = parentprod.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = parentprod.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;
        
        //create contact 
        Contact cont = new Contact();
        cont.LastName = 'application';
        cont.FirstName = 'test';
        cont.Email = '123456@test.com';
        cont.Eloqua_Contact_ID__c = 'testcontacteloquaId';
        insert cont;
        
        Contact cont1 = new Contact();
        cont1.LastName = 'test';
        cont1.FirstName = 'hrcont';
        cont1.Email = '123456@test.com';
        insert cont1;
        
        //Create opportunity data
        Opportunity oppty = new Opportunity();
        oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today();
    	oppty.Pricebook2Id = book2.Id;
    	insert oppty;
        
        //create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = parentprod.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
    	insert lineitem;
        
        //create opportunity role 
        OpportunityCOntactRole role = new OpportunityCOntactRole();
        role.OpportunityId = oppty.Id;
        role.ContactId = cont.Id;
        insert role;
        
        //create application data
        Application__c applic = new Application__c();
        applic.Applicant_FirstName__c = 'test';
        applic.Applicant_LastName__c = 'application';
        applic.Applicant_Email__c = '123456@test.com';
        applic.Application_Subplan__c = 'subplan';
        applic.Application_AdmitTerm__c = 'term';
        applic.Application_Campus__c = 'campus';
        applic.Application_Plan__c = 'academicplan';
        applic.Applicant_EloquaID__c = 'testcontacteloquaId';
        applic.HR_FirstName__c = 'hrcont';
        applic.HR_LastName__c = 'test';
        applic.HR_Email__c = '123456@test.com';
        applic.HR_Company__c = 'testcompany';
        applic.HR_Country__c = 'China';
        insert applic;
    }
    static testMethod void testMethod4() {
        //create product data
        Product2 parentprod = new Product2();
        parentprod.Name = 'programme product';
        parentprod.Is_Programme__c = true;
        insert parentprod;
        
        Product2 childprod = new Product2();
        childprod.Name = 'child product';
        childprod.Programme__c = parentprod.Id;
        childprod.Academic_Sub_Plan__c = 'subplan';
        childprod.Term__c = 'term';
        childprod.Campus__c = 'campus';
        childprod.Academic_Plan__c = 'academicplan';
        insert childprod;
        
        Product2 childprod1 = new Product2();
        childprod1.Name = 'child product';
        childprod1.Programme__c = parentprod.Id;
        childprod1.Academic_Sub_Plan__c = 'subplan1';
        childprod1.Term__c = 'term1';
        childprod1.Campus__c = 'campus1';
        childprod1.Academic_Plan__c = 'academicplan1';
        insert childprod1;
        
        //create custom price book
        String custompricebook = System.Label.Price_Book_Name;
    	Pricebook2 book2 = [select Id from Pricebook2 where Name =:custompricebook];

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = childprod1.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = childprod1.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;
        
        PricebookEntry entry2 = new PricebookEntry();
    	entry2.Product2Id = childprod.Id;
    	entry2.Pricebook2Id = Test.getStandardPricebookId();
    	entry2.UnitPrice = 1200;
    	entry2.IsActive = true;
    	insert entry2;

    	PricebookEntry entry3 = new PricebookEntry();
    	entry3.Product2Id = childprod.Id;
    	entry3.Pricebook2Id = book2.Id;
    	entry3.UnitPrice = 1200;
    	entry3.IsActive = true;
    	insert entry3;
        
        //create contact 
        Contact cont = new Contact();
        cont.LastName = 'application';
        cont.FirstName = 'test';
        cont.Email = '123456@test.com';
        cont.Eloqua_Contact_ID__c = 'testcontacteloquaId';
        insert cont;
        
        Contact cont1 = new Contact();
        cont1.LastName = 'test';
        cont1.FirstName = 'hrcont';
        cont1.Email = '123456@test.com';
        insert cont1;
        
        //Create opportunity data
        Opportunity oppty = new Opportunity();
        oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today();
    	oppty.Pricebook2Id = book2.Id;
    	insert oppty;
        
        //create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = childprod1.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
    	insert lineitem;
        
        //create opportunity role 
        OpportunityCOntactRole role = new OpportunityCOntactRole();
        role.OpportunityId = oppty.Id;
        role.ContactId = cont.Id;
        insert role;
        
        //create application data
        Application__c applic = new Application__c();
        applic.Applicant_FirstName__c = 'test';
        applic.Applicant_LastName__c = 'application';
        applic.Applicant_Email__c = '123456@test.com';
        applic.Application_Subplan__c = 'subplan';
        applic.Application_AdmitTerm__c = 'term';
        applic.Application_Campus__c = 'campus';
        applic.Application_Plan__c = 'academicplan';
        applic.Applicant_EloquaID__c = 'testcontacteloquaId';
        applic.HR_FirstName__c = 'hrcont';
        applic.HR_LastName__c = 'test';
        applic.HR_Email__c = '123456@test.com';
        applic.HR_Company__c = 'testcompany';
        applic.HR_Country__c = 'China';
        insert applic;
    }
}