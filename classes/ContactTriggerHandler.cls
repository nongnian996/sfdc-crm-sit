public class ContactTriggerHandler {
    //extends TriggerHandler {
    public class BusinessAccountAffiliation {
        public hed__Affiliation__c record;
        public Contact contactRecord;

        public BusinessAccountAffiliation(Contact c, Id accountId) {
            this.contactRecord = c;
            this.record = new hed__Affiliation__c(hed__Account__c = accountId
                                    , hed__Role__c = 'Employee'
                                    , hed__StartDate__c = Date.today());
        }
        
        public void setContactId() {
            this.record.hed__Contact__c = this.contactRecord.Id;
        }
    }
    
    private static List<BusinessAccountAffiliation> contactAffiliations;
    private List<hed__Affiliation__c> affiliationsToInsert;
    
    public void beforeInsert() {
        contactAffiliations = new List<BusinessAccountAffiliation>();
        
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for(Contact cnt : (List<Contact>)Trigger.new) {
            if(cnt.AccountId != null) {
                if(!contactsByAccountId.containsKey(cnt.AccountId)) {
                    contactsByAccountId.put(cnt.AccountId, new List<Contact>());
                }
                
                contactsByAccountId.get(cnt.AccountId).add(cnt);
            }
        }
        
        if(contactsByAccountId.size() == 0) {
            return;
        }
        
        for(Account acct : [SELECT Id 
                            FROM Account 
                            WHERE Id IN : contactsByAccountId.keySet()
                            AND RecordType.Name = 'Business Organization']) {
        	for(Contact cnt : contactsByAccountId.get(acct.Id)) {
                contactAffiliations.add(new BusinessAccountAffiliation(cnt, acct.Id));
                cnt.AccountId = null;
            }	                        
        }
        
        System.debug('Trigger.new: '+Trigger.new);
        System.debug('contactAffiliations: '+contactAffiliations);
    }
    
    public void afterInsert() {
        System.debug('after insert contactAffiliations: '+contactAffiliations);
        
        affiliationsToInsert = new List<hed__Affiliation__c>();
        for(BusinessAccountAffiliation affiliation : contactAffiliations) {
            affiliation.setContactId();
            affiliationsToInsert.add(affiliation.record);
        }
        insert affiliationsToInsert;
    }
}