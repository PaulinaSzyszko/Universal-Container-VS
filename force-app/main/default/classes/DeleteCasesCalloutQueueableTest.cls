
@IsTest
private class DeleteCasesCalloutQueueableTest {

    static Case createCase() {
        Case newCase = new Case();
        newCase.Preferred_Language__c = 'English';
        newCase.priority = 'Medium';
        newCase.origin = 'Web';
        newCase.subject = 'Subject';
        newCase.description = 'Description';
        newCase.comments = 'Comments';
        newCase.SuppliedEmail = 'email@test.pl';
        newCase.SuppliedPhone = '555444333';
        newCase.SuppliedName = 'Felix Test';

        insert newCase;
        return newCase;
    }

    @IsTest private static void shouldDeleteCasesCalloutQueueExecuted() {

        createCase();
        Case caseToDelete = [SELECT External_Id__c FROM Case LIMIT 1];
        Set<String> externalIdsToDelete = new Set<String>{
                caseToDelete.External_Id__c
        };


        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        Id enqueueJob = System.enqueueJob(new DeleteCasesCalloutQueueable(externalIdsToDelete));
        Test.stopTest();

        AsyncApexJob asyncJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :enqueueJob];
        System.assertNotEquals(null, enqueueJob);
        System.assertEquals('Completed', asyncJob.Status);

    }
}