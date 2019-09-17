@isTest
private class GDPR_ContactInformationDownloadTest {
    static testMethod void testMethod1() {
    	//create contact data
    	Contact cont = new Contact();
    	cont.LastName = 'test';
    	cont.FirstName = 'contact';
    	cont.Age__c = 18;
    	insert cont;
        
        Contact cont1 = new Contact();
    	cont1.LastName = 'test';
    	cont1.FirstName = 'contact1';
    	cont1.Age__c = 17;
    	insert cont1;
        
        hed__Program_Enrollment__c program = new hed__Program_Enrollment__c();
        program.hed__Contact__c = cont.Id;
        insert program;
        
        hed__Affiliation__c affil = new hed__Affiliation__c();
        affil.hed__Contact__c = cont.Id;
        insert affil;
        
        hed__Relationship__c relatedship = new hed__Relationship__c();
        relatedship.hed__Contact__c = cont.Id;
        relatedship.hed__RelatedContact__c = cont1.Id;
        insert relatedship;
        
        Activity__c act = new Activity__c();
        act.Contact__c = cont.Id;
        insert act;

        System.Test.startTest();
        GDPR_ContactInformationDownload.GDPR_ContactInformationDownload(cont.Id);
        System.Test.stopTest();
    }
}