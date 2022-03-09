/**
 * Created by SZYSZPA on 09-Feb-22.
 */
@IsTest
public with sharing class OpportunityTest {

    @TestSetup static void setup() {

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Closed Won';
        opportunity.CloseDate = Date.today();
        opportunity.OwnerId = UserInfo.getUserId();

        insert opportunity;
    }
    @IsTest static void testCreateTaskAfterUpdateOpportunity() {

        //given
        Opportunity opportunity = [SELECT Id, StageName, OwnerId FROM Opportunity];
        update opportunity;

        //when
        List<Task> tasks = [
                SELECT Id,
                        Subject,
                        WhatId,
                        OwnerId,
                        Type__c
                FROM Task
                WHERE WhatId = :opportunity.Id
                AND Subject = 'Create contract for Opportunity'
        ];
//subject== custom metadata type
        //Then
        for (Task task : tasks) {
            System.assertEquals('Create contract for Opportunity', task.Subject);
            System.assertEquals(opportunity.Id, task.WhatId);
            System.assertEquals('Contact creation reminder', task.Type__c);
            System.assertEquals(opportunity.OwnerId, task.OwnerId);
        }

    }

    @IsTest static void testTaskNotCreated() {

        //given
        Opportunity opportunity = [SELECT Id, StageName, OwnerId FROM Opportunity];
        opportunity.StageName = 'Closed Lost';
        update opportunity;

        //when
        List<Task> tasks = [
                SELECT Id,
                        Subject,
                        WhatId,
                        OwnerId,
                        Type__c
                FROM Task
                WHERE WhatId = :opportunity.Id
                AND Subject = 'Create contract for Opportunity'
        ];

        //Then
        System.assertEquals(0, tasks.size());
    }
}