public without sharing class CaseUtilies {

    private static Map<String, Id> recordTypeByDevName;

    public static Id getRecordTypeIdByDevName(String rtDevName){
        if( recordTypeByDevName == null){

            recordTypeByDevName = new Map<String, Id>();
            for (RecordTypeInfo rtInfo: Case.getSObjectType().getDescribe().getRecordTypeInfos()){

               recordTypeByDevName.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());

            }
        }
        return recordTypeByDevName.get(rtDevName);
    }
}
