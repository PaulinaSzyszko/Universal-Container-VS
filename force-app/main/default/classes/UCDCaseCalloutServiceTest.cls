
@IsTest
private class UCDCaseCalloutServiceTest {

    static Case createCase() {

        Case newCase = new Case();
        newCase.Preferred_Language__c = 'English';
        newCase.Priority = 'Medium';
        newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_QUESTION);
        newCase.Origin = 'Web';
        newCase.Subject = 'Subject';
        newCase.Description = 'Description';
        newCase.Comments = 'Comments';
        newCase.SuppliedEmail = 'email@test.pl';
        newCase.SuppliedPhone = '555444333';
        newCase.SuppliedName = 'Felix Test';

        insert newCase;
        return [
                SELECT Preferred_Language__c,
                        External_Id__c,
                        Priority,
                        RecordTypeId,
                        Origin,
                        Subject,
                        Description,
                        Comments,
                        SuppliedEmail,
                        SuppliedPhone,
                        SuppliedName,
                        RecordType.DeveloperName,
                        Last_Change_Org_Id__c
                FROM Case
                WHERE id = :newCase.Id
        ];
    }

    @IsTest private static void shouldSentUpsertCallouts() {

        Case newCase = createCase();
        Set<String> cases = new Set<String>{
                newCase.External_Id__c
        };

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        HttpResponse response = UCDCaseCalloutService.sendUpsertCallout(cases);
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }
    
    @IsTest private static void shouldDeleteCases() {

        Case newCase = createCase();
        Case secondCase = createCase();
        Set<String> cases = new Set<String>();
        cases.add(newCase.External_Id__c);
        cases.add(secondCase.External_Id__c);

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        HttpResponse response = UCDCaseCalloutService.sendDeleteCallout(cases);
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @IsTest private static void shouldBuildParametersForDelete() {

        Case firstCase = createCase();
        Case secondCase = createCase();

        List<Case> cases = new List<Case>();

        cases.add(firstCase);
        cases.add(secondCase);

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        UCDCaseCalloutService.sendDeleteCallout(cases);
        String parameters = UCDCaseCalloutService.buildEndpointParameterForDelete(cases);
        Test.stopTest();

        String expectedParameters = '?' + UCDCaseCalloutService.URL_PARAM_EXTERNAL_ID + '=' + firstCase.External_Id__c + ',' + secondCase.External_Id__c;
        System.assertEquals(expectedParameters, parameters);

    }

    @IsTest private static void shouldReturnNullGivenEmptyParameterForDelete() {

        List<Case> cases = new List<Case>();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        String parameters = UCDCaseCalloutService.buildEndpointParameterForDelete(cases);
        Test.stopTest();

        System.assertEquals(null, parameters);
    }

    @IsTest private static void shouldReturnNullGivenNullForDelete() {

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        String parameters = UCDCaseCalloutService.buildEndpointParameterForDelete(null);
        Test.stopTest();

        System.assertEquals(null, parameters);
    }
}