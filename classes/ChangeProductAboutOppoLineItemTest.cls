@isTest(SeeAllData=true)
private class ChangeProductAboutOppoLineItemTest {
    static testMethod void testMethod1() {
    	//create product
    	Product2 prod = new Product2();
    	prod.Name = 'test product';
    	insert prod;

    	Product2 prod1 = new Product2();
    	prod1.Name = 'test product 1';
    	insert prod1;

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
    	insert oppty;

    	//create opportunity product
    	OpportunityLineItem lineitem = new OpportunityLineItem();
    	lineitem.OpportunityId = oppty.Id;
    	lineitem.Product2Id = prod.Id;
    	lineitem.PricebookEntryId = entry1.Id;
    	lineitem.Quantity = 1;
    	lineitem.UnitPrice = 1000;
    	insert lineitem;

        System.Test.startTest();
        ChangeProductAboutOppoLineItem.InitData(oppty.Id);
        ChangeProductAboutOppoLineItem.CreateOpportunityProduct(prod1.Id,'test changereason',lineitem.Id);
        System.Test.stopTest();
    }
    static testMethod void testMethod2() {
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
    	insert oppty;

        System.Test.startTest();
        ChangeProductAboutOppoLineItem.InitData(oppty.Id);
        System.Test.stopTest();
    }
}