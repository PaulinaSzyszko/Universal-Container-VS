public with sharing class DeleteCasesCalloutQueueable implements Queueable, Database.AllowsCallouts {

    private List<Case> casesToDelete;

    public DeleteCasesCalloutQueueable(List<Case> cases) {

        this.casesToDelete = cases;
    }
    
    public void execute(QueueableContext context) {

        if (!casesToDelete.isEmpty()) {
            UCDCaseCalloutService.sendDeleteCallout(casesToDelete);
        }
    }
}