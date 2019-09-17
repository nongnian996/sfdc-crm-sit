/************************************************************************************
Class Name : MergeLeadHandler
Version : 1.0 
Created Date : 08/01/2019
Function : Auto merger duplicate Lead when data source = Eloqua

Modification Log :
-----------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon                   08/01/2019               Version 1.0
*************************************************************************************/
public class MergeLeadHandler implements Triggers.Handler {
    public void handle() {
        //after insert
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> workemailSet = new Set<String>();
        Set<String> homeemailSet = new Set<String>();
        if(Trigger.isAfter) {
            for(Lead leads : (List<Lead>) Trigger.new) {
                firstNameSet.add(leads.FirstName);
                lastnameSet.add(leads.LastName);
                emailSet.add(leads.Email);
                workemailSet.add(leads.Work_Email__c);
                homeemailSet.add(leads.Home_Email__c);
            }
            //query lead info
            List<Lead> leadlist = [SELECT Id,FirstName,LastName,Email,Home_Email__c,Work_Email__c,CreatedDate FROM Lead 
                                                WHERE IsConverted = false AND FirstName =: firstNameSet AND LastName =: lastnameSet
                                                AND ((Email =: emailSet AND Email != null ) 
                                                OR (Work_Email__c =: workemailSet AND Work_Email__c != null) 
                                                OR (Home_Email__c =: homeemailSet AND Home_Email__c != null))];
            System.debug('leadlist info: '+leadlist);

            Map<String,List<Lead>> masteremailMap = new Map<String,List<Lead>>();
            Map<String,List<Lead>> workemailMap = new Map<String,List<Lead>>();
            Map<String,List<Lead>> homeemailMap = new Map<String,List<Lead>>();

            //Email
            for(Lead lead : leadlist) {
                if(lead.Email != null) {
                    if(masteremailMap.containsKey(lead.FirstName+lead.LastName+lead.Email)) {
                        masteremailMap.get(lead.FirstName+lead.LastName+lead.Email).add(lead);
                    }
                    else {
                        masteremailMap.put(lead.FirstName+lead.LastName+lead.Email,new List<Lead>{lead});
                    }
                }
            }

            if(masteremailMap.keySet().size() != 0) {
                // duplicate lead reocrd merge
                for(String keys : masteremailMap.keySet()) {
                    //greater than 1 record & less or equals to 3 records
                    if(masteremailMap.get(keys).size() > 1 && masteremailMap.get(keys).size() <=3) {
                        Lead masterLead;
                        List<Lead> clist = masteremailMap.get(keys);
                        //masterLead : created date greatest  -- Bubbling cycle
                        for(Integer i=0; i < clist.size(); i++) {
                            for(Integer j=1; j < clist.size(); j++) {
                                if(clist[i].CreatedDate > clist[j].CreatedDate) {
                                    masterLead = clist[i];
                                    clist[i] = clist[j];
                                    clist[j] = masterLead;
                                }
                            }
                        }
                        List<Lead> mergelist = new List<Lead>();
                        for(Integer i=0; i < clist.size()-1; i++ ) {
                            mergelist.add(clist[i]);
                        }
                        doMerge(JSON.serialize(clist[clist.size()-1]),JSON.serialize(mergelist));
                    }
                    // greater than 3 records
                    else if(masteremailMap.get(keys).size() > 3) {

                    }
                } 
            }

            //HomeEmial
            for(Lead lead : leadlist) {
                if(lead.Home_Email__c != null) {
                    if(homeemailMap.containsKey(lead.FirstName+lead.LastName+lead.Home_Email__c)) {
                        homeemailMap.get(lead.FirstName+lead.LastName+lead.Home_Email__c).add(lead);
                    }
                    else {
                        homeemailMap.put(lead.FirstName+lead.LastName+lead.Home_Email__c,new List<Lead>{lead});
                    }
                }
            }

            if(homeemailMap.keySet().size() != 0) {
                // duplicate lead reocrd merge
                for(String keys : homeemailMap.keySet()) {
                    //greater than 1 record & less or equals to 3 records
                    if(homeemailMap.get(keys).size() > 1 && homeemailMap.get(keys).size() <=3) {
                        Lead masterLead;
                        List<Lead> clist = homeemailMap.get(keys);
                        //masterLead : created date greatest  -- Bubbling cycle
                        for(Integer i=0; i < clist.size(); i++) {
                            for(Integer j=1; j < clist.size(); j++) {
                                if(clist[i].CreatedDate > clist[j].CreatedDate) {
                                    masterLead = clist[i];
                                    clist[i] = clist[j];
                                    clist[j] = masterLead;
                                }
                            }
                        }
                        List<Lead> mergelist = new List<Lead>();
                        for(Integer i=0; i < clist.size()-1; i++ ) {
                            mergelist.add(clist[i]);
                        }
                        doMerge(JSON.serialize(clist[clist.size()-1]),JSON.serialize(mergelist));
                    }
                    // greater than 3 records
                    else if(homeemailMap.get(keys).size() > 3) {

                    }
                } 
            }


            //WorkEmail
            for(Lead lead : leadlist) {
                if(lead.Work_Email__c != null) {
                    if(workemailMap.containsKey(lead.FirstName+lead.LastName+lead.Work_Email__c)) {
                        workemailMap.get(lead.FirstName+lead.LastName+lead.Work_Email__c).add(lead);
                    }
                    else {
                        workemailMap.put(lead.FirstName+lead.LastName+lead.Work_Email__c,new List<Lead>{lead});
                    }
                }
            }

            if(workemailMap.keySet().size() != 0) {
                // duplicate lead reocrd merge
                for(String keys : workemailMap.keySet()) {
                    //greater than 1 record & less or equals to 3 records
                    if(workemailMap.get(keys).size() > 1 && workemailMap.get(keys).size() <=3) {
                        Lead masterLead;
                        List<Lead> clist = workemailMap.get(keys);
                        //masterLead : created date greatest  -- Bubbling cycle
                        for(Integer i=0; i < clist.size(); i++) {
                            for(Integer j=1; j < clist.size(); j++) {
                                if(clist[i].CreatedDate > clist[j].CreatedDate) {
                                    masterLead = clist[i];
                                    clist[i] = clist[j];
                                    clist[j] = masterLead;
                                }
                            }
                        }
                        List<Lead> mergelist = new List<Lead>();
                        for(Integer i=0; i < clist.size()-1; i++ ) {
                            mergelist.add(clist[i]);
                        }
                        doMerge(JSON.serialize(clist[clist.size()-1]),JSON.serialize(mergelist));
                    }
                    // greater than 3 records
                    else if(workemailMap.get(keys).size() > 3) {

                    }
                } 
            }
        }
    }

