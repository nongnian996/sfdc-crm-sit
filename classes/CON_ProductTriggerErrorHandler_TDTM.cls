public class CON_ProductTriggerErrorHandler_TDTM implements Triggers.Handler {
    public void handle() {
        if(Trigger.isUpdate) {
            //compare ModifiedDate_by_CSO__c
            for(Product2 product : (List<Product2>)Trigger.new) {
                Product2 oldproduct = (Product2)Trigger.oldMap.get(product.Id);
                // the new record is not the latest
                if(product.ModifiedDate_by_CSO__c!=null && oldproduct.ModifiedDate_by_CSO__c!=null && product.ModifiedDate_by_CSO__c < oldproduct.ModifiedDate_by_CSO__c) {
                   product.addError(errorMessage('CSO',oldproduct.ModifiedDate_by_CSO__c,product.ModifiedDate_by_CSO__c));
                }
            }
        }
    }

    public static String errorMessage(String type,Datetime oldtime,Datetime newtime) {
        String errmsg = System.Label.Error_Trigger_Handler_Message;
        return errmsg + type +': can\'t update this record cause ' + oldtime +' > ' + newtime;
    }
}