//@RestResource(urlMapping='/cases')
@RestResource(urlMapping='/cases/*')

global with sharing class CaseEndpoint {
    private static final String PARAM_EXTERNAL_ID = 'external_id';
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
            newCase.SuppliedEmail = receivedCase.SuppliedEmail;
            newCase.SuppliedPhone = receivedCase.SuppliedPhone;
            newCase.SuppliedName = receivedCase.SuppliedName;
            newCase.External_Id__c = receivedCase.external_id;
            casesToUpsert.add(newCase);
        }
        upsert casesToUpsert Case.External_Id__c;
    }

    @HttpDelete
    global static void deleteCases() {
        String externalId = RestContext.request.params.get(PARAM_EXTERNAL_ID);
        if (!String.isBlank(externalId)) {
            deleteCasesByExternalId(externalId);
        } else {

            String message = 'None or Bad External Id was passed into the parameter.';
            RestContext.response.responseBody = Blob.valueOf(message);
            RestContext.response.statusCode = 400;
        }
    }

    private static void deleteCasesByExternalId(String receivedExternalId) {

        List<String> externalIds = receivedExternalId.split(',');
        List<Case> casesToDelete = new List<Case> ();
        //casesToDelete.addAll([SELECT External_Id__c FROM Case WHERE External_Id__c in :externalIds]);
        TRY {
            casesToDelete.add([SELECT External_Id__c FROM Case WHERE External_Id__c in :externalIds]);
        } CATCH (Exception e) {
            String message = 'Required parameters do not exist';
            RestContext.response.responseBody = Blob.valueOf(message);
            RestContext.response.statusCode = 400;
        }
        delete casesToDelete;
    }
}
