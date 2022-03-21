public with sharing class UCDCaseCalloutService {

    private static Map<Id, String> adjustRecordTypeForReceiver = new Map<Id, String>{
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST) => 'Invoice_Request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_CORRECTION) => 'Invoice_Correction',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_QUESTION) => 'Delivery_Information',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_CHANGE_REQUEST) => 'Pickup_Request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_DELIVERY_COMPLAINT) => 'Delivery_Complaint',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_MISSING_DAMAGED_GOODS) => 'Missing/Damaged_Goods',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_OTHER) => 'Other'
    };

    public static void sendUpsertCallout(List<Case> caseData) {

        List<CaseEndpointDTO> dtos = mapCasesToDtos(caseData);
        String serializedCases = JSON.serialize(dtos);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Denys_Org/services/apexrest/cases');
        //request.setEndpoint('callout:Filip_Org/services/apexrest/case');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(serializedCases);

        HttpResponse response = http.send(request);
    }

    private static List<CaseEndpointDTO> mapCasesToDtos(List<Case> caseData) {
        List<CaseEndpointDTO> dtos = new List<CaseEndpointDTO>();

        for (Case caseItem : caseData) {
            CaseEndpointDTO dto = new CaseEndpointDTO(caseItem);
            dto.record_type = adjustRecordTypeForReceiver.get(caseItem.RecordTypeId);
            dtos.add(dto);
        }
        return dtos;
    }

//    public static void sendDeleteCallout(List<Case> caseIdsFromParameter) {
//
//        for (Case caseToDelete : caseIdsFromParameter) {
//            Http http = new Http();
//            HttpRequest request = new HttpRequest();
//            request.setEndpoint('callout:Denys_Org/services/apexrest/cases?external_Id=' + caseToDelete.External_Id__c);
//            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
//            // request.setBody()
//            request.setMethod('DELETE');
//            http.send(request);
//        }
//    }

    public static void sendDeleteCallout(List<Case> casesReceivedToDelete) {
        system.debug('Test');
        String externalId = '?external_id=';
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        for (Case processedCase : casesReceivedToDelete) {
            externalId += processedCase.External_Id__c + ',';
        }

        externalId = externalId.removeEnd(',');

        request.setEndpoint('callout:Denys_Org/services/apexrest/cases' + externalId);
        HttpResponse response = http.send(request);
    }

}