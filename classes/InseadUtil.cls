public class InseadUtil {
    
    public static Set<String> stageLostSet = new Set<String>{'Closed Lost', 'Closed/Lost – Admission', 'Closed/Lost'};
    public static Set<String> stageWonSet = new Set<String>{'Admitted/ Enrolled/ Closed/Won', 'Contract Signed - Closed/Won', 'Contract Signed  - Closed/Won', 'Accepted/Admitted/Enrolled Closed/Won', 'Closed Won'};

    public static Map<String, String> getObjectRecordType(String type) {
        Map<String, String> rtMap = new Map<String, String>();
        for(RecordType rt : [Select Id, DeveloperName From RecordType Where SobjectType =: type]) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
        return rtMap;
    }

    public static Datetime returnLocalTime(Datetime dt) {
        if(dt != null) {
            TimeZone tz = UserInfo.getTimeZone();
            dt = returnLocalTime(tz, dt);
        }
        return dt;
    }

    public static Datetime returnLocalTime(TimeZone tz, Datetime dt) {
        if(dt != null) {
            dt = dt.addSeconds(tz.getOffset(dt)/1000);
        }
        return dt;
    }

    public static String prepareQuery(String objType) {
        SObjectType sobjectType = Schema.getGlobalDescribe().get(objType);
        Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
        // System.debug(LoggingLevel.INFO, '*** fieldMap: ' + fieldMap);
        String query = 'Select ';
        for(String key : fieldMap.keySet()) {
            query += key + ',';
        }
        query = query.substringBeforeLast(',');
        // System.debug(LoggingLevel.INFO, '*** query: ' + query);
        query += ' From ' + objType;
        return query;
    }
}