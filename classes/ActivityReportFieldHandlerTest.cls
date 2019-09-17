@isTest
private class ActivityReportFieldHandlerTest {
    static testMethod void testMethod1() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'OnlineAd';
        salesact.Havas_Campaign_Id__c = 'ssu';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'Email Campaign';
        salesact.Product_Interest_Type__c = 'Broc';
        insert salesact;
    }
    static testMethod void testMethod3() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'direct';
        salesact.Havas_Campaign_Id__c = 'Organic';
        salesact.Havas_Ad_Id__c = 'x';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'Email Campaign';
        salesact.Product_Interest_Type__c = 'Appl';
        insert salesact;
    }
    static testMethod void testMethod4() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'Social';
        salesact.Havas_Campaign_Id__c = 'Google-Search';
        salesact.Havas_Ad_Id__c = 'x';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'INSEAD Website';
        salesact.Product_Interest_Type__c = 'Res';
        insert salesact;
    }
    static testMethod void testMethod2() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'organic';
        salesact.Havas_Campaign_Id__c = 'ssu';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'Email Campaign';
        salesact.Product_Interest_Type__c = 'Broc';
        insert salesact;
        
        Activity__c upsalesact = [select Id,GA_Medium__c,Havas_Campaign_Id__c,Product_Interest_Type__c from Activity__c where Id=: salesact.Id];
        upsalesact.GA_Medium__c = 'email';
        upsalesact.Havas_Campaign_Id__c = 'Organic';
        upsalesact.Product_Interest_Type__c = 'Appl';
        update upsalesact;
    }
    static testMethod void testMethod5() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'email';
        salesact.Havas_Campaign_Id__c = 'ssu';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'Email Campaign';
        salesact.Product_Interest_Type__c = 'Broc';
        insert salesact;
        
        Activity__c upsalesact = [select Id,GA_Medium__c,Havas_Campaign_Id__c,Product_Interest_Type__c from Activity__c where Id=: salesact.Id];
        upsalesact.GA_Medium__c = 'direct';
        upsalesact.Havas_Campaign_Id__c = 'Inmail';
        upsalesact.Havas_Ad_Id__c = 'x';
        upsalesact.Havas_Site_Id__c = 'GGL';
        upsalesact.Lead_Source__c = 'Email Campaign';
        upsalesact.Product_Interest_Type__c = 'Appl';
        update upsalesact;
    }
    static testMethod void testMethod6() {
        Activity__c salesact = new Activity__c();
        salesact.GA_Medium__c = 'Social';
        salesact.Havas_Campaign_Id__c = 'Google-Search';
        salesact.Havas_Site_Id__c = 'GGL';
        salesact.Lead_Source__c = 'Email Campaign';
        salesact.Product_Interest_Type__c = 'Broc';
        insert salesact;
        
        Activity__c upsalesact = [select Id,GA_Medium__c,Havas_Campaign_Id__c,Product_Interest_Type__c from Activity__c where Id=: salesact.Id];
        upsalesact.GA_Medium__c = 'Social';
        upsalesact.Havas_Campaign_Id__c = 'Google-Search';
        upsalesact.Havas_Ad_Id__c = 'x';
        upsalesact.Havas_Site_Id__c = 'GGL';
        upsalesact.Lead_Source__c = 'INSEAD Website';
        upsalesact.Product_Interest_Type__c = 'Res';
        update upsalesact;
    }
}