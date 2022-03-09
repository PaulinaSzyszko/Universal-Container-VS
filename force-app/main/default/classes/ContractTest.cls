/**
 * Created by SZYSZPA on 10-Feb-22.
 */
@IsTest
public with sharing class ContractTest {

    @TestSetup static void setup() {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Closed Won';
        opportunity.CloseDate = Date.today();
        opportunity.OwnerId = UserInfo.getUserId();

        insert opportunity;
    }

    @IsTest public static void testTaskUpdateAfterContractCreation() {

        //given
        Opportunity opportunity = [SELECT Id FROM Opportunity];

        Contract__c contract = new Contract__c();
        // contract.Name = 'Test contract';
        contract.Start_Date__c = Date.today();
        contract.End_Date__c = Date.today() + 3;
        contract.Opportunity__c = opportunity.Id;
        contract.OwnerId = UserInfo.getUserId();

        insert contract;
        //When
        List<Task> tasks = [
                SELECT Id,
                        Type__c,
                        is_Closed__c,
                        Closure_Date__c,
                        Status
                FROM Task
                WHERE WhatId = :opportunity.Id
                //AND Type__c = taskWorkflowConfiguration.Task_Type__c
        ];

        //Then
        for (Task task : tasks) {
            System.assertEquals('Contact creation reminder', task.Type__c);
            System.assertEquals(true, task.is_Closed__c);
            System.assertEquals(Date.today(), task.Closure_Date__c);
            System.assertEquals('Completed', task.Status);
        }
    }

}