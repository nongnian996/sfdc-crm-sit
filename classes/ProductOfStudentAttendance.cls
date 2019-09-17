/**************************************************************************************
Class Name:  ProductOfStudentAttendance
Version     : 1.0 
Created Date    : 06/24/2019
Function    : when view a proudct record,can see the students attendance that how much students and male to female ratio 

Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             06/24/2019               Version 1.0
*************************************************************************************/
global class ProductOfStudentAttendance {
    @AuraEnabled
    global static StudentAttendance DoInitData (String recordId) {
    	  StudentAttendance stuattend = new StudentAttendance();
        //query product info
        Product2 prod = [SELECT Id,Is_Programme__c FROM Product2 WHERE Id=: recordId];
        System.debug('product info'+prod);
        stuattend.IsProgramme = prod.Is_Programme__c;
        //query opportunity product 
        List<OpportunityLineItem> lineitemlist = [SELECT Id,OpportunityId,Product2Id FROM OpportunityLineItem WHERE Product2Id =: recordId];
        System.debug('lineitemlist info: '+ lineitemlist);

        //if lineitemlist is not empty
        if(lineitemlist.size() > 0) {
          Set<String> opptySet = new Set<String>();
          for(OpportunityLineItem item : lineitemlist) {
            opptySet.add(item.OpportunityId);
          } 
          //query contact role info
          List<OpportunityContactRole> rolelist = [SELECT Id,ContactId FROM OpportunityContactRole WHERE OpportunityId IN : opptySet];
          System.debug('rolelist info: '+ rolelist);
          Set<String> contactSet = new Set<String>();
          for(OpportunityContactRole item : rolelist) {
            contactSet.add(item.ContactId);
          }
          //query contact info
          List<Contact> contlist = [SELECT Id,Name,hed__Gender__c,Nationality__c,Company__c,Title FROM Contact WHERE Id IN : contactSet];
          System.debug('contlist info: '+ contlist);

          // student attendance Situation
          stuattend.TotalNumber = contlist.size();
          for(Contact cont : contlist) {
            if(cont.hed__Gender__c == 'Male') {
              // male number
              stuattend.MaleNumber += 1;
            }
            else if(cont.hed__Gender__c == 'Female') {
              // female number
              stuattend.FemaleNumber += 1;
            }
            Student stu = new Student();
            stu.ContactName = cont.Name;
            stu.Gender = cont.hed__Gender__c != null ? cont.hed__Gender__c : '';
            stu.Company = cont.Company__c != null ? cont.Company__c : '';
            stu.Title = cont.Title != null ? cont.Title : '';
            stu.Nationality = cont.Nationality__c != null ? cont.Nationality__c : '';
            stuattend.studentlist.add(stu);
          }
        }
       	return stuattend;
    }

    global class StudentAttendance {
    	@AuraEnabled
    	global Decimal TotalNumber = 0;
    	@AuraEnabled
    	global Decimal MaleNumber = 0;
    	@AuraEnabled
    	global Decimal FemaleNumber = 0;
      @AuraEnabled
      global Boolean IsProgramme =false;
    	@AuraEnabled
    	global List<Student> studentlist = new List<Student>();
    }
    //student personal info
    global class Student {
    	@AuraEnabled
    	global String ContactName {get;set;}
    	@AuraEnabled
    	global String Gender {get;set;}
    	@AuraEnabled
    	global String Company {get;set;}
    	@AuraEnabled
    	global String Title {get;set;}
    	@AuraEnabled 
    	global String Nationality {get;set;}
    }
}