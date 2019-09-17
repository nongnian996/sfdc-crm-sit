@isTest
private class AccountRevenueSummaryExtTest {
    static testMethod void testMethod1() {
    	//create account
    	Account acct = new Account();
    	acct.Name = 'test account';
    	insert acct;

    	Account acct1 = new Account();
    	acct1.Name = 'test account';
    	acct1.ParentId = acct.Id; 
    	insert acct1;

    	//create opportunity
    	Opportunity oppty = new Opportunity();
    	oppty.Name = 'test Opportunity';
    	oppty.StageName = 'New';
    	oppty.CloseDate = Date.today().addDays(30);
        oppty.AccountId = acct.Id;
        oppty.Amount = 100000;
    	insert oppty;

    	Opportunity oppty1 = new Opportunity();
    	oppty1.Name = 'test Opportunity 1';
    	oppty1.StageName = 'New';
    	oppty1.CloseDate = Date.today().addDays(31);
        oppty1.AccountId = acct1.Id;
	    oppty1.Amount = 300000;
    	insert oppty1;

        System.Test.startTest();
        AccountRevenueSummaryExt revensummary = new AccountRevenueSummaryExt(new ApexPages.StandardController(acct));
        AccountRevenueSummaryExt.doInitialize(acct.Id);
        System.Test.stopTest();

    }
}