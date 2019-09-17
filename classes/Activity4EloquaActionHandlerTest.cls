@isTest
private class Activity4EloquaActionHandlerTest {
    static testMethod void testMethod1() {
        //create lead
        Lead leads = new Lead();
        leads.LastName = 'test';
        leads.FirstName = 'leads';
        leads.Company = 'testaccount';
        leads.Email = '1234567@test.com';
        insert leads;
        
        //create sales activity
        Activity__c act = new Activity__c();
        act.Lead__c = leads.Id;
        act.Product_Interest_Type__c = 'Brochure';
        act.Program_Type__c = 'test 1';
        act.Is_Eloqua_Activity__c = true;
        insert act;
    }
}