@isTest
private class RN_Generic_lightning_LookupTest {
    static testMethod void testMethod1() {
    	//create product data
    	Product2 prod = new Product2();
    	prod.Name = 'test product';
    	insert prod;

        System.Test.startTest();
        RN_Generic_lightning_Lookup.lookup('test','Product2');
        RN_Generic_lightning_Lookup.lookup('','Product2');
        System.Test.stopTest();
    }
}