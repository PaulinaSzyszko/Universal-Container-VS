@IsTest
private class CaseRoutingServiceTest {

    @TestSetup static void setup() {

        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department'];
        RecordType recordType = [SELECT Id, Name FROM RecordType where Name = 'Invoice Request'];
        Case newTestCase = new Case();
        newTestCase.OwnerId = queue.Id;
        newTestCase.Preferred_Language__c = Language.ENGLISH.name();
        newTestCase.RecordTypeId = recordType.Id;

        insert newTestCase;
    }

    @isTest static void shouldGetCorrectQueueForCaseGivenExistingCaseId() {

        //given
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Payment_Department_English'];
        Case newTestCase = [SELECT Id, OwnerId, Preferred_Language__c FROM Case];

        //when
        Id getQueueId = CaseRoutingService.getInstance().getQueueForCase(newTestCase);

        //then
        System.assertEquals(queue.Id, getQueueId);
    }

    @IsTest static void shouldReturnNullGivenNotExistingLanguage() {

        //given
        User user = [SELECT Id, Name FROM User Where Name = 'System'];
        Case newTestCase = [SELECT Id, OwnerId,Preferred_Language__c FROM Case];
        newTestCase.OwnerId = user.Id;

        update newTestCase;

        //when
        Id getQueueId = CaseRoutingService.getInstance().getQueueForCase(newTestCase);

        //then
        System.assertEquals(null, getQueueId);
    }
}