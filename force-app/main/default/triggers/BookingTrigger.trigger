/**
 * Created by SZYSZPA on 14-Feb-22.
 */

trigger BookingTrigger on Schedule_Booking__c (after insert, after update) {

    if (Trigger.isUpdate || Trigger.isInsert) {
        // Opportunity
        List<Id> opportunityIds = new List<Id>();
        BookingTriggerService bookingTriggerService = new BookingTriggerService();

        for (Schedule_Booking__c booking : Trigger.new) {
            opportunityIds.add(booking.Opportunity__c);
        }

        Map<Id, AggregateResult> opportunitiesTotals = bookingTriggerService.getTotalAmountByOpportunityIds(opportunityIds);
        Map<Id, Opportunity> opportunitiesWithAmount = bookingTriggerService.getOpportunitiesWithAmountByOpportunityIds(opportunityIds);
        List<Opportunity> opportunityToUpdate = bookingTriggerService.setTotalAmountForOpportunities(opportunitiesWithAmount, opportunitiesTotals);

        System.debug(opportunityToUpdate);
        Database.update(opportunityToUpdate);

        //Schedule
        List<Id> schedulesIds = new List<Id>();
        for (Schedule_Booking__c booking : Trigger.new) {
            schedulesIds.add(booking.Schedule__c);
        }

        Map <Id, AggregateResult> newStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('New', schedulesIds);
        Map <Id, AggregateResult> bookedStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('Booked', schedulesIds);
        Map <Id, AggregateResult> lockedStatusTotals = bookingTriggerService.getSumsByStatusAndSchedules('Locked', schedulesIds);

        Map<Id, Schedule__c> schedules = bookingTriggerService.getSchedulesTotalsByIds(schedulesIds);
        List<Schedule__c> schedulesToUpdate = bookingTriggerService.setTotalsForSchedules(schedules, newStatusTotals, bookedStatusTotals, lockedStatusTotals);
        System.debug(schedulesToUpdate);
        Database.update(schedulesToUpdate);
    }
}