/**
 * Created by SZYSZPA on 15-Feb-22.
 */

public with sharing class BookingTriggerService {

    public Map<Id, AggregateResult> getSumsByStatusAndSchedules(String status, List<Id> scheduleIds) {
        return new Map<Id, AggregateResult>([
                SELECT Schedule__c Id,
                        Status__c,
                        SUM(TEU__c) Total_TEU,
                        Sum(Amount__c) Total_Amount
                FROM Schedule_Booking__c
                WHERE Schedule__c IN:scheduleIds AND Status__c = :status
                GROUP BY Status__c, Schedule__c
        ]);
    }

    public Map<Id, Schedule__c> getSchedulesTotalsByIds(List<Id> scheduleIds) {
        return new Map<Id, Schedule__c>([
                SELECT Id,
                        Total_Amount_with_Booked_Status__c,
                        Total_Amount_with_Locked_Status__c,
                        Total_Amount_with_New_Status__c,
                        Total_TEU_with_Booked_Status__c,
                        Total_TEU_with_Locked_Status__c,
                        Total_TEU_with_New_Status__c
                FROM Schedule__c
                WHERE Id IN:scheduleIds
        ]);
    }

    public List<Schedule__c> setTotalsForSchedules(
            Map<Id, Schedule__c> schedules,
            Map<Id, AggregateResult> newStatusTotals,
            Map <Id, AggregateResult> bookedStatusTotals,
            Map <Id, AggregateResult> lockedStatusTotals) {

        List<Schedule__c> schedulesToUpdate = new List<Schedule__c>();
        for (Id id : schedules.keySet()) {
            Schedule__c schedule = schedules.get(Id);

            if (newStatusTotals.get(id) != null) {
                schedule.Total_Amount_with_New_Status__c = (Decimal) newStatusTotals.get(id).get('Total_Amount');
                schedule.Total_TEU_with_New_Status__c = (Decimal) newStatusTotals.get(id).get('Total_TEU');
            } else {
                schedule.Total_Amount_with_New_Status__c = null;
                schedule.Total_TEU_with_New_Status__c = null;
            }

            if (bookedStatusTotals.get(id) != null) {
                schedule.Total_Amount_with_Booked_Status__c = (Decimal) bookedStatusTotals.get(id).get('Total_Amount');
                schedule.Total_TEU_with_Booked_Status__c = (Decimal) bookedStatusTotals.get(id).get('Total_TEU');
            } else {
                schedule.Total_Amount_with_Booked_Status__c = null;
                schedule.Total_TEU_with_Booked_Status__c = null;
            }

            if (lockedStatusTotals.get(id) != null) {
                schedule.Total_Amount_with_Locked_Status__c = (Decimal) lockedStatusTotals.get(id).get('Total_Amount');
                schedule.Total_TEU_with_Locked_Status__c = (Decimal) lockedStatusTotals.get(id).get('Total_TEU');
            } else {
                schedule.Total_Amount_with_Locked_Status__c = null;
                schedule.Total_TEU_with_Locked_Status__c = null;
            }

            schedulesToUpdate.add(schedule);
        }

        return schedulesToUpdate;
    }

    public Map <Id, AggregateResult> getTotalAmountByOpportunityIds(List<Id> opportunityIds) {
        return new Map <Id, AggregateResult>([
                SELECT Opportunity__c Id,
                        SUM(Amount__c) total
                FROM Schedule_Booking__c
                WHERE Opportunity__c = :opportunityIds
                GROUP BY Opportunity__c
        ]);
    }

    public Map<Id, Opportunity> getOpportunitiesWithAmountByOpportunityIds(List<Id> opportunityIds) {
        return new Map <Id, Opportunity>([
                SELECT Id, Amount
                FROM Opportunity
                WHERE Id in:opportunityIds
        ]);
    }

    public List<Opportunity> setTotalAmountForOpportunities(Map<Id, Opportunity> opportunities, Map<Id, AggregateResult> totalBookingAmount) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Id id : opportunities.keySet()) {

            system.debug(opportunity.Amount);
            Opportunity opportunity = opportunities.get(id);
            opportunity.Amount = (Decimal) totalBookingAmount.get(id).get('total');
            opportunitiesToUpdate.add(opportunity);
            system.debug('After update:' + opportunity.Amount);
        }
        return opportunitiesToUpdate;
    }

}