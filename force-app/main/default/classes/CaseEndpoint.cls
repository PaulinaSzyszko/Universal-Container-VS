@RestResource(urlMapping='/cases/*')
global with sharing class CaseEndpoint {
    @TestVisible private static final String PARAM_EXTERNAL_ID = 'external_id';
    @TestVisible private static final String EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED = 'Wrong parameter provided';
    @TestVisible private static final String EXCEPTION_MESSAGE_CASE_NOT_FOUND = 'Case with given id not found';

    @HttpPost
    global static void upsertCases() {

        String requestBody = RestContext.request.requestBody.toString();
        List<CaseEndpointDTO> casesToUpdate = (List<CaseEndpointDTO>) JSON.deserialize(requestBody, List<CaseEndpointDTO>.class);
        List<Case> casesToUpsert = new List<Case>();
        for (CaseEndpointDTO receivedCase : casesToUpdate) {

            Case newCase = new Case();

            newCase.Preferred_Language__c = receivedCase.Preferred_language;
            newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(receivedCase.record_type);
            newCase.Priority = receivedCase.Priority;
            newCase.Subject = receivedCase.Subject;
            newCase.Description = receivedCase.Description;
            newCase.Comments = receivedCase.Comments;
            newCase.SuppliedEmail = receivedCase.supplied_email;
            newCase.SuppliedPhone = receivedCase.supplied_phone;
            newCase.SuppliedName = receivedCase.supplied_name;
            newCase.External_Id__c = receivedCase.external_id;
            newCase.Last_Change_Org_Id__c = receivedCase.last_change_source_org;
            casesToUpsert.add(newCase);
        }
        upsert casesToUpsert Case.External_Id__c;
    }

    @HttpDelete
    global static void deleteCases() {
        
        String externalId = RestContext.request.params.get(PARAM_EXTERNAL_ID);
        TRY {
            deleteCasesByExternalId(externalId);
            if (String.isBlank(externalId)) {
                throw new WrongParametersProvidedException(EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED);
            }

        } CATCH (Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 400;
        }

    }

    private static void deleteCasesByExternalId(String receivedExternalId) {

        List<String> externalIds = receivedExternalId.split(',');
        TRY {
            List<Case> casesToDelete = [SELECT External_Id__c FROM Case WHERE External_Id__c in :externalIds];

            if (casesToDelete.isEmpty()) {
                throw new ResourceNotFoundException(EXCEPTION_MESSAGE_CASE_NOT_FOUND);
            }
            delete casesToDelete;
        } CATCH (Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 400;
        }
    }

    private class ResourceNotFoundException extends Exception {
    }
    private class WrongParametersProvidedException extends Exception {
    }
}
