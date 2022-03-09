/**
 * Created by SZYSZPA on 06-Feb-22.
 */

public with sharing class RouteSearch {

    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public Date startDate { get; set; }
    @AuraEnabled public Date endDate { get; set; }
    @AuraEnabled public String route { get; set; }
    @AuraEnabled public String vessel { get; set; }

}