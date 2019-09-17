@isTest
private class AddChildOpportunitiesTest {
    static testMethod void testMethod1() {
    	//create contact
    	Contact cont = new Contact();
    	cont.LastName = 'test';
    	cont.FirstName = 'clone';
    	insert cont;

    	//create product
    	Product2 prod = new Product2();
    	prod.Name = 'test product';
    	insert prod;

    	//create custom price book
    	Pricebook2 book2 = new Pricebook2();
    	book2.Name = 'test book';
    	book2.IsActive = true;
    	insert book2;

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = prod.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;

    	//create opportunity
    	Opportunity oppty = new Opportunity();
    	oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today();
    	oppty.Pricebook2Id = book2.Id;
        oppty.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_B2B'].Id;
    	insert oppty;

    	Opportunity oppty1 = new Opportunity();
    	oppty1.Name = 'test Opportunity child';
    	oppty1.StageName = 'New';
    	Oppty1.CloseDate = Date.today();
    	oppty1.Pricebook2Id = book2.Id;
    	oppty1.CSP_Parent_Opportunity__c = oppty.Id;
    	insert oppty1;

    	//create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = prod.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
        lineitem.HR_Seats__c = 2;
    	insert lineitem;

    	OpportunityLineItem lineitem1 = new OpportunityLineItem();
    	lineitem1.OpportunityId = oppty1.Id;
    	lineitem1.Product2Id = prod.Id;
    	lineitem1.PricebookEntryId = entry1.Id;
    	lineitem1.Quantity = 1;
    	lineitem1.UnitPrice = 1000;
    	insert lineitem1;

    	//create contact role
    	OpportunityContactRole role = new OpportunityContactRole();
    	role.OpportunityId = oppty1.Id;
    	role.ContactId = cont.Id;
    	insert role;

        System.Test.startTest();
        AddChildOpportunities addchild = new AddChildOpportunities(new ApexPages.StandardController(lineitem));
        addchild.contactid = cont.Id;
        addchild.remove();
        addchild.cancel();
        System.Test.stopTest();
    }
    static testMethod void testMethod2() {
    	//create contact
    	Contact cont = new Contact();
    	cont.LastName = 'test';
    	cont.FirstName = 'clone';
    	insert cont;

    	//create product
    	Product2 prod = new Product2();
    	prod.Name = 'test product';
    	insert prod;

    	//create custom price book
    	Pricebook2 book2 = new Pricebook2();
    	book2.Name = 'test book';
    	book2.IsActive = true;
    	insert book2;

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = prod.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;

    	//create opportunity
    	Opportunity oppty = new Opportunity();
    	oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today();
    	oppty.Pricebook2Id = book2.Id;
        oppty.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_B2B'].Id;
    	insert oppty;

    	//create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = prod.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
        lineitem.HR_Seats__c = 2;
    	insert lineitem;

        System.Test.startTest();
        AddChildOpportunities addchild = new AddChildOpportunities(new ApexPages.StandardController(lineitem));
        OpportunityLineItem items = new OpportunityLineItem();
        items.Product2Id = prod.Id;
        items.Particpant_Full_Name__c = cont.Id;
        List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
        itemlist.add(items);
        addchild.opptyprodlist = itemlist;
        addchild.save();
        System.Test.stopTest();
    }
    static testMethod void testMethod3() {
    	//create contact
    	Contact cont = new Contact();
    	cont.LastName = 'test';
    	cont.FirstName = 'clone';
    	insert cont;
        
        Contact cont1 = new Contact();
    	cont1.LastName = 'test';
    	cont1.FirstName = 'clone 1';
    	insert cont1;

    	//create product
    	Product2 prod = new Product2();
    	prod.Name = 'test product';
    	insert prod;

    	//create custom price book
    	Pricebook2 book2 = new Pricebook2();
    	book2.Name = 'test book';
    	book2.IsActive = true;
    	insert book2;

    	PricebookEntry entry = new PricebookEntry();
    	entry.Product2Id = prod.Id;
    	entry.Pricebook2Id = Test.getStandardPricebookId();
    	entry.UnitPrice = 1200;
    	entry.IsActive = true;
    	insert entry;

    	PricebookEntry entry1 = new PricebookEntry();
    	entry1.Product2Id = prod.Id;
    	entry1.Pricebook2Id = book2.Id;
    	entry1.UnitPrice = 1200;
    	entry1.IsActive = true;
    	insert entry1;

    	//create opportunity
    	Opportunity oppty = new Opportunity();
    	oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	Oppty.CloseDate = Date.today();
    	oppty.Pricebook2Id = book2.Id;
        oppty.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_B2B'].Id;
    	insert oppty;
        
        Opportunity oppty1 = new Opportunity();
    	oppty1.Name = 'clone test Opportunity';
    	oppty1.StageName = 'New';
    	Oppty1.CloseDate = Date.today();
    	oppty1.Pricebook2Id = book2.Id;
    	oppty1.CSP_Parent_Opportunity__c = oppty.Id;
        oppty1.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP_Online'].Id;
    	insert oppty1;

    	//create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = prod.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
        lineitem.HR_Seats__c = 2;
    	insert lineitem;
        
        OpportunityLineItem lineitem1 = new OpportunityLineItem();
    	lineitem1.OpportunityId = oppty1.Id;
    	lineitem1.Product2Id = prod.Id;
    	lineitem1.PricebookEntryId = entry1.Id;
    	lineitem1.Quantity = 1;
    	lineitem1.UnitPrice = 1000;
    	insert lineitem1;
        
        OpportunityContactRole role = new OpportunityContactRole();
    	role.OpportunityId = oppty1.Id;
    	role.ContactId = cont.Id;
    	insert role;


        System.Test.startTest();
        AddChildOpportunities addchild = new AddChildOpportunities(new ApexPages.StandardController(lineitem));
        OpportunityLineItem items = new OpportunityLineItem();
        items.Product2Id = prod.Id;
        items.Particpant_Full_Name__c = cont.Id;
        
        OpportunityLineItem items1 = new OpportunityLineItem();
        items1.Product2Id = prod.Id;
        items1.Particpant_Full_Name__c = cont1.Id;
        
        List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
        itemlist.add(items);
        itemlist.add(items1);
        addchild.opptyprodlist = itemlist;
        addchild.save();
        System.Test.stopTest();
    }
}