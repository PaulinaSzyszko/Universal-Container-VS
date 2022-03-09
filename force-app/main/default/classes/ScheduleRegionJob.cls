/**
 * Created by SZYSZPA on 16-Feb-22.
 */

public with sharing class ScheduleRegionJob implements Schedulable, Database.Batchable<Schedule__c> {
    String scheduleId;

    public ScheduleRegionJob(String scheduleId) {
        this.scheduleId = scheduleId;
    }
    public ScheduleRegionJob() {
    }

    public Iterable<Schedule__c> start(Database.BatchableContext batchableContext) {

        if (scheduleId == null) {
            return [SELECT Id, Region__c, OwnerId FROM Schedule__c WHERE Disable_Region_Calculation__c = FALSE];
        }
        return [SELECT Id, Region__c, OwnerId FROM Schedule__c WHERE Disable_Region_Calculation__c = FALSE AND Id = :scheduleId];

    }

    public void execute(Database.BatchableContext context, List<Schedule__c> schedules) {

        List<Id> schedulesUserIds = new List<Id>();

        for (Schedule__c schedule : schedules) {
            schedulesUserIds.add(schedule.OwnerId);
        }

        List<User_Territory__c> scheduleUserTerritories = [SELECT Id, User__c, Region__c, Name FROM User_Territory__c WHERE User__c IN:schedulesUserIds];
        Map<Id, User_Territory__c> scheduleUserTerritoriesMap = new Map<Id, User_Territory__c >();


        for (User_Territory__c userTerritory : scheduleUserTerritories) {
            scheduleUserTerritoriesMap.put(userTerritory.User__c, userTerritory);
        }
        for (Schedule__c schedule : schedules) {


            if (scheduleUserTerritoriesMap.get(schedule.OwnerId) != null && schedule.Region__c != scheduleUserTerritoriesMap.get(schedule.OwnerId).Region__c) {

                schedule.Region__c = scheduleUserTerritoriesMap.get(schedule.OwnerId).Region__c;

            } else if (scheduleUserTerritoriesMap.get(schedule.OwnerId) == null) {
                schedule.Region__c = 'a067Q000000FhNdQAK';

            }
        }

        Database.update(schedules);
    }

    public void finish(Database.BatchableContext context) {
    }
    public void execute(SchedulableContext context) {

        Database.executeBatch(new ScheduleRegionJob(), 100);
    }

}