    @future
    public static void doMerge(String leadObj,String listObj) {
        Lead masterLead = (Lead)JSON.deserialize(leadObj, Lead.class);
        System.debug(LoggingLevel.INFO, '*** masterLead: ' + masterLead);
        List<Lead> duplicateList = (List<Lead>)JSON.deserialize(listObj, List<Lead>.class);
        System.debug(LoggingLevel.INFO, '*** merge duplicateList: ' + duplicateList);

        Schema.FieldSet leadFieldSet = Schema.SObjectType.Lead.fieldSets.getMap().get('GDPR_Lead_Fields');

        Set<ID> masterIdSet = new Set<ID>();
        masterIdSet.add(masterLead.Id);
        String sqlquery = 'SELECT Id';
        for(Schema.FieldSetMember setmember : leadFieldSet.getFields()) {
            sqlquery += ','+setmember.getFieldPath();
        }
        sqlquery += ' FROM Lead WHERE Id IN : masterIdSet';
        System.debug('Query SQL: '+ sqlquery);
        List<Lead> masterleadlist = Database.query(sqlquery);

        Set<ID> leadIdSet = new Set<ID>();
        for(Lead lead : duplicateList) {
            leadIdSet.add(lead.Id);
        }

        String sqlquery1 = 'SELECT Id';
        for(Schema.FieldSetMember setmember : leadFieldSet.getFields()) {
            sqlquery1 += ','+setmember.getFieldPath();
        }
        sqlquery1 += ' FROM Lead WHERE Id IN : leadIdSet';
        System.debug('Query SQL: '+ sqlquery1);
        //query the duplicate Lead record
        List<Lead> mergeleadlist = Database.query(sqlquery1);

        // if duplicate record equals to 1
        if(mergeleadlist.size() ==1 ) {
            for(Lead lead : mergeleadlist) {
                for(Schema.FieldSetMember setmember : leadFieldSet.getFields()) {
                    if(masterleadlist[0].get(setmember.getFieldPath()) == null) {
                       masterleadlist[0].put(setmember.getFieldPath(),lead.get(setmember.getFieldPath()));
                    }
                    else if(masterleadlist[0].get(setmember.getFieldPath()) == false) {
                       masterleadlist[0].put(setmember.getFieldPath(),lead.get(setmember.getFieldPath()));
                    }
                }
            }
            Database.MergeResult[] results = Database.merge(masterleadlist[0], mergeleadlist,true);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
        }
        // if duplicate record equals to 2
        else {
            masterleadlist[0].Verification_Status__c = 'Raised for Potential Duplicate';
            masterleadlist[0].Potential_Duplicate_Lead_1__c = mergeleadlist[0].Id;
            masterleadlist[0].Potential_Duplicate_Lead_2__c = mergeleadlist[1].Id;
            update masterleadlist;
        }
    }
}