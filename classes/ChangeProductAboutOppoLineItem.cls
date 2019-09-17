/**************************************************************************************
Class Name:  ChangeProductAboutOppoLineItem
Version     : 1.0 
Created Date    : 06/06/2019
Function    : when change the product of Opportunity Product, will create one new record about Opportunity Product, and delete the old record

Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             06/06/2019               Version 1.0
*************************************************************************************/

public class ChangeProductAboutOppoLineItem {
    //Load all Opportunity Product of Opportunity 
    @AuraEnabled
    public static String InitData(String recordId) {
        String result = '';
        Opportunity oppty = [select Id,RecordType.DeveloperName from Opportunity where Id =: recordId];

        OpportunityInfo info = new OpportunityInfo();
        if(oppty.RecordType.DeveloperName.contains('CSP')) {
            info.OpptyRecordTypeName = 'CSP';
        }
        else if (oppty.RecordType.DeveloperName.contains('OEP')){
            info.OpptyRecordTypeName = 'OEP';
        }        
        //query the Opportunity Product Info
        List<OpportunityLineItem>   olditemlist = [select  Id,
                                                           PricebookEntryId,
                                                           Product2Id,
                                                           Product2.Name
                                                           from OpportunityLineItem
                                                           where OpportunityId =: recordId];
        System.debug(LoggingLevel.INFO, 'OldItemlist Info : ' + olditemlist);
        //olditemlist not empty
        if(olditemlist.size() > 0) {
            for(OpportunityLineItem olditem : olditemlist) {
                OldOppoLineItem retitem = new OldOppoLineItem();
                retitem.OpportunityLineItemId = olditem.Id;
                retitem.ProductName = olditem.Product2.Name;
                retitem.ProductId = olditem.Product2Id;
                retitem.PricebookEntryId = olditem.PricebookEntryId;        
                info.lineitemlist.add(retitem);
            }
        }
        //olditemlist empty
        else {
            OldOppoLineItem inititem = new OldOppoLineItem();   
            inititem.OpportunityLineItemId = '';
            inititem.ProductName = 'No Opportunity Product';
            inititem.ProductId = '';
            inititem.PricebookEntryId = '';
            info.lineitemlist.add(inititem);
        }
        result = JSON.serialize(info);
        return result;
    }

