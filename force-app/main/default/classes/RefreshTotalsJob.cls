/**
 * Created by SZYSZPA on 15-Feb-22.
 */

public with sharing class RefreshTotalsJob implements Queueable {

    private String scheduleId;

    public RefreshTotalsJob(String scheduleId) {
        this.scheduleId = scheduleId;
    }

    public void execute(QueueableContext context) {

        BookingTriggerService bookingTriggerService = new BookingTriggerService();

        List<String> schedulesIds = new List<String>();
        schedulesIds.add(this.scheduleId);

        Map <Id, AggregateResult> newStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('New', schedulesIds);
        Map <Id, AggregateResult> bookedStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('Booked', schedulesIds);
        Map <Id, AggregateResult> lockedStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('Locked', schedulesIds);

        Map<Id, Schedule__c> schedules = bookingTriggerService.getSchedulesTotalsByIds(schedulesIds);
        List<Schedule__c> schedulesToUpdate = bookingTriggerService.setTotalsForSchedules(schedules, newStatusTotals, bookedStatusTotals, lockedStatusTotals);

        System.debug(schedulesToUpdate);

        Database.update(schedulesToUpdate);
    }
}