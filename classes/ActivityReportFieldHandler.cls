public class ActivityReportFieldHandler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isInsert && Trigger.isBefore) {
            for(Activity__c activity : (List<Activity__c>)Trigger.new) {
                Boolean channel = true;
                Boolean reportsource = true;
                Boolean interesttype = true;
                //report source field assignment
                if(activity.GA_Medium__c == 'OnlineAd' || activity.GA_Medium__c == 'onlinead' || activity.Havas_Campaign_Id__c == 'StandardMega' || activity.Havas_Campaign_Id__c == 'StandardSquare302') {
                    activity.Report_Source__c = 'OnlineAd';
                    reportsource = false;
                }
                if(activity.Havas_Campaign_Id__c == 'ssu' || activity.Havas_Campaign_Id__c == 'SSU' || activity.Havas_Campaign_Id__c == 'inmail' || activity.Havas_Campaign_Id__c == 'Inmail') {
                    activity.Report_Source__c = 'Social - Paid';
                    reportsource = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Organic' || activity.GA_Medium__c == 'Social' || activity.GA_Medium__c == 'social') {
                    activity.Report_Source__c = 'Social - Organic';
                    reportsource = false;
                }
                if(activity.Havas_Site_Id__c == 'GGL' || activity.Havas_Campaign_Id__c == 'Google-Search') {
                    activity.Report_Source__c = 'SEM';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'organic') {
                    activity.Report_Source__c = 'Organic';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'email' || activity.Lead_Source__c == 'Email Campaign') {
                    activity.Report_Source__c = 'Email';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'direct' && activity.Havas_Ad_Id__c == 'x') {
                    activity.Report_Source__c = 'Direct/Others';
                    reportsource = false;
                }
                if(reportsource){
                    activity.Report_Source__c = 'Direct/Others';
                }

                //marketing channel field assignment
                if(activity.GA_Medium__c == 'email') {
                    activity.Marketing_Channel__c = 'Email';
                    channel = false;
                }
                if(activity.GA_Medium__c == 'OnlineAd' || activity.GA_Medium__c == 'onlinead') {
                    activity.Marketing_Channel__c = 'OnlineAd';
                    channel = false;
                }
                if(activity.GA_Medium__c == 'Social' || activity.GA_Medium__c == 'social' || activity.GA_Medium__c == 'Sponsored' || activity.GA_Medium__c == 'ssu') {
                    activity.Marketing_Channel__c = 'Social';
                    channel = false;
                }
                if(activity.Havas_Site_Id__c == 'GGL' || activity.Havas_Site_Id__c == 'Google') {
                    activity.Marketing_Channel__c = 'SEM';
                    channel = false;
                }
                if(activity.Lead_Source__c == 'Email Campaign') {
                    activity.Marketing_Channel__c = 'Email';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Google-Search') {
                    activity.Marketing_Channel__c = 'SEM';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'StandardMega' || activity.Havas_Campaign_Id__c == 'StandardSquare302') {
                    activity.Marketing_Channel__c = 'OnlineAd';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Inmail' || activity.Havas_Campaign_Id__c == 'inmail') {
                    activity.Marketing_Channel__c = 'Social';
                    channel = false;
                }
                if(activity.Havas_Site_Id__c == 'x' || activity.Lead_Source__c == 'INSEAD Website' || activity.Lead_Source__c == 'Unknown') {
                    activity.Marketing_Channel__c = 'Organic/Direct';
                    channel = false;
                }
                if(channel){
                    activity.Marketing_Channel__c = 'Other';
                }

                if(activity.Product_Interest_Type__c != null) {
                    if(activity.Product_Interest_Type__c.contains('Appl') || activity.Product_Interest_Type__c.contains('apol') || activity.Product_Interest_Type__c.contains('APOL')) {
                        activity.Product_Interest_Type_Category__c = 'AF';
                        interesttype=false;
                    }
                    if(activity.Product_Interest_Type__c.contains('Broc') || activity.Product_Interest_Type__c.contains('Soft') || activity.Product_Interest_Type__c.contains('broc')) {
                        activity.Product_Interest_Type_Category__c = 'BR';
                        interesttype=false;
                    }
                    if(activity.Product_Interest_Type__c.contains('Res') || activity.Product_Interest_Type__c.contains('Reserve') || activity.Product_Interest_Type__c.contains('RAS')) {
                        activity.Product_Interest_Type_Category__c = 'RAS';
                        interesttype=false;
                    }
                    if(interesttype) {
                        activity.Product_Interest_Type_Category__c = 'Others';
                    }
                }
            }
        }

        if(Trigger.isUpdate && Trigger.isBefore) {
            Set<String> idSet = new Set<String>();
            for(Activity__c activity : (List<Activity__c>)Trigger.new) {
                Boolean channel = true;
                Boolean reportsource = true;
                Boolean interesttype = true;
                //report source field assignment
                if(activity.GA_Medium__c == 'OnlineAd' || activity.GA_Medium__c == 'onlinead' || activity.Havas_Campaign_Id__c == 'StandardMega' || activity.Havas_Campaign_Id__c == 'StandardSquare302') {
                    activity.Report_Source__c = 'OnlineAd';
                    reportsource = false;
                }
                if(activity.Havas_Campaign_Id__c == 'ssu' || activity.Havas_Campaign_Id__c == 'SSU' || activity.Havas_Campaign_Id__c == 'inmail' || activity.Havas_Campaign_Id__c == 'Inmail') {
                    activity.Report_Source__c = 'Social - Paid';
                    reportsource = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Organic' || activity.GA_Medium__c == 'Social' || activity.GA_Medium__c == 'social') {
                    activity.Report_Source__c = 'Social - Organic';
                    reportsource = false;
                }
                if(activity.Havas_Site_Id__c == 'GGL' || activity.Havas_Campaign_Id__c == 'Google-Search') {
                    activity.Report_Source__c = 'SEM';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'organic') {
                    activity.Report_Source__c = 'Organic';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'email' || activity.Lead_Source__c == 'Email Campaign') {
                    activity.Report_Source__c = 'Email';
                    reportsource = false;
                }
                if(activity.GA_Medium__c == 'direct' && activity.Havas_Ad_Id__c == 'x') {
                    activity.Report_Source__c = 'Direct/Others';
                    reportsource = false;
                }
                if(reportsource){
                    activity.Report_Source__c = 'Direct/Others';
                }

                //marketing channel field assignment
                if(activity.GA_Medium__c == 'email') {
                    activity.Marketing_Channel__c = 'Email';
                    channel = false;
                }
                if(activity.GA_Medium__c == 'OnlineAd' || activity.GA_Medium__c == 'onlinead') {
                    activity.Marketing_Channel__c = 'OnlineAd';
                    channel = false;
                }
                if(activity.GA_Medium__c == 'Social' || activity.GA_Medium__c == 'social' || activity.GA_Medium__c == 'Sponsored' || activity.GA_Medium__c == 'ssu') {
                    activity.Marketing_Channel__c = 'Social';
                    channel = false;
                }
                if(activity.Havas_Site_Id__c == 'GGL' || activity.Havas_Site_Id__c == 'Google') {
                    activity.Marketing_Channel__c = 'SEM';
                    channel = false;
                }
                if(activity.Lead_Source__c == 'Email Campaign') {
                    activity.Marketing_Channel__c = 'Email';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Google-Search') {
                    activity.Marketing_Channel__c = 'SEM';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'StandardMega' || activity.Havas_Campaign_Id__c == 'StandardSquare302') {
                    activity.Marketing_Channel__c = 'OnlineAd';
                    channel = false;
                }
                if(activity.Havas_Campaign_Id__c == 'Inmail' || activity.Havas_Campaign_Id__c == 'inmail') {
                    activity.Marketing_Channel__c = 'Social';
                    channel = false;
                }
                if(activity.Havas_Site_Id__c == 'x' || activity.Lead_Source__c == 'INSEAD Website' || activity.Lead_Source__c == 'Unknown') {
                    activity.Marketing_Channel__c = 'Organic/Direct';
                    channel = false;
                }
                if(channel){
                    activity.Marketing_Channel__c = 'Other';
                }

                if(activity.Product_Interest_Type__c != null) {
                    if(activity.Product_Interest_Type__c.contains('Appl') || activity.Product_Interest_Type__c.contains('apol') || activity.Product_Interest_Type__c.contains('APOL')) {
                        activity.Product_Interest_Type_Category__c = 'AF';
                        interesttype=false;
                    }
                    if(activity.Product_Interest_Type__c.contains('Broc') || activity.Product_Interest_Type__c.contains('Soft') || activity.Product_Interest_Type__c.contains('broc')) {
                        activity.Product_Interest_Type_Category__c = 'BR';
                        interesttype=false;
                    }
                    if(activity.Product_Interest_Type__c.contains('Res') || activity.Product_Interest_Type__c.contains('Reserve') || activity.Product_Interest_Type__c.contains('RAS')) {
                        activity.Product_Interest_Type_Category__c = 'RAS';
                        interesttype=false;
                    }
                    if(interesttype) {
                        activity.Product_Interest_Type_Category__c = 'Others';
                    }
                }
            }
        }
    }
}