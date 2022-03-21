public without sharing class CaseUtilities {

    private static Map<String, Id> recordTypeByDevName;
    public static final String RT_INVOICE_REQUEST = 'Invoice_Request';
    public static final String RT_INVOICE_CORRECTION = 'Invoice_Correction';
    public static final String RT_QUESTION = 'Question';
    public static final String RT_CHANGE_REQUEST = 'Change_request';
    public static final String RT_DELIVERY_COMPLAINT = 'Delivery_Complaint';
    public static final String RT_MISSING_DAMAGED_GOODS = 'Missing_Damaged_Goods';
    public static final String RT_OTHER = 'Other';

    public static Id getRecordTypeIdByDevName(String rtDevName) {

        if (recordTypeByDevName == null) {
            recordTypeByDevName = new Map<String, Id>();
            for (RecordTypeInfo rtInfo : Case.getSObjectType().getDescribe().getRecordTypeInfos()) {
                recordTypeByDevName.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
            }
        }
        return recordTypeByDevName.get(rtDevName);
    }

}
