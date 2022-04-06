public with sharing class DeleteCasesCalloutQueueable extends CasesCalloutQueueable {

    public DeleteCasesCalloutQueueable(Set<String> casesExternalIds) {
        super(casesExternalIds);
    }

    protected override void executeCallout() {
        List<Case> casesList = new List<Case>();
        for (String externalId : casesExternalIds) {
            casesList.add(new Case(External_Id__c = externalId));
        }
        UCDCaseCalloutService.sendDeleteCallout(casesList);
    }

}