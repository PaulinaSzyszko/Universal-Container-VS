/**
 * Created by SZYSZPA on 15-Feb-22.
 */

public with sharing class ScheduleController {

    @AuraEnabled
    public static void refreshTotals(String scheduleId) {
        RefreshTotalsJob job = new RefreshTotalsJob(scheduleId);
        System.enqueueJob(job);

    }
    @AuraEnabled
    public static void checkScheduleRegion(String scheduleId) {
        
        ScheduleRegionJob job = new ScheduleRegionJob(scheduleId);
        System.scheduleBatch(job, 'check schedule region', 0);

    }

}