/**
 * Created by SZYSZPA on 08-Feb-22.
 */

trigger ContractTrigger on Contract__c (after insert, after update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        List<Id> opportunityIds = new List<Id>();
        TaskService taskService = new TaskService();
        
        List<Contract__c> contracts = [SELECT Opportunity__r.Id FROM Contract__c WHERE Id IN :Trigger.new];

        for (Contract__c contract : contracts) {
            opportunityIds.add(contract.Opportunity__r.Id);
        }

        List<Task> tasks = [SELECT Id, Type__c, is_Closed__c, Closure_Date__c FROM Task WHERE WhatId IN :opportunityIds];

        for (Task task : tasks) {
            if (task.Type__c == 'Contact creation reminder') {

                taskService.closeTask(task);
            }
        }
        update tasks;
    }
}