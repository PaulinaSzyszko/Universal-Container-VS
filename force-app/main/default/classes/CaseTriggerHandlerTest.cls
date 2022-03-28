@IsTest
private class CaseTriggerHandlerTest {

    @TestSetup private static void setup() {

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Opportunity Test';
        newOpportunity.StageName = OpportunityUtilities.OPPORTUNITY_STAGE_NAME;
        newOpportunity.CloseDate = Date.today();
        insert newOpportunity;

        Schedule__c schedule = new Schedule__c();
        insert schedule;

        Schedule_Booking__c booking = new Schedule_Booking__c();
        booking.TEU__c = 500;
        booking.Amount__c = 100000;
        booking.Opportunity__c = newOpportunity.Id;
        booking.Schedule__c = schedule.Id;
        insert booking;

    }

    @IsTest private static void shouldInitializedCaseDataOnInsert() {

        Case newCase = new Case();
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, External_Id__c, Last_Change_Org_Id__c, Last_status_change_date__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(CaseTriggerHandlerHelper.SOURCE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
        System.debug(caseAfterInsert.External_Id__c);
        System.assertNotEquals(null, caseAfterInsert.External_Id__c);
    }

    @IsTest
    private static void shouldAssignBookingToCaseBeforeInsert() {
        Schedule_Booking__c scheduleBooking = [SELECT Id, Name FROM Schedule_Booking__c];

        System.debug(scheduleBooking);
        Case newCase = new Case();
        newCase.Booking_number_from_contact_form__c = scheduleBooking.Name;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Schedule_Booking__c, Booking_number_from_contact_form__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(scheduleBooking.Id, caseAfterInsert.Schedule_Booking__c);
    }

    @IsTest private static void shouldNotAssignBookingToCaseBeforeInsertNoValue() {
        Schedule_Booking__c scheduleBooking = [SELECT Id FROM Schedule_Booking__c];

        Case newCase = new Case();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Schedule_Booking__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(null, caseAfterInsert.Schedule_Booking__c);
    }

    @IsTest private static void shouldNotAssignBookingToCaseBeforeInsertNoBooking() {
        Schedule_Booking__c scheduleBooking = [SELECT Id FROM Schedule_Booking__c];

        Case newCase = new Case();
        newCase.Booking_number_from_contact_form__c = 'Not existing schedule Booking Id';

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Schedule_Booking__c, Booking_number_from_contact_form__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(null, caseAfterInsert.Schedule_Booking__c);
    }

    @IsTest private static void shouldAssignCorrectQueueToCaseAfterInsert() {

        Group queue;
        Group expectedQueue;
        for (Group queueRecord : [SELECT Id, DeveloperName FROM Group WHERE Type = :CaseTriggerHandlerHelper.GROUP_TYPE AND DeveloperName In (:CaseTriggerHandlerHelper.QUEUE_DEVELOPER_NAME_MAIN_QUEUE, :CaseTriggerHandlerHelper.QUEUE_DEVELOPER_NAME_ENGLISH)]) {
            if (queueRecord.DeveloperName == CaseTriggerHandlerHelper.QUEUE_DEVELOPER_NAME_MAIN_QUEUE) {
                queue = queueRecord;
            } else {
                expectedQueue = queueRecord;
            }
        }

        Case newCase = new Case();

        newCase.Preferred_Language__c = Language.ENGLISH.name();
        newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(expectedQueue.Id, caseAfterInsert.OwnerId);
    }

    @IsTest private static void shouldAssignCorrectQueueToCaseBeforeUpdateLanguageChange() {

        Group expectedQueue = [SELECT Id, DeveloperName FROM GROUP WHERE Type = :CaseTriggerHandlerHelper.GROUP_TYPE AND DeveloperName = :CaseTriggerHandlerHelper.QUEUE_DEVELOPER_NAME_GERMAN];

        Case newCase = new Case();
        newCase.Preferred_Language__c = Language.ENGLISH.name();
        newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);
        insert newCase;


        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Preferred_Language__c = Language.GERMAN.name();
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(expectedQueue.id, caseAfterInsert.OwnerId);
    }

    @IsTest private static void shouldAssignSourceOrgToCaseBeforeUpdate() {

        Case newCase = new Case();
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Last_Change_Org_Id__c = CaseTriggerHandlerHelper.SOURCE_ORG_NAME_FILIP;
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(CaseTriggerHandlerHelper.SOURCE_ORG_NAME_FILIP, caseAfterInsert.Last_Change_Org_Id__c);
    }

    @IsTest private static void shouldUpdateSourceOrgWhenSensitiveDataChanged() {

        Case newCase = new Case();
        newCase.Last_Change_Org_Id__c = CaseTriggerHandlerHelper.SOURCE_ORG_NAME_FILIP;
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Subject = 'updated Subject';
        update newCase;
        System.debug(newCase.Last_Change_Org_Id__c);
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(CaseTriggerHandlerHelper.SOURCE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
    }
    // dodac negatywny test
    
    @IsTest private static void shouldSendDeleteRequestOnDelete() {

        Case newCase = new Case();
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        delete newCase;
        Test.stopTest();

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :newCase.Id ALL ROWS];
        System.assertEquals(true, caseAfterDelete.IsDeleted);
    }

    @IsTest private static void shouldSetTotalOpenedTimeBeforeUpdate() {

        Case newCase = new Case();

        insert newCase;
        newCase.Status = 'Closed';

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        update newCase;
        Test.stopTest();

        Case caseAfterUpdate = [SELECT Id, Total_open_case__c, Total_time_opened__c, IsClosed FROM Case WHERE Id = :newCase.Id];

        // System.assertNotEquals(null, caseAfterUpdate.Total_open_case__c);
        System.assertNotEquals(null, caseAfterUpdate.Total_time_opened__c);
    }
}
