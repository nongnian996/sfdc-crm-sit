/************************************************************************
Class Name : ProductWinRateCalculateSchedule
Version : 1.0
CreatedDate : 07/18/2019
Function : excute the ProductWinRateCalculateBatch on 9:00 AM every day
Modification Log :
-----------------------------------------------------------------------------
* Developer            Date                   Description
* ----------------------------------------------------------------------------                 
* Gordon             07/18/2019               Version 1.0
*************************************************************************/
global class ProductWinRateCalculateSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ProductWinRateCalculateBatch(),1);
    }
}