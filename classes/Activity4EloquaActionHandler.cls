/************************************************************************************
Class Name : Activity4EloquaActionHandler
Version : 1.0 
Created Date : 07/26/2019
Function : 1, Tag activity to Contact if there's an new eloqua activity coming
           2, Auto convert lead if there's an new submit a form/reserve a seat/download a brochure
           3, Create an new opportunity for DP contact if there's an new submit a form/reserve a seat/download a brochure

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Terry                07/26/2019               Version 1.0
*************************************************************************************/
public without sharing class Activity4EloquaActionHandler implements Triggers.Handler {

    public void handle() {
        Map<String, String> rtMap = InseadUtil.getObjectRecordType('Activity__c');
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> eloquaIdSet = new Set<String>();
        Set<String> leadIdSet = new Set<String>();
        Set<String> campaignIdSet = new Set<String>();
        Set<String> siebelIdSet = new Set<String>();
        if(Trigger.isBefore) {
            for(Activity__c t : (List<Activity__c>) Trigger.new) {
                t.Qualifier_for_Opportunity__c = (t.Create_Lead_for_ODM_Activity__c == null || 'N' == t.Create_Lead_for_ODM_Activity__c)? false : true;
                t.Name = t.First_Name__c + ' ' + t.Last_Name__c + ' - ' + t.Program_Name__c;
                System.debug(LoggingLevel.INFO, '*** t: ' + t);
                // if(t.CRMCampaignId__c != null) {
                //     campaignIdSet.add(t.CRMCampaignId__c);
                // }
                // if(t.Last_Siebel_OnDemand_Campaign_ID__c != null) {
                //     siebelIdSet.add(t.Last_Siebel_OnDemand_Campaign_ID__c);
                // }
                if(!t.Is_Eloqua_Activity__c || String.isBlank(t.Registration_Email__c)) continue;

                System.debug(LoggingLevel.INFO, '*** eloqua Activity__c: ' + t);
                // t.WhoId = t.WhoId != null? t.WhoId : (t.SFDC_Contact_ID__c == null? (t.SFDC_Lead_ID__c == null? null : t.SFDC_Lead_ID__c) : t.SFDC_Contact_ID__c);
                // System.debug(LoggingLevel.INFO, '*** t.WhoId: ' + t.WhoId);
                // t.Program_Type__c
                
                if(t.Lead__c != null) {
                    leadIdSet.add(t.Lead__c);
                }
                String activityType = t.Product_Interest_Type__c + t.Program_Type__c;
                if(activityType.containsIgnoreCase('Application')) t.RecordTypeId = rtMap.get('Submit_a_form');
                if(activityType.containsIgnoreCase('Reserve')) t.RecordTypeId = rtMap.get('Reserve_a_seat');
                if(activityType.containsIgnoreCase('Brochure')) t.RecordTypeId = rtMap.get('Download_a_brochure');

                if(t.Contact__c == null && t.Lead__c == null) {
                    if(t.First_Name__c != null) firstNameSet.add(t.First_Name__c);
                    lastNameSet.add(t.Last_Name__c);
                    if(t.Registration_Email__c != null) emailSet.add(t.Registration_Email__c);
                    if(t.Eloqua_Contact_ID__c != null) eloquaIdSet.add(t.Eloqua_Contact_ID__c);
                }

            }
            //tag activity to campaign
            // Map<String, Campaign> campaignMap = new Map<String, Campaign>();
            // Map<String, Campaign> IntegrationCampaignMap = new Map<String, Campaign>();
            // for(Campaign campaign : [Select Id, Integration_ID__c From Campaign Where Id IN: campaignIdSet OR Integration_ID__c IN: siebelIdSet]) {
            //     campaignMap.put(campaign.Id, campaign);
            //     if(campaign.Integration_ID__c != null) {
            //         IntegrationCampaignMap.put(campaign.Integration_ID__c, campaign);
            //     }
            // }
            // System.debug(LoggingLevel.INFO, '*** campaignIdSet: ' + campaignIdSet);
            // System.debug(LoggingLevel.INFO, '*** siebelIdSet: ' + siebelIdSet);
            // System.debug(LoggingLevel.INFO, '*** campaignMap: ' + campaignMap);
            // System.debug(LoggingLevel.INFO, '*** IntegrationCampaignMap: ' + IntegrationCampaignMap);
            Map<String, Lead> convertedLeadMap = new Map<String, Lead>();
            for(Lead ld : [Select Id, ConvertedContactId From Lead Where Id IN: leadIdSet And IsConverted = true]) {
                convertedLeadMap.put(ld.Id, ld);
            }
            Map<String, String> recordMap = findMatchingRecord(firstNameSet, lastNameSet, emailSet, eloquaIdSet);
            System.debug(LoggingLevel.INFO, '*** recordMap: ' + recordMap);
            Set<String> companySet = new Set<String>();
            Set<String> countrySet = new Set<String>();
            Map<String, String> companyCountryMap = new Map<String, String>();
            List<Activity__c> activityList = new List<Activity__c>();
            Set<String> contactIdSet = new Set<String>();
            leadIdSet = new Set<String>();
            Map<String, Lead> leadMap = new Map<String, Lead>();
            Map<String, Contact> contactMap = new Map<String, Contact>();
            for(Activity__c t : (List<Activity__c>)Trigger.new) {

                // if(campaignMap.containsKey(t.CRMCampaignId__c)) {
                //     t.Campaign__c = campaignMap.get(t.CRMCampaignId__c).Id;
                // }
                // if(t.Campaign__c == null && IntegrationCampaignMap.containsKey(t.Last_Siebel_OnDemand_Campaign_ID__c)) {
                //     t.Campaign__c = IntegrationCampaignMap.get(t.Last_Siebel_OnDemand_Campaign_ID__c).Id;
                // }
                // System.debug(LoggingLevel.INFO, '*** t.Campaign__c: ' + t.Campaign__c);
                if(!t.Is_Eloqua_Activity__c || String.isBlank(t.Registration_Email__c)) continue;
                
                String key = t.First_Name__c + t.Last_Name__c;
                key = t.Registration_Email__c != null? key += t.Registration_Email__c: key;
                key = t.Work_Email__c != null? key += t.Work_Email__c: key;
                key = t.Home_Email__c != null? key += t.Home_Email__c: key;

                Id recordId = recordMap.get(key);
                if(convertedLeadMap.containsKey(t.Lead__c)) {
                    t.Contact__c = convertedLeadMap.get(t.Lead__c).ConvertedContactId;
                    t.Lead__c = null;
                }
                if(t.Contact__c == null && t.Eloqua_Contact_ID__c != null && recordMap.containsKey(key)) {
                    if(recordId.getSobjectType().getDescribe().getName() == 'Lead') {
                        t.Lead__c = recordId;
                    }
                    if(recordId.getSobjectType().getDescribe().getName() == 'Contact') {
                        t.Contact__c = recordId;
                    }
                }
                if(t.Contact__c == null && t.Lead__c == null && recordMap.containsKey(key)) {
                    if(recordId.getSobjectType().getDescribe().getName() == 'Lead') {
                        t.Lead__c = recordId;
                    }
                    if(recordId.getSobjectType().getDescribe().getName() == 'Contact') {
                        t.Contact__c = recordId;
                    }
                }
                if(t.Contact__c == null && t.Lead__c == null) {
                    System.debug(LoggingLevel.INFO, '*** t.First_Name__c: ' + t.First_Name__c);
                    if(t.Company__c != null) {
                        companySet.add(t.Company__c);
                    }
                    countrySet.add(t.Work_Country__c);
                    if(t.Company__c != null) {
                        companyCountryMap.put(t.Company__c + ':' + t.Work_Country__c, t.Company__c + ':' + t.Work_Country__c);
                    }
                    activityList.add(t);
                }
                if(t.Contact__c != null) {
                    contactIdSet.add(t.Contact__c);
                }
                if(t.Lead__c != null) {
                    leadIdSet.add(t.Lead__c);
                }
            }
            for(Contact cont : [Select Id, EDP_Marketing_Score__c From Contact Where Id IN: contactIdSet]) {
                contactMap.put(cont.Id, cont);
            }

            for(Lead ld : [Select Id, EDP_Marketing_Score__c From Lead Where Id IN: leadIdSet]) {
                leadMap.put(ld.Id, ld);
            }
            System.debug(LoggingLevel.INFO, '*** companySet: ' + companySet);
            System.debug(LoggingLevel.INFO, '*** countrySet: ' + countrySet);
            System.debug(LoggingLevel.INFO, '*** companyCountryMap: ' + companyCountryMap);
            //create new lead and build the relationship with Activity__c
            System.debug(LoggingLevel.INFO, '*** activityList: ' + activityList);

            Map<String, Lead> newLeadMap = createLead(activityList);
            Map<String, Contact> newContactMap = createContact(activityList, companySet, countrySet, companyCountryMap);
            
            for(Activity__c t : (List<Activity__c>) Trigger.new) {
                if(t.Contact__c != null && contactMap.containsKey(t.Contact__c)) {
                    t.EDP_Marketing_Score__c = contactMap.get(t.Contact__c).EDP_Marketing_Score__c;
                }else if(t.Lead__c != null && leadMap.containsKey(t.Lead__c)) {
                    t.EDP_Marketing_Score__c = leadMap.get(t.Lead__c).EDP_Marketing_Score__c;
                }
                if(!t.Is_Eloqua_Activity__c || String.isBlank(t.Registration_Email__c) || (t.Contact__c != null && t.lead__c != null)) continue;
                String key = t.First_Name__c + t.Last_Name__c;
                key = t.Registration_Email__c != null? key += t.Registration_Email__c: key;
                key = t.Work_Email__c != null? key += t.Work_Email__c: key;
                key = t.Home_Email__c != null? key += t.Home_Email__c: key;

                System.debug(LoggingLevel.INFO, '*** newkey: ' + key);
                if(t.Contact__c == null && newContactMap.containsKey(key)) {
                    t.Contact__c = newContactMap.get(key).Id;
                }
                if(t.Contact__c == null && String.isBlank(t.Lead__c) && newLeadMap.containsKey(key)) {
                    t.Lead__c = newLeadMap.get(key).Id;
                }
            }

            
        }
        if(Trigger.isAfter) {
            Map<Id, Id> campaignRelationshipMap = new Map<Id, Id>();
            for(Activity__c t : (List<Activity__c>) Trigger.new) {
                System.debug(LoggingLevel.INFO, '*** t.Contact__c: ' + t.Contact__c);
                System.debug(LoggingLevel.INFO, '*** t.Lead__c: ' + t.Lead__c);
                if(t.Campaign__c == null) continue;
                
                if(t.Contact__c != null) {
                    campaignRelationshipMap.put(t.Contact__c, t.Campaign__c);
                }
                if(t.Contact__c == null && t.Lead__c != null) {
                    campaignRelationshipMap.put(t.Lead__c, t.Campaign__c);
                }
            }
            updateCampaignRelationship(campaignRelationshipMap);
        }
        /***
        if(Trigger.isAfter) {
            System.debug(LoggingLevel.INFO, '*** after trigger: ');
            for(Activity__c t : (List<Activity__c>) Trigger.new) {

                if(!t.Is_Eloqua_Activity__c || String.isBlank(t.Registration_Email__c)) continue;
                String activityType = '' + t.Program_Type__c + t.Product_Interest_Type__c;

                if(!t.Qualifier_for_Opportunity__c) continue;

                if(activityType.containsIgnoreCase('Application') || activityType.containsIgnoreCase('Reserve') || activityType.containsIgnoreCase('Brochure')) {
                    if(t.Contact__c != null) {
                        autoTagOpportunity2Contact(t.Contact__c, t.Program_Name__c, t.Reserved_Session__c, t.Id, t.Are_you_a_HR__c);
                    }
                    if(t.Contact__c == null && t.Lead__c != null) {
                        if((activityType.containsIgnoreCase('Application') || activityType.containsIgnoreCase('Reserve')) || activityType.containsIgnoreCase('Brochure')) {
                            AutoConvertLeads.autoConvert(t.Lead__c, t.Id, t.Reserved_Session__c, activityType, t.Program_Name__c);
                        }
                    }
                }
            }
        }
        ***/
    }

    public static void updateCampaignRelationship(Map<Id, Id> relationshipMap) {

        System.debug(LoggingLevel.INFO, '*** relationshipMap: ' + relationshipMap);
        if(relationshipMap.size() < 1) return;

        Map<String, CampaignMember> existingMemberMap = new Map<String, CampaignMember>();
        for(CampaignMember member : [Select Id, LeadId, ContactId, CampaignId From CampaignMember Where (LeadId IN: relationshipMap.keySet() OR ContactId IN: relationshipMap.keySet()) AND CampaignId IN: relationshipMap.values()]) {
            
            String recordId = member.ContactId == null? member.LeadId : member.ContactId;
            existingMemberMap.put(member.CampaignId + '' + recordId, member);
        }
        System.debug(LoggingLevel.INFO, '*** existingMemberMap: ' + existingMemberMap);
        List<CampaignMember> memberList = new List<CampaignMember>();
        for(Id recordId : relationshipMap.keySet()) {

            
            if(existingMemberMap.containsKey(relationshipMap.get(recordId) + '' + recordId)) continue;

            CampaignMember member = new CampaignMember();
            member.Status = 'Responded';
            member.CampaignId = relationshipMap.get(recordId);
            if(recordId.getSobjectType().getDescribe().getName() == 'Lead') {
                member.LeadId = recordId;
            }
            if(recordId.getSobjectType().getDescribe().getName() == 'Contact') {
                member.ContactId = recordId;
            }
            memberList.add(member);
        }
        insert memberList;
    }

    public static Map<String, Id> findMatchingRecord(Set<String> firstNameSet, Set<String> lastNameSet, Set<String> emailSet, Set<String> eloquaIdSet) {
        //key: firstName + lastName + email
        Map<String, Id> recordMap = new Map<String, Id>();
        // for(Contact con : [Select Id, FirstName, LastName, Email From Contact Where Data_Source__c = 'Eloqua' And FirstName IN: firstNameSet And LastName IN: lastNameSet And Email IN: emailSet]) {
        //     String key = con.FirstName + con.LastName + con.Email;
        //     if(recordMap.containsKey(key)) continue;
        //     recordMap.put(key, con.Id);
        // }
        List<Contact> contactList = new List<Contact>();
        System.debug(LoggingLevel.INFO, '*** eloquaIdSet: ' + eloquaIdSet);
        if(eloquaIdSet.size() > 0) {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Eloqua_Contact_ID__c, hed__AlternateEmail__c, Home_Email__c, hed__WorkEmail__c, hed__Preferred_Email__c
                                FROM Contact
                                WHERE Eloqua_Contact_ID__c IN: eloquaIdSet
                                OR (FirstName IN: firstNameSet 
                                    AND LastName IN: lastNameSet 
                                    AND (Email IN: emailSet OR hed__AlternateEmail__c IN: emailSet 
                                        OR Home_Email__c IN: emailSet OR hed__Preferred_Email__c IN: emailSet
                                        OR hed__WorkEmail__c IN: emailSet))];
        }else {
            contactList = [SELECT Id, FirstName, LastName, Email, AccountId, Eloqua_Contact_ID__c, hed__AlternateEmail__c, Home_Email__c, hed__WorkEmail__c, hed__Preferred_Email__c
                            FROM Contact
                            WHERE FirstName IN: firstNameSet 
                                AND LastName IN: lastNameSet 
                                AND (Email IN: emailSet OR hed__AlternateEmail__c IN: emailSet 
                                    OR Home_Email__c IN: emailSet OR hed__Preferred_Email__c IN: emailSet
                                    OR hed__WorkEmail__c IN: emailSet)];
        }

        for(Contact cont : contactList) {
            if(cont.Eloqua_Contact_ID__c != null) recordMap.put(cont.Eloqua_Contact_ID__c, cont.Id);
            String key = cont.FirstName + cont.LastName;
            key = cont.Email != null? key += cont.Email: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__AlternateEmail__c != null? key += cont.hed__AlternateEmail__c: key;
            recordMap.put(key, cont.Id);
            key = cont.Home_Email__c != null? key += cont.Home_Email__c: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__Preferred_Email__c != null? key += cont.hed__Preferred_Email__c: key;
            recordMap.put(key, cont.Id);
            key = cont.hed__WorkEmail__c != null? key += cont.hed__WorkEmail__c: key;
            recordMap.put(key, cont.Id);
        }
        List<Lead> leadList = new List<Lead>();
        if(eloquaIdSet.size() > 0) {
            leadList = [SELECT Id, FirstName, LastName, Email, Eloqua_Contact_ID__c, Home_Email__c, Work_Email__c, ConvertedContactId 
                                            FROM Lead
                                            WHERE Eloqua_Contact_ID__c IN: eloquaIdSet
                                            OR (FirstName IN: firstNameSet 
                                                AND LastName IN: lastNameSet 
                                                AND (Email IN: emailSet 
                                                    OR Home_Email__c IN: emailSet 
                                                    OR Work_Email__c IN: emailSet))];
        }else {
            leadList = [SELECT Id, FirstName, LastName, Email, Eloqua_Contact_ID__c, Home_Email__c, Work_Email__c, ConvertedContactId 
                                            FROM Lead
                                            WHERE FirstName IN: firstNameSet 
                                                AND LastName IN: lastNameSet 
                                                AND (Email IN: emailSet 
                                                    OR Home_Email__c IN: emailSet
                                                    OR Work_Email__c IN: emailSet)];
        }
        for(lead lead : leadList) {

            String recordId = String.isBlank(lead.ConvertedContactId)? lead.Id : lead.ConvertedContactId;

            if(lead.Eloqua_Contact_ID__c != null && !recordMap.containsKey(lead.Eloqua_Contact_ID__c)) recordMap.put(lead.Eloqua_Contact_ID__c, recordId);
            
            String key = lead.FirstName + lead.LastName;
            key = lead.Email != null? key += lead.Email: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            key = lead.Home_Email__c != null? key += lead.Home_Email__c: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            key = lead.Work_Email__c != null? key += lead.Work_Email__c: key;
            if(!recordMap.containsKey(key)) recordMap.put(key, recordId);
            
        }
        return recordMap;
    }

    public static Map<String, Lead> createLead(List<Activity__c> activityList) {
        List<Lead_ActivityFieldsMapping__c> fieldList = Lead_ActivityFieldsMapping__c.getall().values();
        Map<String, Lead> leadMap = new Map<String, Lead>();
        for(Activity__c t : activityList) {
            if(t.Lead_Type__c != 'OEP') continue;
            System.debug(LoggingLevel.INFO, '*** t.Company__c: ' + t.Company__c);
            System.debug(LoggingLevel.INFO, '*** t.Last_Name__c: ' + t.Last_Name__c);
            Lead newLead = new Lead();
            for(Lead_ActivityFieldsMapping__c field : fieldList) {
                newLead.put(field.Lead_Field__c, t.get(field.Activity_Field__c));
            }
            newLead.Data_Source__c = 'Eloqua';

            String key = t.First_Name__c + t.Last_Name__c;
            key = t.Registration_Email__c != null? key += t.Registration_Email__c: key;
            key = t.Work_Email__c != null? key += t.Work_Email__c: key;
            key = t.Home_Email__c != null? key += t.Home_Email__c: key;

            leadMap.put(key, newLead);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        if(leadMap.size() > 0) Database.insert(leadMap.values(), dml); 
        // if(leadMap.size() > 0) insert leadMap.values();
        System.debug(LoggingLevel.INFO, '*** new leadMap: ' + leadMap);
        return leadMap;
    }

    public static Map<String, Contact> createContact(List<Activity__c> activityList, Set<String> companySet, Set<String> countrySet, Map<String, String> companyCountryMap) {

        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account acct : [Select Id, Name, BillingCountry From Account Where Name IN:companySet And BillingCountry IN: countrySet]) {
            accountMap.put(acct.Name + ':' + acct.BillingCountry, acct);
        }
        System.debug(LoggingLevel.INFO, '*** accountMap: ' + accountMap);
        Set<String> tmpSet1 = companyCountryMap.keySet();
        Set<String> tmpSet2 = accountMap.keySet();
        System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + tmpSet1);
        System.debug(LoggingLevel.INFO, '*** tmpSet2: ' + tmpSet2);
        tmpSet1.removeAll(tmpSet2);
        System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + tmpSet1);
        Map<String, String> acctRTMap = new Map<String, String>();
        if(tmpSet1.size() > 0) {
            acctRTMap = InseadUtil.getObjectRecordType('Account');
        }
        Map<String, Account> newAcctMap = new Map<String, Account>();
        for(String s : tmpSet1) {
            System.debug(LoggingLevel.INFO, '*** tmpSet1: ' + s);
            String company = s.split(':')[0], country = s.split(':')[1];
            Account acct = new Account();
            acct.Name = company;
            if(!String.isBlank(country) && country != 'null') acct.BillingCountry = country;
            acct.RecordTypeId = acctRTMap.get('Business_Organization');
            newAcctMap.put(s, acct);
        }
        System.debug(LoggingLevel.INFO, '*** newAcctMap: ' + newAcctMap);
        if(newAcctMap.size() > 0) insert newAcctMap.values();

        Map<String, Contact> contactMap = new Map<String, Contact>();
        List<Contact_ActivityFieldsMapping__c> fieldList = Contact_ActivityFieldsMapping__c.getall().values();
        for(Activity__c t : activityList) {
            if('OEP' == t.Lead_Type__c) continue;
            System.debug(LoggingLevel.INFO, '*** t.Company__c: ' + t.Company__c);
            System.debug(LoggingLevel.INFO, '*** t.Last_Name__c: ' + t.Last_Name__c);
            Contact newContact = new Contact();
            if(t.Company__c != null && accountMap.containsKey(t.Company__c + ':' + t.Work_Country__c)) {
                newContact.AccountId = accountMap.get(t.Company__c + ':' + t.Work_Country__c).Id;
            }else if(t.Company__c != null && newAcctMap.containsKey(t.Company__c + ':' + t.Work_Country__c)) {
                newContact.AccountId = newAcctMap.get(t.Company__c + ':' + t.Work_Country__c).Id;
            }
            for(Contact_ActivityFieldsMapping__c field : fieldList) {
                newContact.put(field.Contact_Field__c, t.get(field.Activity_Field__c));
            }

            newContact.Data_Source__c = 'Eloqua';
            String key = t.First_Name__c + t.Last_Name__c;
            key = t.Registration_Email__c != null? key += t.Registration_Email__c: key;
            key = t.Work_Email__c != null? key += t.Work_Email__c: key;
            key = t.Home_Email__c != null? key += t.Home_Email__c: key;

            contactMap.put(key, newContact);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        if(contactMap.size() > 0) Database.insert(contactMap.values(), dml); 
        // if(contactMap.size() > 0) insert contactMap.values();
        System.debug(LoggingLevel.INFO, '*** new contactMap: ' + contactMap);
        return contactMap;
    }

}