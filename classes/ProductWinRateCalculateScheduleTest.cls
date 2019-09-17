@isTest
private class ProductWinRateCalculateScheduleTest {
    static testMethod void testMethod1() {
        //create Product
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.Is_Programme__c = true;
        prod.RecordTypeId = [select Id from RecordType where DeveloperName = 'OEP'].Id;
        insert prod;

        Product2 prod1 = new Product2();
        prod1.Name = 'test product 1';
        prod1.Programme__c = prod.Id;
        insert prod1;
        // create price book
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
        System.schedule('Test Product Win Rate Job','0 0 1 * * ?',new ProductWinRateCalculateSchedule());
        System.Test.stopTest();
    }
}