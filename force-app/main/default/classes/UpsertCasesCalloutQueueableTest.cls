@IsTest
private class UpsertCasesCalloutQueueableTest {

    static Case createCase() {

        Case newCase = new Case();
        newCase.Preferred_Language__c = 'English';
        newCase.Priority = 'Medium';
        newCase.Origin = 'Web';
        newCase.Subject = 'Subject';
        newCase.Description = 'Description';
        newCase.Comments = 'Comments';
        newCase.SuppliedEmail = 'email@test.pl';
        newCase.SuppliedPhone = '555444333';
        newCase.SuppliedName = 'Felix Test';

        insert newCase;
        return newCase;
    }

    @IsTest private static void shouldUpsertCasesCalloutQueueExecuted() {

        createCase();
        Case caseToUpsert = [SELECT External_Id__c FROM Case LIMIT 1];
        Set<String> externalIdsToUpsert = new Set<String>{
                caseToUpsert.External_Id__c
        };

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        Id enqueueJob = System.enqueueJob(new DeleteCasesCalloutQueueable(externalIdsToUpsert));
        Test.stopTest();

        AsyncApexJob asyncJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :enqueueJob];
        System.assertNotEquals(null, enqueueJob);
        System.assertEquals('Completed', asyncJob.Status);

    }
}