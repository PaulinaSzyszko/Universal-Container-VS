/**
 * Created by SZYSZPA on 18-Feb-22.
 */

public with sharing class OpportunityController {

    @AuraEnabled
    public static void checkRegion(String opportunityId) {

        OpportunityRegionJob job = new OpportunityRegionJob(opportunityId);
        System.scheduleBatch(job, 'check opportunity region', 0);
    }
}