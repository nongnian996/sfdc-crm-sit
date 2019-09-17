/************************************************************************************
Class Name : ApplicationTriggerHandler
Version : 1.0 
Created Date : 06/24/2019
Function : 1.   Find matching [Lead], [Contact] record in Salesforce with the Eloqua ID (if available on
                Application record):
                (1) If a matched [Contact] record is found, create a new [Opportunity] record associated to the
                    [Account] of the [Contact] record and link the [Application] record under the newly created
                    [Opportunity] record.
                (2) If a matched [Lead] record is found, convert the [Lead] record to new [Account], [Contact]
                    and [Opportunity] then associate the [Application] record to the [Opportunity].
            2.  Find matching [Lead] [Contact] record in Salesforce with 100% matching criteria - email, first
                name, last name? <TBC - Searching Criteria>:
                1. If a matched [Contact] record is found, create a new [Opportunity] record associated to the
                   [Account] of the [Contact] record and link the [Application] record under the newly created
                   [Opportunity] record
                2. If a matched [Lead] record is found, convert the [Lead] record to new [Account], [Contact]
                   and [Opportunity] then associate the [Application] record to the [Opportunity].

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                06/24/2019                Version 1.0
*************************************************************************************/
public class ApplicationTriggerHandler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isInsert) {
            if(Trigger.isBefore) {
                for(Application__c application :(List<Application__c>)Trigger.new) {
                    if(application.Applicant_CGMInterest__c == 'Yes' || application.Applicant_OOCInterest__c == 'Yes') {
                        
                    }
                }
            }
            if(Trigger.isAfter) {
                // query lead convertstatus
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                for(Application__c application :(List<Application__c>)Trigger.new) {
                    DealwithMasterContact(application.Id,convertStatus.MasterLabel);
                }
            }
        }

        if(Trigger.isUpdate) {
            Set<String> IdSet = new Set<String>();
            List<Opportunity> opptylists = new List<Opportunity>();
            List<Application__c> applicatlist = (List<Application__c>)Trigger.new;
            for(Application__c applicat : applicatlist) {
                // Field assignment on oppty
                if(applicat.Opportunity__c != null) {
                    IdSet.add(applicat.Opportunity__c);
                }
            }

            if(IdSet.size() != 0) {
                List<Opportunity> opptylist = [SELECT Id,RecordType.DeveloperName,Admission_Status__c,APOL_Created_Date__c,APOL_Modified_Date__c,APOL_Status__c,Has_APOL__c,Completion_Percentage__c,StageName FROM Opportunity WHERE Id IN : IdSet];
                Map<String,Opportunity> OpportunityMap = new Map<String,Opportunity>();
                for(Opportunity oppty : opptylist) {
                    OpportunityMap.put(oppty.Id,oppty);
                }

                for(Application__c applicat : applicatlist) { 
                    Application__c oldapp = (Application__c)Trigger.oldMap.get(applicat.Id);
                    Opportunity oppty = OpportunityMap.get(applicat.Opportunity__c);
                    oppty.APOL_Created_Date__c = applicat.Application_CreatedDate__c;
                    oppty.APOL_Modified_Date__c = applicat.Application_LastModifiedDate__c;
                    oppty.APOL_Status__c = applicat.Application_APOLStatus__c;
                    oppty.Has_APOL__c = applicat.Application_IsAPOL__c;
                    oppty.Admission_Status__c = applicat.Admission_Prog_Status__c;
                    oppty.Completion_Percentage__c = applicat.Application_CompletionPercentage__c;
                    //opportunity record type
                    if(OpportunityMap.get(applicat.Opportunity__c).RecordType.DeveloperName == 'OEP_F2F') {
                        if(applicat.Application_CompletionPercentage__c >= 20 && applicat.Application_CompletionPercentage__c <= 60 && (oppty.StageName == 'New' || oppty.StageName == 'Initiating Contact' || oppty.StageName == 'Initial Conversation')) {
                            oppty.StageName = 'New RAS/APOL';
                        } 
                        else if(applicat.Application_CompletionPercentage__c > 60 && (oppty.StageName == 'New' || oppty.StageName == 'Initiating Contact' || oppty.StageName == 'Initial Conversation' || oppty.StageName == 'New RAS/APOL')) {
                            oppty.StageName = 'In-Progress Unqualified';
                        }
                        else if(applicat.Application_APOLStatus__c == 'Applied' && (oppty.StageName == 'New' || oppty.StageName == 'Initiating Contact' || oppty.StageName == 'Initial Conversion' || oppty.StageName == 'New RAS/APOL' || oppty.StageName == 'In-Progress Unqualified' || oppty.StageName == 'Advanced Conversation' || oppty.StageName == 'Expecting Application' || oppty.StageName == 'In-Progress Qualified')) {
                            oppty.StageName = 'Applied(AR/CO/INC)';
                        }
                    }
                    else if(OpportunityMap.get(applicat.Opportunity__c).RecordType.DeveloperName == 'OEP_Online') {
                        if(applicat.Application_CompletionPercentage__c >= 20 && applicat.Application_CompletionPercentage__c < 100 && (oppty.StageName == 'New' || oppty.StageName == 'Initiating Contact' || oppty.StageName == 'Initial Conversation')) {
                            oppty.StageName = 'In-Progress Unqualified';
                        } 
                        else if((applicat.Application_APOLStatus__c == 'Applied' || applicat.Application_CompletionPercentage__c == 100) && (oppty.StageName == 'New' || oppty.StageName == 'Initiating Contact' || oppty.StageName == 'Initial Conversation' || oppty.StageName == 'In-Progress Unqualified' || oppty.StageName == 'In-Progress Qualified' || oppty.StageName == 'Advanced Conversation without APOL')) {
                            oppty.StageName = 'Applied';
                        }
                    }
                    if(oldapp.Admission_Prog_Status__c != 'Admitted' && applicat.Admission_Prog_Status__c == 'Admitted' && oppty.StageName != 'Closed Lost') {
                        oppty.StageName = 'Closed Won';
                    }
                    opptylists.add(oppty);
                }
            }
            
            if(opptylists.size() > 0) {
                update opptylists;
            }
        }
    }

    @future
    public static void DealwithMasterContact (String applicationId,String masterlabel) {
        List<Application__c> application =  [SELECT Id,Application_Subplan__c,Applicant_Email__c,Applicant_FirstName__c,Applicant_LastName__c,Invoice_LastName__c,
                                            Invoice_Email__c,Invoice_FirstName__c,Sponsor_FirstName__c,Sponsor_Email__c,Sponsor_LastName__c,Opportunity__c,
                                            HR_LastName__c,HR_Email__c,HR_FirstName__c,Applicant_EloquaID__c,Invoice_CompanyName__c,Applicant_Dob__c,Applicant_Gender__c
                                            ,Company_Name__c,Applicant_Nationality__c,HR_Company__c,Sponsor_CompanyName__c,HR_Country__c,Invoice_Country__c,Sponsor_Country__c,
                                            Application_AdmitTerm__c,Application_Campus__c,Application_Plan__c     
                                            FROM Application__c 
                                            WHERE Id =: applicationId
                                            AND Opportunity__c = null];
        System.debug('application info ' + application);
        if(application.size() == 0) {
            return;
        }
        String custompricename = System.Label.Price_Book_Name;
        List<Contact> mastercontact = new List<Contact>();
        if(String.isNotBlank(application[0].Applicant_EloquaID__c)) {
            mastercontact = [SELECT Id, Name, FirstName, LastName, Email, AccountId,Account.Name,Account.RecordType.DeveloperName,ACG_Interest_Adv_Certificate_in_Gov__c,CGM_Interest__c,OOC_Interest__c
                                            FROM Contact
                                            WHERE Eloqua_Contact_ID__c =: application[0].Applicant_EloquaID__c
                                            OR (FirstName =: application[0].Applicant_FirstName__c AND LastName =: application[0].Applicant_LastName__c AND (Email =: application[0].Applicant_Email__c OR Home_Email__c =: application[0].Applicant_Email__c OR hed__WorkEmail__c =: application[0].Applicant_Email__c))];
        }else {
            mastercontact = [SELECT Id, Name, FirstName, LastName, Email, AccountId,Account.Name,Account.RecordType.DeveloperName,ACG_Interest_Adv_Certificate_in_Gov__c,CGM_Interest__c,OOC_Interest__c 
                                            FROM Contact
                                            WHERE FirstName =: application[0].Applicant_FirstName__c AND LastName =: application[0].Applicant_LastName__c AND (Email =: application[0].Applicant_Email__c OR Home_Email__c =: application[0].Applicant_Email__c OR hed__WorkEmail__c =: application[0].Applicant_Email__c)];
        }
        System.debug('mastercontact info: ' + mastercontact);
        List<Lead> leadlist = new List<Lead>();

        if(mastercontact.size() > 0 ) {
            //query contact role info
            List<OpportunityContactRole> rolelist = [SELECT Id,OpportunityId FROM OpportunityContactRole WHERE ContactId =: mastercontact[0].Id AND (Opportunity.RecordType.DeveloperName='OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
            System.debug('contact role info: '+rolelist);
            List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
            //query product info 
            List<Product2> prolist = [SELECT Id,Name,Programme__c,Programme__r.Name FROM Product2 WHERE Academic_Sub_Plan__c =: application[0].Application_Subplan__c AND Term__c=:application[0].Application_AdmitTerm__c AND Campus__c =: application[0].Application_Campus__c AND Academic_Plan__c=: application[0].Application_Plan__c AND Is_Programme__c=false limit 1]; 
            System.debug('product info: '+prolist);

            if(prolist.size() != 0) {
                itemlist = [SELECT Id,OpportunityId,Product2Id,Product2.Academic_Sub_Plan__c,Product2.Term__c,Product2.Campus__c,Product2.Academic_Plan__c FROM OpportunityLineItem WHERE Product2Id =: prolist[0].Id AND (Opportunity.RecordType.DeveloperName='OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
            }
            System.debug('itemlist info: ' + itemlist);
            String newopportunityId = '';
            Set<String> roleSet = new Set<String>();
            for(OpportunityContactRole role : rolelist) {
                roleSet.add(role.OpportunityId);
            }
            // search the opportunityId by contactrole and opportunityproduct
            for(OpportunityLineItem item : itemlist) {
                if(roleSet.contains(item.OpportunityId)) {
                    newopportunityId = item.OpportunityId;
                    break;
                }
            }
            System.debug(LoggingLevel.INFO, 'newopportunityId info: ' + newopportunityId);
            //if(String.isBlank(newopportunityId) && prolist.size() != 0 && itemlist.size() < 1 && prolist[0].Programme__c != null) {
            if(String.isBlank(newopportunityId) && prolist.size() != 0 && prolist[0].Programme__c != null) {
                itemlist = [SELECT Id, OpportunityId,Product2.Academic_Sub_Plan__c,Product2.Term__c,Product2.Campus__c,Product2.Academic_Plan__c FROM OpportunityLineItem WHERE Product2.Programme__c =: prolist[0].Programme__c AND (Opportunity.RecordType.DeveloperName='OEP_F2F' OR Opportunity.RecordType.DeveloperName = 'OEP_Online')];
                System.debug(LoggingLevel.INFO, '*** program: ' + itemlist);
                for(OpportunityLineItem item : itemlist) {
                    if(roleSet.contains(item.OpportunityId)) {
                        newopportunityId = item.OpportunityId;
                        break;
                    }
                }
                System.debug(LoggingLevel.INFO, 'newopportunityId 11111: ' + newopportunityId);
            }
            System.debug(LoggingLevel.DEBUG, '*** program product: ' + itemlist);
            if(!String.isBlank(newopportunityId)) {
                application[0].Opportunity__c = newopportunityId;
                update application;
                Opportunity newoppoty = [SELECT Id,Pricebook2Id,(SELECT Id,Product2.Academic_Sub_Plan__c,Product2.Term__c,Product2.Campus__c,Product2.Academic_Plan__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =: newopportunityId];
                //if the existed itemlist info not equals to application product info
                if(newoppoty.OpportunityLineItems.size() != 0){
                    if(newoppoty.OpportunityLineItems[0].Product2.Academic_Sub_Plan__c != application[0].Application_Subplan__c && newoppoty.OpportunityLineItems[0].Product2.Term__c != application[0].Application_AdmitTerm__c && newoppoty.OpportunityLineItems[0].Product2.Campus__c != application[0].Application_Campus__c && newoppoty.OpportunityLineItems[0].Product2.Academic_Plan__c != application[0].Application_Plan__c) {
                        delete newoppoty.OpportunityLineItems[0];
                        //get the pricebookId
                        // add opportuniy product
                        OpportunityLineItem items = new OpportunityLineItem();
                        items.OpportunityId = newoppoty.Id;
                        items.Product2Id = prolist[0].Id; 
                        items.Quantity = 1;
                        items.UnitPrice = 2000;
                        items.PricebookEntryId = [SELECT Id FROM PricebookEntry WHERE Product2Id =: items.Product2Id AND Pricebook2Id =: newoppoty.Pricebook2Id].Id;
                        insert items;
                    }
                }
            }
            else {
                Opportunity oppty = new Opportunity();
                oppty.AccountId = mastercontact[0].AccountId;
                //opportunity naming rule
                if(mastercontact[0].AccountId != null && mastercontact[0].Account.RecordType.DeveloperName == 'Business_Organization') {
                    oppty.Name = prolist[0].Name +'-'+ mastercontact[0].Account.Name+'-'+mastercontact[0].Name;
                }
                else {
                    oppty.Name = prolist[0].Name +'-'+mastercontact[0].Name;
                }
                oppty.StageName = 'New';
                oppty.Primary_Contact__c = mastercontact[0].Id;
                oppty.ACG_Interest__c = mastercontact[0].ACG_Interest_Adv_Certificate_in_Gov__c;
                oppty.OOC_Interest__c = mastercontact[0].OOC_Interest__c;
                oppty.CGM_Interest__c = mastercontact[0].CGM_Interest__c;
                oppty.CloseDate = Date.today().addDays(30);
                insert oppty;
                // modified the opportunity info
                application[0].Opportunity__c = oppty.Id;
                update application;

                //add oppoty product
                if(prolist.size() != 0) {
                    //update price book id to add oppoty product
                    String bookId = [SELECT Id, Name FROM Pricebook2 WHERE Name =: custompricename].Id;
                    Opportunity opptys = new Opportunity();
                    opptys.Id = oppty.Id;
                    opptys.Pricebook2Id = bookId;
                    update opptys;

                    List<PricebookEntry> entry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prolist[0].Id AND Pricebook2Id =: bookId];
                    OpportunityLineItem lineitem = new OpportunityLineItem();
                    lineitem.OpportunityId = oppty.Id;
                    lineitem.Product2Id = prolist[0].Id;
                    lineitem.Quantity = 1;
                    lineitem.UnitPrice = 2000;
                    if(entry.size() > 0) {
                        lineitem.PricebookEntryId = entry[0].Id;
                    }
                    else {
                        Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
                        PricebookEntry standardPrice = new PricebookEntry(
                        Pricebook2Id = stdPriceBook.Id, 
                        Product2Id = prolist[0].Id, 
                        UnitPrice = 12000, 
                        IsActive = true
                        );
                        insert standardPrice;
                        System.debug(LoggingLevel.INFO, '*** custom price book entry: ' );
                        PricebookEntry customPriceEntry = new PricebookEntry(
                        Pricebook2Id = bookId, 
                        Product2Id = prolist[0].Id, 
                        UnitPrice = 12000, 
                        IsActive = true
                        );
                        insert customPriceEntry;
                        lineitem.PricebookEntryId = customPriceEntry.Id;
                    }
                    insert lineitem;
                }
            }
        }
        else {
            if(String.isNotBlank(application[0].Applicant_EloquaID__c)) {
                leadlist = [SELECT Id,Name, IsConverted,ConvertedContactId,ConvertedOpportunityId FROM Lead WHERE Eloqua_Contact_ID__c =: application[0].Applicant_EloquaID__c 
                                OR (FirstName =: application[0].Applicant_FirstName__c AND LastName =: application[0].Applicant_LastName__c AND (Email =: application[0].Applicant_Email__c OR Home_Email__c =: application[0].Applicant_Email__c OR Work_Email__c =: application[0].Applicant_Email__c))];
            }
            else {
                leadlist = [SELECT Id,Name, IsConverted,ConvertedContactId,ConvertedOpportunityId FROM Lead WHERE FirstName =: application[0].Applicant_FirstName__c AND LastName =: application[0].Applicant_LastName__c AND (Email =: application[0].Applicant_Email__c OR Home_Email__c =: application[0].Applicant_Email__c OR Work_Email__c =: application[0].Applicant_Email__c)];
            }
            System.debug('leadlist info: '+leadlist);

            List<Product2> product = [SELECT Id,Name FROM Product2 WHERE Academic_Sub_Plan__c =: application[0].Application_Subplan__c AND Term__c=:application[0].Application_AdmitTerm__c AND Campus__c =: application[0].Application_Campus__c AND Academic_Plan__c=: application[0].Application_Plan__c];
            System.debug('product info: '+product);
            //query account info
            List<Account> acctlist = new List<Account>();
            String mastercompanyname = application[0].Applicant_FirstName__c+' '+application[0].Applicant_LastName__c+' Administrative Account';
            if(!String.isBlank(application[0].Company_Name__c)) {
                acctlist = [SELECT Id,Name FROM Account WHERE Name =: application[0].Company_Name__c AND BillingCountry =: application[0].Applicant_Nationality__c limit 1];
            }
            else {
                acctlist = [SELECT Id,Name FROM Account WHERE Name =: mastercompanyname AND BillingCountry =: application[0].Applicant_Nationality__c limit 1];
            }
            System.debug('acctlist Info: '+acctlist);
            //if lead existed
            if(leadlist.size() > 0) {
                //if the lead not converted
                if(!leadlist[0].IsConverted) {
                    Database.LeadConvert lc = new Database.LeadConvert();
                    if(acctlist.size() != 0) {
                        lc.setAccountId(acctlist[0].Id);
                    }
                    lc.setLeadId(leadlist[0].Id);
                    lc.setConvertedStatus(masterlabel);

                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    if(lcr.isSuccess()) {
                        application[0].Opportunity__c = lcr.getOpportunityId();
                        update application[0];
                        
                        if(product.size() != 0) {
                            //update price book id to add oppoty product
                            String bookId = [SELECT Id, Name FROM Pricebook2 WHERE Name =:custompricename].Id;
                            Opportunity opptys = [SELECT Id,Primary_Contact__c,Name,CurrencyIsoCode,Pricebook2Id FROM Opportunity WHERE Id =: lcr.getOpportunityId()];
                            opptys.Pricebook2Id = bookId;
                            opptys.Primary_Contact__c = lcr.getContactId();
                            //productname+contactname, cause by the account record type not business organization
                            opptys.Name = product[0].Name+'-'+application[0].Applicant_FirstName__c+' '+application[0].Applicant_LastName__c;
                            update opptys;

                            List<PricebookEntry> entry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: product[0].Id AND Pricebook2Id =: bookId AND CurrencyIsoCode =: opptys.CurrencyIsoCode];
                            OpportunityLineItem lineitem = new OpportunityLineItem();
                            lineitem.OpportunityId = lcr.getOpportunityId();
                            lineitem.Product2Id = product[0].Id;
                            lineitem.Quantity = 1;
                            lineitem.UnitPrice = 2000;
                            if(entry.size() > 0) {
                                lineitem.PricebookEntryId = entry[0].Id;
                            }
                            else {
                                Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
                                PricebookEntry standardPrice = new PricebookEntry(
                                    Pricebook2Id = stdPriceBook.Id, 
                                    Product2Id = product[0].Id, 
                                    UnitPrice = 12000, 
                                    IsActive = true,
                                    CurrencyIsoCode = opptys.CurrencyIsoCode
                                );
                                insert standardPrice;
                                System.debug(LoggingLevel.INFO, '*** custom price book entry: ' );
                                PricebookEntry customPriceEntry = new PricebookEntry(
                                    Pricebook2Id = bookId, 
                                    Product2Id = product[0].Id, 
                                    UnitPrice = 12000, 
                                    IsActive = true,
                                    CurrencyIsoCode = opptys.CurrencyIsoCode
                                );
                                insert customPriceEntry;
                                lineitem.PricebookEntryId = customPriceEntry.Id;
                            }
                            insert lineitem;
                        }
                    }
                }
                // if lead coverted
                else {
                    application[0].Opportunity__c = leadlist[0].ConvertedOpportunityId;
                    update application;
                }
            }
            //if lead not existed
            else {
                // new one lead
                Lead leads = new Lead();
                leads.LastName = application[0].Applicant_LastName__c;
                leads.FirstName = application[0].Applicant_FirstName__c;
                leads.Email = application[0].Applicant_Email__c;
                leads.LeadSource = 'INSEAD Website';
                leads.Gender__c = application[0].Applicant_Gender__c;
                leads.Company = application[0].Company_Name__c!=null ? application[0].Company_Name__c : application[0].Applicant_FirstName__c+' '+application[0].Applicant_LastName__c+' Administrative Account';
                leads.Date_of_Birth__c = application[0].Applicant_Dob__c;
                leads.Country = application[0].Applicant_Nationality__c;
                insert leads;
                
                Database.LeadConvert lc = new Database.LeadConvert();
                if(acctlist.size() != 0) {
                    lc.setAccountId(acctlist[0].Id);
                }
                lc.setLeadId(leads.Id);
                lc.setConvertedStatus(masterlabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                if(lcr.isSuccess()) { 
                    application[0].Opportunity__c = lcr.getOpportunityId();
                    update application[0];

                    if(product.size() != 0) {
                        //update price book id to add oppoty product
                        String bookId = [SELECT Id, Name FROM Pricebook2 WHERE Name =:custompricename].Id;
                        Opportunity opptys = [SELECT Id,Name,Primary_Contact__c,CurrencyIsoCode,Pricebook2Id FROM Opportunity WHERE Id =: lcr.getOpportunityId()];
                        opptys.Pricebook2Id = bookId;
                        opptys.Primary_Contact__c= lcr.getContactId();
                        //productname+contactname, cause by the account record type not business organization
                        opptys.Name = product[0].Name+'-'+application[0].Applicant_FirstName__c+' '+application[0].Applicant_LastName__c;
                        update opptys;

                        List<PricebookEntry> entry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: product[0].Id AND Pricebook2Id =: bookId AND CurrencyIsoCode =: opptys.CurrencyIsoCode];
                        OpportunityLineItem lineitem = new OpportunityLineItem();
                        lineitem.OpportunityId = lcr.getOpportunityId();
                        lineitem.Product2Id = product[0].Id;
                        lineitem.Quantity = 1;
                        lineitem.UnitPrice = 2000;
                        if(entry.size() > 0) {
                            lineitem.PricebookEntryId = entry[0].Id;
                        }
                        else {
                            Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
                            PricebookEntry standardPrice = new PricebookEntry(
                                Pricebook2Id = stdPriceBook.Id, 
                                Product2Id = product[0].Id, 
                                UnitPrice = 12000, 
                                IsActive = true,
                                CurrencyIsoCode = opptys.CurrencyIsoCode
                            );
                            insert standardPrice;
                            System.debug(LoggingLevel.INFO, '*** custom price book entry: ' );
                            PricebookEntry customPriceEntry = new PricebookEntry(
                                Pricebook2Id = bookId, 
                                Product2Id = product[0].Id, 
                                UnitPrice = 12000, 
                                IsActive = true,
                                CurrencyIsoCode = opptys.CurrencyIsoCode
                            );
                            insert customPriceEntry;
                            lineitem.PricebookEntryId = customPriceEntry.Id;
                        }
                        insert lineitem;
                    }
                }
            }
        }

        if(application[0].Invoice_FirstName__c != null && application[0].Invoice_LastName__c != null && application[0].Invoice_Email__c != null) {
            DealwithOtherContact(applicationId,application[0].Invoice_FirstName__c,application[0].Invoice_LastName__c,application[0].Invoice_Email__c,application[0].Invoice_CompanyName__c,application[0].Invoice_Country__c);
        }

        if(application[0].HR_FirstName__c != null && application[0].HR_LastName__c != null && application[0].HR_Email__c != null) {
            DealwithOtherContact(applicationId,application[0].HR_FirstName__c,application[0].HR_LastName__c,application[0].HR_Email__c,application[0].HR_Company__c,application[0].HR_Country__c);
        }

        if(application[0].Sponsor_FirstName__c != null && application[0].Sponsor_LastName__c != null && application[0].Sponsor_Email__c != null) {
            DealwithOtherContact(applicationId,application[0].Sponsor_FirstName__c,application[0].Sponsor_LastName__c,application[0].Sponsor_Email__c,application[0].Sponsor_CompanyName__c,application[0].Sponsor_Country__c);
        }

    }
    
    public static void DealwithOtherContact(String applicationId,String firstname,String lastname,String email,String company,String country) {
        //query account info
        List<Account> acctlist = [SELECT Id FROM Account WHERE Name =: company AND BillingCountry =: country limit 1]; 
        System.debug('account list info: '+ acctlist);
        //query application info
        Application__c applicat = [SELECT Id,Opportunity__c,Applicant_FirstName__c,Applicant_LastName__c,Applicant_Email__c FROM Application__c WHERE Id =: applicationId]; 
        System.debug('applicat info: '+applicat);
        //query master contact info
        List<Contact> mastercontlist = [SELECT Id FROM Contact WHERE FirstName =: applicat.Applicant_FirstName__c AND LastName =: applicat.Applicant_LastName__c AND Email =: applicat.Applicant_Email__c]; 
        System.debug('master contact info: '+mastercontlist);
        //query other contact info
        List<Contact> contlist = [SELECT Id FROM Contact WHERE FirstName =: firstname AND LastName =: lastname AND Email =: email limit 1];
        System.debug('other contact info: '+contlist);

        if(acctlist.size() != 0) {
            if(contlist.size() != 0 && contlist[0].Id != mastercontlist[0].Id) {
                OpportunityContactRole role = new OpportunityContactRole ();
                role.OpportunityId = applicat.Opportunity__c;
                role.ContactId = contlist[0].Id;
                insert role;

                List<hed__Relationship__c> shiplist = [SELECT Id FROM hed__Relationship__c WHERE hed__Contact__c =: mastercontlist[0].Id AND hed__RelatedContact__c =: contlist[0].Id];
                if(shiplist.size() == 0) {
                    hed__Relationship__c relationship = new hed__Relationship__c();
                    relationship.hed__Contact__c = mastercontlist[0].Id;
                    relationship.hed__RelatedContact__c = contlist[0].Id;
                    insert relationship;
                }
            }
            else if(contlist.size() == 0) {
                Contact cont = new Contact();
                cont.AccountId = acctlist[0].Id;
                cont.FirstName = firstname;
                cont.LastName = lastname;
                cont.Email = email;
                insert cont;

                OpportunityContactRole role = new OpportunityContactRole ();
                role.OpportunityId = applicat.Opportunity__c;
                role.ContactId = cont.Id;
                insert role;

                hed__Relationship__c relationship = new hed__Relationship__c();
                relationship.hed__Contact__c = mastercontlist[0].Id;
                relationship.hed__RelatedContact__c =cont.Id;
                insert relationship;
            }
        }
        else {
            //company name not equal  null ,then the new account record type equal to Bussiness Organization
            if(company != null) {
                Account acct = new Account();
                acct.Name = company;
                acct.BillingCountry = country;
                acct.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Organization'].Id; 
                insert acct;
                if(contlist.size() != 0 && contlist[0].Id != mastercontlist[0].Id) {
                    OpportunityContactRole role = new OpportunityContactRole ();
                    role.OpportunityId = applicat.Opportunity__c;
                    role.ContactId = contlist[0].Id;
                    insert role;

                    List<hed__Relationship__c> shiplist = [SELECT Id FROM hed__Relationship__c WHERE hed__Contact__c =: mastercontlist[0].Id AND hed__RelatedContact__c =: contlist[0].Id];
                    if(shiplist.size() == 0) {
                        hed__Relationship__c relationship = new hed__Relationship__c();
                        relationship.hed__Contact__c = mastercontlist[0].Id;
                        relationship.hed__RelatedContact__c = contlist[0].Id;
                        insert relationship;
                    }
                }
                else if(contlist.size() == 0) {
                    Contact cont = new Contact();
                    cont.AccountId = acct.Id;
                    cont.FirstName = firstname;
                    cont.LastName = lastname;
                    cont.Email = email;
                    insert cont;

                    OpportunityContactRole role = new OpportunityContactRole ();
                    role.OpportunityId = applicat.Opportunity__c;
                    role.ContactId = cont.Id;
                    insert role;

                    hed__Relationship__c relationship = new hed__Relationship__c();
                    relationship.hed__Contact__c = mastercontlist[0].Id;
                    relationship.hed__RelatedContact__c =cont.Id;
                    insert relationship;
                }
            }
            else {
                if(contlist.size() != 0 && contlist[0].Id != mastercontlist[0].Id) {
                    OpportunityContactRole role = new OpportunityContactRole ();
                    role.OpportunityId = applicat.Opportunity__c;
                    role.ContactId = contlist[0].Id;
                    insert role;

                    List<hed__Relationship__c> shiplist = [SELECT Id FROM hed__Relationship__c WHERE hed__Contact__c =: mastercontlist[0].Id AND hed__RelatedContact__c =: contlist[0].Id];
                    if(shiplist.size() == 0) {
                        hed__Relationship__c relationship = new hed__Relationship__c();
                        relationship.hed__Contact__c = mastercontlist[0].Id;
                        relationship.hed__RelatedContact__c = contlist[0].Id;
                        insert relationship;
                    }
                }
                else if(contlist.size() == 0) {
                    Contact cont = new Contact();
                    cont.FirstName = firstname;
                    cont.LastName = lastname;
                    cont.Email = email;
                    insert cont;

                    OpportunityContactRole role = new OpportunityContactRole ();
                    role.OpportunityId = applicat.Opportunity__c;
                    role.ContactId = cont.Id;
                    insert role;

                    hed__Relationship__c relationship = new hed__Relationship__c();
                    relationship.hed__Contact__c = mastercontlist[0].Id;
                    relationship.hed__RelatedContact__c =cont.Id;
                    insert relationship;
                }
            }
        }   
    }
}