    // create the new opportunity product,then delete old item
    @AuraEnabled
    public static String CreateOpportunityProduct(String productId,String changereason,String oppolineitemId) {
        String result = '';
        System.debug('!!!!!!!!!!!'+oppolineitemId);
        //query the old opportunity product info
        if(oppolineitemId == '') {
            result = 'No';
            return result;
        }
        OpportunityLineItem olditem = [select OpportunityId,Discount, PricebookEntryId, Product2Id, Quantity, TotalPrice, UnitPrice, 
                                                ServiceDate, Description, Change_Reason__c, Delivered__c, Delivery_Mode__c, Prep_Days__c, Standard_Delivery_Days__c, 
                                                Start_Date__c, End_Date__c, Delivery_Site__c,Financial_Location__c,Coaching_Rate__c,Coaching_Days__c, 
                                                Follow_up_Project_action_learning_revenu__c, Follow_up_coaching_project_support_reven__c, Virtual_Online_Learning_Webinar_revenue__c, 
                                                Any_other_additional_revenue__c, Additional_description__c, Delivery_Rate__c, Prep_Daily_Rate__c, Total_Number_of_Seats__c, Number_of_Enrolments__c, 
                                                Number_of_Reserved_Seats__c, Number_of_Available_Seats__c, Manual_Price__c,Opportunity.Pricebook2Id 
                                                from OpportunityLineItem 
                                                where Id =: oppolineitemId];
        System.debug(LoggingLevel.INFO, 'Olditem Info : ' + olditem);
        Savepoint sp = Database.setSavepoint();
        //the new record copy infor from old item
        OpportunityLineItem newitem = new OpportunityLineItem();
        newitem.OpportunityId = olditem.OpportunityId;
        newitem.Product2Id = productId;
        newitem.Previously_Changed_Product__c = olditem.Product2Id;
        newitem.Change_Reason__c = changereason;
        List<PricebookEntry> entrylist = [select Id from PricebookEntry where Pricebook2Id=:olditem.Opportunity.Pricebook2Id and Product2Id=: productId];
        if(entrylist.size() > 0 ) {
            newitem.PricebookEntryId = entrylist[0].Id;
        }
        else {
            Pricebook2 stdPriceBook = [Select Id, Name From Pricebook2 Where isStandard = true limit 1];
            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = stdPriceBook.Id, 
            Product2Id = productId, 
            UnitPrice = 12000, 
            IsActive = true
            );
            insert standardPrice;
            
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = olditem.Opportunity.Pricebook2Id;
            entry.Product2Id = productId;
            entry.UnitPrice = 12000;
            entry.IsActive=true;
            insert entry;
            newitem.PricebookEntryId = entry.Id;
        }
        newitem.Quantity = olditem.Quantity;
        newitem.UnitPrice = olditem.UnitPrice;
        newitem.Description = olditem.Description;
        newitem.Additional_description__c = olditem.Additional_description__c;
        newitem.Any_other_additional_revenue__c = olditem.Any_other_additional_revenue__c;
        newitem.Coaching_Rate__c = olditem.Coaching_Rate__c;
        newitem.Coaching_Days__c = olditem.Coaching_Days__c;
        newitem.ServiceDate = olditem.ServiceDate;
        newitem.Delivered__c = olditem.Delivered__c;
        newitem.Delivery_Mode__c = olditem.Delivery_Mode__c;
        newitem.Delivery_Rate__c = olditem.Delivery_Rate__c;
        newitem.Delivery_Site__c = olditem.Delivery_Site__c;
        newitem.Discount = olditem.Discount;
        newitem.Financial_Location__c = olditem.Financial_Location__c;
        newitem.Follow_up_Project_action_learning_revenu__c = olditem.Follow_up_Project_action_learning_revenu__c;
        newitem.Manual_Price__c = olditem.Manual_Price__c;
        newitem.Number_of_Available_Seats__c = olditem.Number_of_Available_Seats__c;
        newitem.Number_of_Enrolments__c = olditem.Number_of_Enrolments__c;
        newitem.Number_of_Reserved_Seats__c = olditem.Number_of_Reserved_Seats__c;
        newitem.Prep_Daily_Rate__c = olditem.Prep_Daily_Rate__c;
        newitem.Prep_Days__c = olditem.Prep_Days__c;
        newitem.Standard_Delivery_Days__c = olditem.Standard_Delivery_Days__c;
        newitem.Start_Date__c = olditem.Start_Date__c;
        newitem.Total_Number_of_Seats__c = olditem.Total_Number_of_Seats__c;
        newitem.Virtual_Online_Learning_Webinar_revenue__c = olditem.Virtual_Online_Learning_Webinar_revenue__c;

        try {
            insert newitem;
            System.debug(LoggingLevel.INFO, 'new item Id : ' + newitem.Id);
            result = newitem.Id;
            //after inserted successed, then delete the old opportunity product
            delete olditem;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, 'Exception Message : ' + e.getMessage());
            result = e.getMessage();
            Database.rollback(sp);
        }
        return result;
    }

    public class OpportunityInfo {
        @AuraEnabled
        public String OpptyRecordTypeName;
        @AuraEnabled
        public List<OldOppoLineItem> lineitemlist = new List<OldOppoLineItem>();
    }

    //Opportunity Product Infor
    public class OldOppoLineItem {
        @AuraEnabled
        public String OpportunityLineItemId;
        @AuraEnabled  
        public String ProductName;
        @AuraEnabled  
        public String ProductId;
        @AuraEnabled
        public String PricebookEntryId;
    }

    //Product Info
    public class ProductInfo {
        @AuraEnabled  
        public String ProductName;
        @AuraEnabled  
        public String ProductId;
    }
}