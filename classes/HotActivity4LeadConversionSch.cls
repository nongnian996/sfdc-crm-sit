global class HotActivity4LeadConversionSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        String excludeProgram = Label.Exclude_Program;
        // String query = 'SELECT OwnerId, Name, CurrencyIsoCode, RecordTypeId, Allocation__c, AttendanceCount__c, BatchId__c, Booked_On_Formatted__c, Browser_Details__c, Business_Phone__c, CRMCampaignId__c, Campaign_Program_Id__c, Category__c, Comment__c, Company__c, Confirmation_Code__c, Contact_Id__c, Contact__c, Current_URL__c, DP_Engagement_Score__c, DP_Lead_score__c, DP_Profile_Score__c, Data_Import__c, Date_Booked__c, Date_of_Birth__c, Date_of_Visit__c, EDP_Engagement_Score__c, EDP_Lead_Score__c, EDP_Marketing_Score__c, EDP_Profile_Score__c, Eloqua_Lead_Type__c, First_Name__c, GA_Ad_Content__c, GA_Campaign__c, GA_Keywords__c, GA_Medium__c, GA_Source__c, Gender__c, Havas_Ad_Id__c, Havas_Campaign_Id__c, Havas_Cat__c, Havas_Site_Id__c, Havas_Type__c, Havas_u3__c, Havas_u4__c, Havas_u6__c, Havas_u8__c, Hidden_Campaign_ID_Field__c, Is_Eloqua_Activity__c, Last_Name__c, Lead_Source__c, Lead_Type__c, Lead__c, LocationAddress__c, Mobile__c, OnDemand_ActivityID__c, Opportunity__c, Opt_In_Date__c, Opt_In__c, Opt_Out_Date__c, Opt_Out__c, Origin_Of_Data_Source__c, Product_Interest_Type__c, Program_Name__c, Program_Type__c, Programme_Sponsorship__c, Rating__c, RecurrenceInterval__c, Registration_Email__c, ReservationToken__c, Reserved_Session__c, SFDC_Contact_ID__c, SFDC_Lead_ID__c, State_or_Province__c, State_or_province_AUS__c, State_or_province_CAN__c, State_or_province_USA__c, Thank_you_Page_Id__c, Title__c, UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Work_Country__c, Work_Experience__c, Priority__c, City__c, Eloqua_Contact_ID__c, Home_Email__c, Work_Email__c, Engagement_EDP_LSP_Score__c, EDP_LSP_Score__c, Qualifier_for_Opportunity__c, Are_you_a_HR__c, Report_Source__c, Marketing_Channel__c, DWH_Activity_Unique_ID__c, DWH_Registration_Email__c, Marketing_Activity_Identifier__c, Product_Interest_Type_Category__c, Processed_by_Lead2Oppy__c, Verification_Error__c, Campaign__c, Last_Siebel_OnDemand_Campaign_ID__c, Create_Lead_for_ODM_Activity__c, Lead_Status__c, Product_Interest_1__c FROM Activity__c';
        String query = InseadUtil.prepareQuery('Activity__c');
        // System.debug(LoggingLevel.INFO, '*** : ' + Database.query(query));
        query += ' Where Qualifier_for_Opportunity__c = true';
        query += ' And Processed_by_Lead2Oppy__c = false';
        query += ' And Lead_Type__c = \'OEP\'';
        // query += ' And Lead_Status__c = \'Qualifying\'';
        query += ' And Product_Interest_Type__c != null';
        query += ' And ((Lead__c != null And (Lead__r.Status = \'New\' OR Lead__r.Status = \'Assigned\')) OR Contact__c != null)';
        query += ' And (Rating__c = \'Hot\' OR Programme_Family__c = \'Certificate\')';
        query += ' And Program_Name__c != null';
        query += ' And Program_Name__c NOT IN (';
        String programTxt = '';
        for(String s : excludeProgram.split(',')) {
            programTxt += '\'' + s + '\',';
        }
        programTxt = programTxt.substring(0, programTxt.lastIndexOf(','));
        System.debug(LoggingLevel.INFO, '*** programTxt: ' + programTxt);
        query += programTxt + ')';
        System.debug(LoggingLevel.INFO, '*** query: ' + query);
        System.debug(LoggingLevel.INFO, '*** Database.query(query): ' + Database.query(query));
        HotActivity4LeadConversionBatch batch = new HotActivity4LeadConversionBatch(query);
        Database.executeBatch(batch, 1);
    }
}