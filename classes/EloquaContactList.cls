//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are not valid in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class EloquaContactList {

    public List<Element> elements {get;set;} 
    public Integer page {get;set;} 
    public Integer pageSize {get;set;} 
    public Integer total {get;set;} 

    public EloquaContactList(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'elements') {
                        elements = arrayOfElements(parser);
                    } else if (text == 'page') {
                        page = parser.getIntegerValue();
                    } else if (text == 'pageSize') {
                        pageSize = parser.getIntegerValue();
                    } else if (text == 'total') {
                        total = parser.getIntegerValue();
                    } else {
                        System.debug(LoggingLevel.WARN, 'EloquaContactList consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class FieldValue {
        public String type {get;set;} // in json: type
        public String id {get;set;} 
        public String value {get;set;} 

        public FieldValue(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'FieldValues consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Element {
        public String type {get;set;} // in json: type
        public String currentStatus {get;set;} 
        public String id {get;set;} 
        public String createdAt {get;set;} 
        public String depth {get;set;} 
        public String name {get;set;} 
        public String updatedAt {get;set;} 
        public String accountName {get;set;} 
        public String businessPhone {get;set;} 
        public String emailAddress {get;set;} 
        public String emailFormatPreference {get;set;} 
        public List<FieldValue> fieldValues {get;set;} 
        public String firstName {get;set;} 
        public String isBounceback {get;set;} 
        public String isSubscribed {get;set;} 
        public String lastName {get;set;} 
        public String subscriptionDate {get;set;} 

        public Element(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'currentStatus') {
                            currentStatus = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'depth') {
                            depth = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'updatedAt') {
                            updatedAt = parser.getText();
                        } else if (text == 'accountName') {
                            accountName = parser.getText();
                        } else if (text == 'businessPhone') {
                            businessPhone = parser.getText();
                        } else if (text == 'emailAddress') {
                            emailAddress = parser.getText();
                        } else if (text == 'emailFormatPreference') {
                            emailFormatPreference = parser.getText();
                        } else if (text == 'fieldValues') {
                            fieldValues = arrayOfFieldValues(parser);
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'isBounceback') {
                            isBounceback = parser.getText();
                        } else if (text == 'isSubscribed') {
                            isSubscribed = parser.getText();
                        } else if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'subscriptionDate') {
                            subscriptionDate = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Elements consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static EloquaContactList parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new EloquaContactList(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    




    private static List<Element> arrayOfElements(System.JSONParser p) {
        List<Element> res = new List<Element>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Element(p));
        }
        return res;
    }


    private static List<FieldValue> arrayOfFieldValues(System.JSONParser p) {
        List<FieldValue> res = new List<FieldValue>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FieldValue(p));
        }
        return res;
    }




}