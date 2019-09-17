/************************************************************************************
Class Name : AddChildOpportunities
Version : 1.0 
Created Date : 06/08/2019
Function : Auto add child opportunity   

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                08/06/2019                Version 1.0
*************************************************************************************/
public class AddChildOpportunities {
    //orginal oppty product list
    public OpportunityLineItem items {get;set;}
    public List<OpportunityLineItem> opptyprodlist {get;set;}
    public String contactid {get;set;}
    public AddChildOpportunities(ApexPages.StandardController controller) {
        ID recordid = controller.getId();
        items = [SELECT ID,Product2Id,Product2.Name,OpportunityId,Opportunity.CurrencyIsoCode,HR_Seats__c,Particpant_Full_Name__c,PricebookEntryId FROM OpportunityLineItem WHERE Id=: recordid];
        System.debug('lineitem info: '+items);
        opptyprodlist = new List<OpportunityLineItem>();
        if(items.HR_Seats__c != null && items.HR_Seats__c != 0) {
            List<Opportunity> opptylist = [SELECT Id FROM Opportunity WHERE CSP_Parent_Opportunity__c =: items.OpportunityId];
            if(opptylist.size() == 0) {
                for(Integer i=0; i< items.HR_Seats__c; i++) {
                    OpportunityLineItem prod = new OpportunityLineItem(); 
                    prod.Product2Id = items.Product2Id;
                    prod.Particpant_Full_Name__c = null;
                    opptyprodlist.add(prod);
                }
            }
            else {
                Map<String,String> roleMap = new Map<String,String>();
                Set<String> IdSet = new Set<String>();
                for(Opportunity oppty : opptylist) {
                    IdSet.add(oppty.Id);
                }
                List<OpportunityContactRole> rolelist = [SELECT Id,ContactId,OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN : IdSet];
                for(OpportunityContactRole role : rolelist) {
                    roleMap.put(role.OpportunityId,role.ContactId);
                }
                if(roleMap.keySet().size() == items.HR_Seats__c) {
                    for(String keys : roleMap.keySet()) {
                        OpportunityLineItem prod = new OpportunityLineItem(); 
                        prod.Product2Id = items.Product2Id;
                        prod.Particpant_Full_Name__c = roleMap.get(keys);
                        opptyprodlist.add(prod);
                    }
                }
                else {
                    for(String keys : roleMap.keySet()) {
                        OpportunityLineItem prod = new OpportunityLineItem(); 
                        prod.Product2Id = items.Product2Id;
                        prod.Particpant_Full_Name__c = roleMap.get(keys);
                        opptyprodlist.add(prod);
                    }
                    for(Integer i=0; i< items.HR_Seats__c-roleMap.keySet().size(); i++) {
                        OpportunityLineItem prod = new OpportunityLineItem(); 
                        prod.Product2Id = items.Product2Id;
                        prod.Particpant_Full_Name__c = null;
                        opptyprodlist.add(prod);
                    }
                }
            }
        }   
    }

    public PageReference save() {
        try {
            Map<String,Contact> contMap = new Map<String,Contact>();
            Set<String> contSet = new Set<String>(); 
            for(OpportunityLineItem lineitem : opptyprodlist) {
                if(!contSet.contains(lineitem.Particpant_Full_Name__c) && lineitem.Particpant_Full_Name__c != null) {
                    contSet.add(lineitem.Particpant_Full_Name__c);
                }
                else if(contSet.contains(lineitem.Particpant_Full_Name__c) && lineitem.Particpant_Full_Name__c != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'At least two identical contacts'));
                    return null;
                }
            }

            List<Contact> contlist = [SELECT Id,Name,FirstName,LastName,AccountId,Account.Name,Account.RecordType.DeveloperName,ACG_Interest_Adv_Certificate_in_Gov__c,CGM_Interest__c,OOC_Interest__c  FROM Contact WHERE Id IN : contSet];
            System.debug('contlist info: '+contlist);
            if(contlist.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter at least one contact'));
                return null;
            }
            for(Contact cont : contlist) {
                contMap.put(cont.Id,cont);
            }
            //must check if it already existed before create
            List<Opportunity> oppotylist = [SELECT Id,Name FROM Opportunity WHERE CSP_Parent_Opportunity__c=: items.OpportunityId AND RecordType.DeveloperName = 'OEP_Online'];
            System.debug('existed opportunity info: '+oppotylist);
            Map<String,String> existedMap = new Map<String,String>();
            for(Opportunity oppty : oppotylist) {
                existedMap.put(oppty.Name,oppty.Id);
            }

