@IsTest
private class CaseEndpointTest {

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

    @IsTest static void shouldUpsertCase() {

        createCase();
        Case newCase = [SELECT External_Id__c, Preferred_Language__c, RecordType.DeveloperName, Priority, Subject, Description, Comments, SuppliedEmail, Last_Change_Org_Id__c, Origin, SuppliedPhone, SuppliedName FROM Case LIMIT 1];

        CaseEndpointDTO dto = new CaseEndpointDTO(newCase);
        RestRequest request = new RestRequest();
        String serializedCase = JSON.serialize(new List<CaseEndpointDTO>{
                dto
        });
        request.requestBody = Blob.valueOf(serializedCase);
        RestContext.request = request;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Subject = 'Subject changed';
        CaseEndpoint.upsertCases();
        Test.stopTest();

        Case upsertedCase = [SELECT Id, External_Id__c, Preferred_Language__c, RecordType.DeveloperName, Priority, Subject, Description, Comments, SuppliedEmail, Last_Change_Org_Id__c, Origin, SuppliedPhone, SuppliedName FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertNotEquals(null, upsertedCase);
        System.assertNotEquals(newCase, upsertedCase);
        System.assertNotEquals(newCase.Subject, upsertedCase.Subject);
        System.assertEquals(newCase.Preferred_Language__c, upsertedCase.Preferred_Language__c);
        System.assertEquals(newCase.RecordTypeId, upsertedCase.RecordTypeId);
        System.assertEquals(newCase.Priority, upsertedCase.Priority);
        System.assertEquals(newCase.Description, upsertedCase.Description);
        System.assertEquals(newCase.SuppliedEmail, upsertedCase.SuppliedEmail);
        System.assertEquals(newCase.SuppliedPhone, upsertedCase.SuppliedPhone);
        System.assertEquals(newCase.SuppliedName, upsertedCase.SuppliedName);
        System.assertEquals(newCase.External_Id__c, upsertedCase.External_Id__c);
    }

    @IsTest static void shouldDeleteCase() {

        createCase();
        Case newCase = [SELECT External_Id__c FROM Case];

        Map<String, String> requestParam = new Map<String, String>();
        requestParam.put(CaseEndpoint.PARAM_EXTERNAL_ID, newCase.External_Id__c);
        RestRequest request = new RestRequest();
        RestContext.request = request;
        RestContext.request.params.putAll(requestParam);

        RestResponse expectedResponse = new RestResponse();
        expectedResponse.statusCode = 200;
        RestContext.response = expectedResponse;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :newCase.Id ALL ROWS];

        System.assertEquals(true, caseAfterDelete.IsDeleted);
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest static void shouldFailToDeleteCaseWhenExternalIdIsEmpty() {

        Map<String, String> requestParam = new Map<String, String>();
        requestParam.put(CaseEndpoint.PARAM_EXTERNAL_ID, ' ');
        RestRequest request = new RestRequest();
        RestContext.request = request;
        RestContext.request.params.putAll(requestParam);
        RestContext.response = new RestResponse();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(CaseEndpoint.EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED, RestContext.response.responseBody.toString());
    }

    @IsTest static void shouldFailToDeleteCaseWhenExternalIdDoesNotExist() {

        Map<String, String> requestParam = new Map<String, String>();
        requestParam.put(CaseEndpoint.PARAM_EXTERNAL_ID, 'non exist id');
        RestRequest request = new RestRequest();
        RestContext.request = request;
        RestContext.request.params.putAll(requestParam);
        RestContext.response = new RestResponse();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(CaseEndpoint.EXCEPTION_MESSAGE_CASE_NOT_FOUND, RestContext.response.responseBody.toString());
    }
}