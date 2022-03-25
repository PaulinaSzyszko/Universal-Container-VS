
public with sharing abstract class CasesCalloutQueueable implements Queueable, Database.AllowsCallouts {

    protected Set<String> casesExternalIds;

    public CasesCalloutQueueable(Set<String> casesExternalIds) {

        this.casesExternalIds = casesExternalIds;
    }

    public void execute(QueueableContext context) {

        if (!casesExternalIds.isEmpty()) {
            executeCallout();
        }
    }

    protected abstract void executeCallout();
}