@isTest
private class CaseTriggerTest {

   @IsTest static void shouldGetCorrectQueueAfterNewCaseCreation() {

        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department'];
        RecordType recordType = [SELECT Id, Name FROM RecordType where Name = 'Invoice Request'];
        Case newTestCase = new Case();
        newTestCase.OwnerId = queue.Id;
        newTestCase.Preferred_Language__c = Language.ENGLISH.name();
        newTestCase.RecordTypeId = recordType.Id;

        insert newTestCase;
        update newTestCase;

        Group expectedQueue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department_English'];
        Case newCase = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id=:newTestCase.Id];
   
        System.assertEquals(newCase.OwnerId, expectedQueue.Id);
    }

    @IsTest static void shouldGetCorrectQueueAfterLanguageUpdate() {

        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department'];
        RecordType recordType = [SELECT Id, Name FROM RecordType where Name = 'Invoice Request'];
        Case newTestCase = new Case();
        newTestCase.OwnerId = queue.Id;
        newTestCase.Preferred_Language__c = Language.ENGLISH.name();
        newTestCase.RecordTypeId = recordType.Id;

        insert newTestCase;
        update newTestCase;

        newTestCase.Preferred_Language__c = Language.GERMAN.name();
        Group expectedChaneLanguageQueue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department_German'];
        update newTestCase;
        Case updatedCase = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id=:newTestCase.Id];
   
        System.assertEquals(updatedCase.OwnerId, expectedChaneLanguageQueue.Id);
    }
}
