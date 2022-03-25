public with sharing class UpsertCasesCalloutQueueable extends CasesCalloutQueueable {

    public UpsertCasesCalloutQueueable(Set<String> casesExternalIds) {

        super(casesExternalIds);
    }

    protected override void executeCallout() {

        List<Case> casesToSend = [
                SELECT External_Id__c, Preferred_Language__c, RecordType.DeveloperName, Priority, Origin, Subject, Description, Comments, SuppliedEmail, SuppliedPhone, SuppliedName, Last_Change_Org_Id__c
                FROM Case
                WHERE External_Id__c in :casesExternalIds
        ];

        UCDCaseCalloutService.sendUpsertCallout(casesToSend);
    }
}