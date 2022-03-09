/**
 * Created by SZYSZPA on 09-Feb-22.
 */

public with sharing class TaskService {

    public Task newTask(Id opportunityId, Id ownerId) {
        //final String CONTRACT_REMINDER ='Contract_Reminder';
        Task_workflow_configuration__mdt taskWorkflowConfiguration = [
                SELECT Id,
                        is_Active__c,
                        Task_Type__c,
                        Task_Subject__c,
                        developerName
                FROM Task_workflow_configuration__mdt
                WHERE developerName = 'Contract_Reminder'
        ];
// contract reminder zmienic na final

        if (taskWorkflowConfiguration.is_Active__c == true) {

            Task task = new Task();
            task.WhatId = opportunityId;
            task.OwnerId = ownerId;
            task.Subject = taskWorkflowConfiguration.Task_Subject__c ;
            task.Type__c = taskWorkflowConfiguration.Task_Type__c;
            return task;
        }
        return null;
    }

    public Task closeTask(Task task) {
        task.is_Closed__c = true;
        task.Closure_Date__c = Date.today();
        task.Status = 'Completed';
        return task;
    }
}