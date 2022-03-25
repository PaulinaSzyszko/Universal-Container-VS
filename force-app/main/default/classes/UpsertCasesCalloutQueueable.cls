public with sharing class UpsertCasesCalloutQueueable implements Queueable, Database.AllowsCallouts {

    private List<Case> casesToSend;

    public UpsertCasesCalloutQueueable(List<Case> cases) {

        this.casesToSend = cases;
    }

    public void execute(QueueableContext context) {
        
        if (!casesToSend.isEmpty()) {
            UCDCaseCalloutService.sendUpsertCallout(casesToSend);
        }
    }
}