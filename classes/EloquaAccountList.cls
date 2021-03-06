//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are not valid in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class EloquaAccountList {

    public List<Element> elements {get;set;} 
    public Integer page {get;set;} 
    public Integer pageSize {get;set;} 
    public Integer total {get;set;} 

    public EloquaAccountList(JSONParser parser) {
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
                        System.debug(LoggingLevel.WARN, 'EloquaAccountList consuming unrecognized property: '+text);
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
                            System.debug(LoggingLevel.WARN, 'FieldValue consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Element {
        public String type {get;set;} // in json: type
        public String id {get;set;} 
        public String createdAt {get;set;} 
        public String depth {get;set;} 
        public String description {get;set;} 
        public String name {get;set;} 
        public String updatedAt {get;set;} 
        public String address1 {get;set;} 
        public String address2 {get;set;} 
        public String address3 {get;set;} 
        public String businessPhone {get;set;} 
        public String city {get;set;} 
        public String country {get;set;} 
        public List<FieldValue> fieldValues {get;set;} 
        public String postalCode {get;set;} 
        public String province {get;set;} 

        public Element(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'depth') {
                            depth = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'updatedAt') {
                            updatedAt = parser.getText();
                        } else if (text == 'address1') {
                            address1 = parser.getText();
                        } else if (text == 'address2') {
                            address2 = parser.getText();
                        } else if (text == 'address3') {
                            address3 = parser.getText();
                        } else if (text == 'businessPhone') {
                            businessPhone = parser.getText();
                        } else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else if (text == 'fieldValues') {
                            fieldValues = arrayOfFieldValues(parser);
                        } else if (text == 'postalCode') {
                            postalCode = parser.getText();
                        } else if (text == 'province') {
                            province = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Element consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static EloquaAccountList parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new EloquaAccountList(parser);
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