@RestResource(urlMapping='/cases')
global with sharing class CaseEndpoint {


    @HttpPost
    global static void upsertCases(){

        String requestBody = RestContext.request.requestBody.toString();
        List<CaseWrapper> casesToUpdate =  (List<CaseWrapper>) JSON.deserialize(requestBody, List<CaseWrapper>.class);

        for(CaseWrapper receivedCase: casesToUpdate){
            Case newCase= new Case();

            newCase.Preferred_Language__c = receivedCase.Preferred_Language;
            newCase.RecordTypeId = CaseUtilies.getRecordTypeIdByDevName(receivedCase.record_type);
            newCase.Priority = receivedCase.Priority;
            newCase.Subject = receivedCase.Subject;
            newCase.Description = receivedCase.Description;
            newCase.Comments = receivedCase.Comments;
            newCase.SuppliedEmail = receivedCase.SuppliedEmail;
            newCase.SuppliedPhone = receivedCase.SuppliedPhone;
            newCase.SuppliedName = receivedCase.SuppliedName;
            newCase.Id = receivedCase.external_id;
            upsert newCase Case.Id;

            //case.ide zmienic na extrenal id, ktore stworze
        }
    }

    @HttpDelete
    global static void deleteCase(){
        System.debug('Delete Case');
    }
}