            //create new child opportunity
            ID typeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'OEP_Online'].Id;
            List<Opportunity> opptylist = new List<Opportunity>();
            for(OpportunityLineItem lineitem : opptyprodlist) {
                if(lineitem.Particpant_Full_Name__c != null) {
                    Opportunity oppty = new Opportunity();
                    if(existedMap.keySet().size() == 0) {
                        oppty.CSP_Parent_Opportunity__c = items.OpportunityId;
                        if(contMap.get(lineitem.Particpant_Full_Name__c).AccountId != null && contMap.get(lineitem.Particpant_Full_Name__c).Account.RecordType.DeveloperName == 'Business_Organization') {
                            oppty.Name = items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Account.Name+'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name;
                        }
                        else {
                            oppty.Name = items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name;
                        }
                        oppty.CurrencyIsoCode = items.Opportunity.CurrencyIsoCode;
                        oppty.CloseDate = Date.today().addDays(30);
                        oppty.StageName = 'New';
                        oppty.Primary_Contact__c = lineitem.Particpant_Full_Name__c;
                        oppty.RecordTypeId = typeId;
                        oppty.AccountId = contMap.get(lineitem.Particpant_Full_Name__c).AccountId;
                        oppty.ACG_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).ACG_Interest_Adv_Certificate_in_Gov__c;
                        oppty.CGM_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).CGM_Interest__c;
                        oppty.OOC_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).OOC_Interest__c;
                        opptylist.add(oppty);
                    }
                    else if(existedMap.keySet().size() != 0 && !existedMap.containsKey(items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name) && !existedMap.containsKey(items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Account.Name+'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name)) {
                        oppty.CSP_Parent_Opportunity__c = items.OpportunityId;
                        if(contMap.get(lineitem.Particpant_Full_Name__c).AccountId != null && contMap.get(lineitem.Particpant_Full_Name__c).Account.RecordType.DeveloperName == 'Business_Organization') {
                            oppty.Name = items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Account.Name+'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name;
                        }
                        else {
                            oppty.Name = items.Product2.Name +'-'+contMap.get(lineitem.Particpant_Full_Name__c).Name;
                        }
                        oppty.CurrencyIsoCode = items.Opportunity.CurrencyIsoCode;
                        oppty.CloseDate = Date.today().addDays(30);
                        oppty.StageName = 'New';
                        oppty.Primary_Contact__c = lineitem.Particpant_Full_Name__c;
                        oppty.RecordTypeId = typeId;
                        oppty.AccountId = contMap.get(lineitem.Particpant_Full_Name__c).AccountId;
                        oppty.ACG_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).ACG_Interest_Adv_Certificate_in_Gov__c;
                        oppty.CGM_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).CGM_Interest__c;
                        oppty.OOC_Interest__c = contMap.get(lineitem.Particpant_Full_Name__c).OOC_Interest__c;
                        opptylist.add(oppty);
                    }
                }
            }
            System.debug('insert opportunity list'+opptylist);
            if(opptylist.size() != 0) {
                Database.SaveResult[] srList = Database.insert(opptylist);
                //create opportunity product
                List<OpportunityLineItem> productlist = new List<OpportunityLineItem>();
                for(Integer i=0; i<opptyprodlist.size(); i++) {
                    if(opptyprodlist[i].Particpant_Full_Name__c != null) {
                        if(srList[i].isSuccess()) {
                            OpportunityLineItem newitem = new OpportunityLineItem();
                            newitem.Product2Id = opptyprodlist[i].Product2Id;
                            newitem.OpportunityId = srList[i].getId();
                            newitem.PricebookEntryId = items.PricebookEntryId;
                            newitem.Quantity = 1;
                            productlist.add(newitem);
                        }
                    }
                }
                insert productlist;
            }
            PageReference opptyPage = new ApexPages.StandardController(items).view();
            opptyPage.setRedirect(true);
            return opptyPage;
        }
        catch (Exception e) {
            System.debug('exception info: '+e.getMessage() +'@@@@@'+e.getLineNumber());
            if(e.getMessage().contains('Parent Opportunity: Value does not exist or does not match filter criteria')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Opportunity which related  with this opportunity product not Parent Opportunity'));
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
            return null;
        }
    }

    public PageReference cancel() {
        PageReference opptyPage = new ApexPages.StandardController(items).view();
        opptyPage.setRedirect(true);
        return opptyPage;
    }

    public PageReference remove() {
        System.debug('contactid: '+contactid);
        if(items.HR_Seats__c > 0) {
            items.HR_Seats__c += -1;
            update items; 
            if(contactid != '') {
                List<OpportunityContactRole> opptyproduct = [SELECT Id,OpportunityId FROM OpportunityContactRole WHERE ContactId =: contactid AND Opportunity.CSP_Parent_Opportunity__c =: items.OpportunityId];
                if(opptyproduct.size() != 0) {
                    Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id=:opptyproduct[0].OpportunityId];
                    delete oppty;
                }
            }
            PageReference opptyPage = new ApexPages.StandardController(items).view();
            opptyPage.setRedirect(true);
            return opptyPage;
        }
        return null;
    }
}