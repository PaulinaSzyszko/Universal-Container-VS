/**
 * Created by SZYSZPA on 08-Feb-22.
 */

trigger OpportunityTrigger on Opportunity (after insert, after update) {

    if (Trigger.isUpdate && Trigger.isAfter) {

        List<Task> tasks = new List<Task>();
        TaskService taskService = new TaskService();


        Map<Id, Opportunity> oldOpportunities = Trigger.oldMap;
        for (Opportunity opportunity : Trigger.new) {
            if (oldOpportunities.get(opportunity.Id).StageName != opportunity.StageName && opportunity.StageName == 'Closed Won') {
                System.debug(opportunity);

                Task task = taskService.newTask(opportunity.Id, opportunity.OwnerId);
                System.debug(task);
                if (task != null) {
                    tasks.add(task);
                }
            }
        }
        System.debug(tasks);
        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        
    }
}