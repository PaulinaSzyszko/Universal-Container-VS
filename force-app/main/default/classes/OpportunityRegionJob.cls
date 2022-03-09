/**
 * Created by SZYSZPA on 16-Feb-22.
 */

public with sharing class OpportunityRegionJob implements Schedulable, Database.Batchable<Opportunity> {
    String opportunityId;

    public OpportunityRegionJob(String opportunityId) {
        this.opportunityId = opportunityId;
    }

    public OpportunityRegionJob() {

    }

    public Iterable<Opportunity> start(Database.BatchableContext batchableContext) {

        if (opportunityId == null) {
            return [SELECT Id, Region__c, OwnerId FROM Opportunity WHERE Disable_Region_Calculation__c = FALSE];
        }
        return [SELECT Id, Region__c, OwnerId FROM Opportunity WHERE Disable_Region_Calculation__c = FALSE AND Id = :opportunityId];
    }

    public void execute(Database.BatchableContext ctx, List<Opportunity> opportunities) {

        List<Id> opportunitiesUserIds = new List<Id>();

        for (Opportunity opportunity : opportunities) {
            opportunitiesUserIds.add(opportunity.OwnerId);
        }

        List<User_Territory__c> opportunityUserTerritories = [SELECT Id, User__c, Region__c, Name FROM User_Territory__c WHERE User__c IN:opportunitiesUserIds];
        Map<Id, User_Territory__c> opportunityUserTerritoriesMap = new Map<Id, User_Territory__c>();

        for (User_Territory__c userTerritory : opportunityUserTerritories) {
            opportunityUserTerritoriesMap.put(userTerritory.User__c, userTerritory);
        }

        for (Opportunity opportunity : opportunities) {

            if (opportunityUserTerritoriesMap.get(opportunity.OwnerId) != null && opportunity.Region__c != opportunityUserTerritoriesMap.get(opportunity.OwnerId).Region__c) {
                opportunity.Region__c = opportunityUserTerritoriesMap.get(opportunity.OwnerId).Region__c;
            } else if (opportunityUserTerritoriesMap.get(opportunity.OwnerId) == null) {
                opportunity.Region__c = 'a067Q000000FhNdQAK';
            }
        }
        Database.update(opportunities);
    }

    public void finish(Database.BatchableContext ctx) {
    }
    public void execute(SchedulableContext context) {

        Database.executeBatch(new OpportunityRegionJob(), 100);
    }

}