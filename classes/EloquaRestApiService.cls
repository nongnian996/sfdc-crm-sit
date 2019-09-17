public with sharing class EloquaRestApiService {
    
    public static final String DefaultPartition = 'local.Insead';

    public static final String TokenCacheKey = 'EloquaToken';

    // Org partition object
    static Cache.OrgPartition orgPartition = Cache.Org.getPartition(DefaultPartition);

    @future(callout=true)
    public static void updateEloquaContact(String email, String leadId) {

        System.debug(LoggingLevel.INFO, '*** leadId: ' + leadId);

        String token = EloquaRestApiService.requestEloquaToken();

        EloquaContactList contactList = retrieveContactList(email, token);

        if(contactList == null || (contactList != null && contactList.elements.size() < 1)) return;

        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String url = setting.update_contact_url__c;
        EloquaContactList.Element element = contactList.elements[0];
        url = url.replace('{id}', element.id);
        String sfdcLeadId = '', sfdcContactId = '', leadStatus = '', eloquaContactId = '', sfdcAccountId = '';
        //find sfdc lead id from eloqua contact
        for(EloquaContactList.FieldValue field : element.fieldValues) {
            if(field.id == '100048') {
                System.debug(LoggingLevel.INFO, '*** lead status: ' + field.value);
                leadStatus = field.value;
            }
            if(field.id == '100024') {
                System.debug(LoggingLevel.INFO, '*** sfdc lead id : ' + field.value);
                sfdcLeadId = field.value;
            }
            if(field.id == '100023') {
                System.debug(LoggingLevel.INFO, '*** sfdc contact id : ' + field.value);
                sfdcContactId = field.value;
            }
            if(field.id == '100032') {
                System.debug(LoggingLevel.INFO, '*** eloqua contact id : ' + field.value);
                eloquaContactId = field.value;
            }
            if(field.id == '100033') {
                System.debug(LoggingLevel.INFO, '*** eloqua account id : ' + field.value);
                sfdcAccountId = field.value;
            }
        }

        if(String.isBlank(sfdcLeadId)) return;
        
        List<Lead> leadList = [Select Id, ConvertedContactId, ConvertedAccountId From Lead Where Id =: sfdcLeadId And Status = 'Converted'];

        if(leadList.size() < 1) return;

        if(leadList[0].Eloqua_Contact_ID__c != eloquaContactId) return;

        System.debug(LoggingLevel.INFO, '*** url: ' + url);
        String body = '{';
        body += '"emailAddress":"' + email + '",';
        body += '"id":"' + element.id + '",';
        // body += '"businessPhone":"555-555-5556",';
        body += '"fieldValues": [';
        body += '   {';
        body += '       "type": "FieldValue",';
        body += '       "id": "100023",';
        body += '       "value": "' + leadList[0].ConvertedContactId + '"';
        body += '   },';
        body += '   {';
        body += '       "type": "FieldValue",';
        body += '       "id": "100048",';
        body += '       "value": "Converted"';
        body += '   },';
        body += '   {';
        body += '       "type": "FieldValue",';
        body += '       "id": "100033",';
        body += '       "value": "' + leadList[0].ConvertedAccountId + '"';
        body += '   }';
        body += ']';
        body += '}';
        System.debug(LoggingLevel.INFO, '*** body: ' + body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        // res.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());
    }

    @future(callout=true)
    public static void deleteEloquaContact(String email, ID recordId, String eloquaContId, ID masterRecordId) {

        System.debug(LoggingLevel.INFO, '*** email: ' + email);

        System.debug(LoggingLevel.INFO, '*** recordId: ' + recordId);

        System.debug(LoggingLevel.INFO, '*** eloquaContId: ' + eloquaContId);

        String token = EloquaRestApiService.requestEloquaToken();

        EloquaContactList contactList = retrieveContactList(email, token);

        if(contactList.elements.size() < 1) return;
        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String url = setting.delete_contact_url__c;
        EloquaContactList.Element element = contactList.elements[0];
        url = url.replace('{id}', element.id);
        String sfdcLeadId = '', sfdcContactId = '', leadStatus = '', eloquaContactId = '', sfdcAccountId = '';
        //find sfdc lead id from eloqua contact
        for(EloquaContactList.FieldValue field : element.fieldValues) {
            if(field.id == '100048') {
                System.debug(LoggingLevel.INFO, '*** lead status: ' + field.value);
                leadStatus = field.value;
            }
            if(field.id == '100024') {
                System.debug(LoggingLevel.INFO, '*** sfdc lead id : ' + field.value);
                sfdcLeadId = field.value;
            }
            if(field.id == '100023') {
                System.debug(LoggingLevel.INFO, '*** sfdc contact id : ' + field.value);
                sfdcContactId = field.value;
            }
            if(field.id == '100032') {
                System.debug(LoggingLevel.INFO, '*** eloqua contact id : ' + field.value);
                eloquaContactId = field.value;
            }
            if(field.id == '100033') {
                System.debug(LoggingLevel.INFO, '*** eloqua account id : ' + field.value);
                sfdcAccountId = field.value;
            }
        }
        //if there's a merge action, and email as the same as master email, then don't delete from eloqua
        if(!String.isBlank(masterRecordId) && masterRecordId.getSobjectType().getDescribe().getName() == 'Lead') {
            List<Lead> leadList = [Select Id, Email, Eloqua_Contact_ID__c From Lead Where Id =: masterRecordId];
            if(leadList != null && leadList.size() > 0 && email == leadList[0].Email) {
                return;
            }
        }
        //if there's a merge action, and email as the same as master email, then don't delete from eloqua
        if(!String.isBlank(masterRecordId) && masterRecordId.getSobjectType().getDescribe().getName() == 'Contact') {
            List<Contact> contList = [Select Id, Email, Eloqua_Contact_ID__c From Contact Where Id =: masterRecordId];
            if(contList != null && contList.size() > 0 && email == contList[0].Email) {
                return;
            }
        }
        // if(leadList.size() < 1) return;

        // if(eloquaContId != eloquaContactId) return;
        if(recordId.getSobjectType().getDescribe().getName() == 'Lead' 
                    && (!String.isBlank(sfdcContactId) 
                    || String.isBlank(sfdcLeadId) 
                    || !sfdcLeadId.containsIgnoreCase(('' + recordId))
                    || 'Converted' == leadStatus
                    || eloquaContId != eloquaContactId)) 
        {
            System.debug(LoggingLevel.INFO, '*** : can not delete lead');
            return;
        }
        if(recordId.getSobjectType().getDescribe().getName() == 'Contact' 
            && (String.isBlank(sfdcContactId) 
                || eloquaContId != eloquaContactId
                || !sfdcContactId.containsIgnoreCase(('' + recordId)))) {
            System.debug(LoggingLevel.INFO, '*** : can not delete contact');
            return;
        }
        System.debug(LoggingLevel.INFO, '*** url: ' + url);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('DELETE');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        // req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        // res.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        System.debug(LoggingLevel.INFO, '*** res status: ' + res.getStatus());
        System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());
    }

    @future(callout=true)
    public static void deleteEloquaAccount(ID recordId) {

        System.debug(LoggingLevel.INFO, '*** recordId: ' + recordId);

        String token = EloquaRestApiService.requestEloquaToken();

        EloquaAccountList eloquaAcctList = retrieveAccountList(recordId, token);

        if(eloquaAcctList.elements.size() < 1) return;
        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String url = setting.delete_account_url__c;
        //find matching account record id
        String deletedAccountId = eloquaAcctList.elements[0].id;
        System.debug(LoggingLevel.INFO, '*** deletedAccountId: ' + deletedAccountId);
        /***
        for(EloquaAccountList.Element element : eloquaAcctList.elements) {
            String eloquaCompanyId = '', sfdcAccountId = '';
            //find sfdc lead id from eloqua contact
            for(EloquaAccountList.FieldValue field : element.fieldValues) {
                if(field.id == '100094') {
                    System.debug(LoggingLevel.INFO, '*** lead status: ' + field.value);
                    eloquaCompanyId = field.value;
                }
                if(field.id == '100100') {
                    System.debug(LoggingLevel.INFO, '*** sfdc lead id : ' + field.value);
                    sfdcAccountId = field.value;
                }
                if(!String.isBlank(sfdcAccountId) && sfdcAccountId.containsIgnoreCase('' + recordId)) {
                    deletedAccountId = element.id;
                    break;
                }
            }
        }
        
        if(String.isBlank(deletedAccountId)) return;
        ***/
        url = url.replace('{id}', deletedAccountId);

        doDelete(url, token);
        
    }

    public static void doDelete(String reqUrl,String token) {
        System.debug(LoggingLevel.INFO, '*** reqUrl: ' + reqUrl);
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(reqUrl);
            req.setMethod('DELETE');
            req.setTimeout(120000);
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Content-Type', 'application/json');
            // req.setBody(body);
            Http http = new Http();
            HTTPResponse res = new HttpResponse();
            res = http.send(req);
            System.debug(LoggingLevel.INFO, '*** res status: ' + res.getStatus());
            System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());
        }catch(Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
        }
    }

    public static EloquaAccountList retrieveAccountList(Id recordId, String token) {
        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String url = setting.retrieve_account_url__c + '?depth=complete&search=M_SFDCAccountID=\'' + recordId +'\'';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        // req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        // res.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());
        EloquaAccountList eloquaAcctList = null;
        if(res.getStatus() == 'OK' && res.getStatusCode() == 200) {
            eloquaAcctList = EloquaAccountList.parse(res.getBody());
        }
        // System.debug(LoggingLevel.INFO, '*** eloquaAcctList: ' + eloquaAcctList);
        return eloquaAcctList;
    }

    public static EloquaContactList retrieveContactList(String email, String token) {
        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String url = setting.retrieve_contact_url__c + '?depth=complete&search=emailAddress=\'' + email +'\'';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Bearer ' + token);
        // req.setHeader('Content-Type', 'application/json');
        // req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        // res.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        EloquaContactList cont = null;
        if(res.getStatus() == 'OK' && res.getStatusCode() == 200) {
            cont = EloquaContactList.parse(res.getBody());
        }
        
        // System.debug(LoggingLevel.INFO, '*** cont: ' + cont);
        return cont;
    }

    public static String getLoginSession() {
        EloquaIntegrationSetting__c setting = EloquaIntegrationSetting__c.getInstance();
        String Client_Id = setting.Client_Id__c;
        String Client_Secret = setting.Client_Secret__c;
        Blob beforeblob = Blob.valueOf(Client_Id + ':' + Client_Secret);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        System.debug(LoggingLevel.INFO, '*** paramvalue: ' + paramvalue);

        String body = '{';
        body += '"grant_type":"' + setting.grant_type__c + '",';
        body += '"scope":"' + setting.scope__c + '",';
        body += '"username":"' + setting.username__c + '",';
        body += '"password":"' + setting.password__c + '"';
        body += '}';
        System.debug(LoggingLevel.INFO, '*** body: ' + body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(setting.login_url__c);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Basic ' + paramvalue);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
        // res.setHeader('Content-Type', 'application/json');
        res = http.send(req);
        System.debug(LoggingLevel.INFO, '*** res.getBody(): ' + res.getBody());

        Token tk = (Token)JSON.deserialize(res.getBody(), Token.class);
        // System.debug(LoggingLevel.INFO, '*** tk: ' + tk);
        return tk.access_token;
    }

    public static String requestEloquaToken() {
        String eloqua_token = '';
        Map<String, Datetime> newtoken = new Map<String, Datetime>();
        // Add counter to the cache with an initial value 
        //  or increment it if it's already there.
        if(orgPartition.contains(TokenCacheKey)) {
            // orgPartition.put(TokenCacheKey, );
            System.debug(LoggingLevel.INFO, '*** orgPartition.get(TokenCacheKey): ' + orgPartition.get(TokenCacheKey));
            Map<String, Datetime> extoken = (Map<String, Datetime>)orgPartition.get(TokenCacheKey);
            for(String token : extoken.keySet()) {
                Datetime dt = extoken.get(token);
                System.debug(LoggingLevel.INFO, '*** dt: ' + dt);
                Datetime sysNow = InseadUtil.returnLocalTime(System.now());
                System.debug(LoggingLevel.INFO, '*** sysNow: ' + sysNow);
                if(dt != null && dt > sysNow.addMinutes(-10)) {
                    System.debug(LoggingLevel.INFO, '*** oldToken: ' + token);
                    eloqua_token = token;
                }else {
                    eloqua_token = getLoginSession();
                    newtoken.put(eloqua_token, InseadUtil.returnLocalTime(System.now()));
                    Cache.Org.put('local.Insead.Eloqua_Token', newtoken);
                    System.debug(LoggingLevel.INFO, '*** newtoken 2: ' + newtoken);
                }
            }
        }else {
            // orgPartition.put(TokenCacheKey, );
            eloqua_token = getLoginSession();
            newtoken.put(eloqua_token, InseadUtil.returnLocalTime(System.now()));
            orgPartition.put(TokenCacheKey, newtoken);
            // Cache.Org.put('local.Insead.Eloqua_Token', newtoken);
            System.debug(LoggingLevel.INFO, '*** newtoken: ' + newtoken);
        }
        return eloqua_token;
    }
    
    private static Cache.OrgPartition getPartition() {
       if(orgPartition == null) {
            orgPartition = Cache.Org.getPartition(DefaultPartition);
       }
       
       return orgPartition;
     }

    public class Token {

        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String refresh_token;

    }

}