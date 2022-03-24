public with sharing class UCDCaseCalloutService {

    private static final String DENYS_ORG_ENDPOINT = 'callout:Denys_Org/services/apexrest/cases';
    // private static final String FILIPS_ORG_ENDPOINT = 'callout:Filip_Org/services/apexrest/case';
    private static final String URL_PARAM_EXTERNAL_ID = 'external_id';

    private static Map<Id, String> adjustRecordTypeForReceiver = new Map<Id, String>{
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST) => 'Invoice_Request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_CORRECTION) => 'Invoice_Correction',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_QUESTION) => 'Delivery_Information',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_CHANGE_REQUEST) => 'Pickup_Request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_DELIVERY_COMPLAINT) => 'Delivery_Complaint',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_MISSING_DAMAGED_GOODS) => 'Missing/Damaged_Goods',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_OTHER) => 'Other'
    };

    @future(callout=true)
    public static void sendUpsertCallout(Set<String> casesExternalIds) {
        System.debug(casesExternalIds);
        List<Case> casesToSend = [
                SELECT External_Id__c, Preferred_Language__c, RecordType.DeveloperName, Priority, Origin, Subject, Description, Comments, SuppliedEmail, SuppliedPhone, SuppliedName, Last_Change_Org_Id__c
                FROM Case
                WHERE External_Id__c in :casesExternalIds
        ];

        System.debug(casesToSend);
        sendUpsertCallout(casesToSend);
    }

    public static void sendUpsertCallout(List<Case> caseData) {

        List<CaseEndpointDTO> dtos = mapCasesToDtos(caseData);
        String serializedCases = JSON.serialize(dtos);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DENYS_ORG_ENDPOINT);
        System.debug(DENYS_ORG_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(serializedCases);
        System.debug(serializedCases);

        HttpResponse response = http.send(request);
        System.debug(response);
        System.debug(response.getBody());

    }

    @Future(Callout=true)
    public static void sendDeleteCallout(Set<String> casesExternalIds) {
        List<Case> casesList = new List<Case>();
        for (String externalId : casesExternalIds) {
            casesList.add(new Case(External_Id__c = externalId));
        }
        sendDeleteCallout(casesList);
    }

    public static void sendDeleteCallout(List<Case> casesReceivedToDelete) {

        HttpRequest request = new HttpRequest();

        Http http = new Http();
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndpoint(DENYS_ORG_ENDPOINT + buildEndpointParameterForDelete(casesReceivedToDelete));
        HttpResponse response = http.send(request);
        System.debug(response);
        System.debug(response.getBody());
        System.debug(response.getBody());
    }

    public static String buildEndpointParameterForDelete(List<Case> casesReceivedToDelete) {

        List<String> externalIdList = new List<String>();
        for (Case processedCase : casesReceivedToDelete) {
            externalIdList.add(processedCase.External_Id__c);
        }
        String parameterBuilt = new RestUtilities.UrlParameterBuilder().addParam(URL_PARAM_EXTERNAL_ID, String.join(externalIdList, ',')).build();
        System.debug(parameterBuilt);
        if (String.isNotBlank(parameterBuilt)) {
            return parameterBuilt;
        }
        return null;
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

}