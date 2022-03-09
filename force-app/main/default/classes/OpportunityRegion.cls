/**
 * Created by SZYSZPA on 16-Feb-22.
 */

public with sharing class OpportunityRegion {

    public static void check() {
        OpportunityRegionJob schedule = new OpportunityRegionJob();
        System.schedule('check opportunity region', '0 45 * * * ?', schedule);
    }
}