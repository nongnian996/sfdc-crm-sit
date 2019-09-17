public class hedAddressTriggerHandler implements Triggers.Handler {
	public void handle() {
        if(Trigger.isBefore) {
            //Replace HEDA Mailing Country (Free text) with Mailing Country Picklist
            //Populate Mailing Country to HEDA Mailing Country
            for(hed__Address__c a : (List<hed__Address__c>) Trigger.new) {
                if(a.Mailing_Country__c != null && a.Mailing_Country__c != '' && (a.Mailing_Country__c != a.hed__MailingCountry__c || a.hed__MailingCountry__c == null)) {
                    a.hed__MailingCountry__c = a.Mailing_Country__c;
                }
            }
        }
    }                
}