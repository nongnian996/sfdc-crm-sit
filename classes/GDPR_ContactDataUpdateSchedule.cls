/**************************************************************************************
Class Name:  GDPR_ContactDataUpdateSchedule
Version     : 1.0 
Created Date    : 08/26/2019
Function  : Run GDPR_ContactDataUpdateBatch monthly

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             08/26/2019             Original Version
*************************************************************************************/
global class GDPR_ContactDataUpdateSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GDPR_ContactDataUpdateBatch(), 500);
    }
}