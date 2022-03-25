public class CaseTriggerHandler {

    private static Set<String> casesExternalIdsToUpsert;
    private static Set<String> casesExternalIdsToDelete;
    private static final String LAST_SOURCE_ORG_DENYS = 'DENYS';
    private static Boolean isUpsertRequestSend = false;
    private static Boolean isDeleteRequestSend = false;
    CaseTriggerHandlerHelper helper;

    public CaseTriggerHandler() {
        casesExternalIdsToUpsert = new Set<String>();
        casesExternalIdsToDelete = new Set<String>();
        helper = new CaseTriggerHandlerHelper();
    }

    public void run() {

        if (Trigger.isBefore) {
            for (Case newCase : (List<Case>) Trigger.new) {
                bulkBefore(newCase);
            }
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeUpdate((Case) Trigger.oldMap.get(newCase.Id), newCase);
                }
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    afterInsert(newCase);
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    afterUpdate((Case) Trigger.oldMap.get(newCase.Id), newCase);
                }
            } else if (Trigger.isDelete) {
                for (Case oldCase : (List<Case>) Trigger.old) {
                    afterDelete(oldCase);
                }
            }
        }
        andFinally();
    }

    public void bulkBefore(Case newCase) {

        if (newCase.Booking_number_from_contact_form__c != null && newCase.Schedule_Booking__c == null) {
            helper.bookings = new List<Schedule_Booking__c>([SELECT Name, Id FROM Schedule_Booking__c]);
        }
    }

    public void beforeInsert(Case newCase) {

        if (newCase.External_Id__c == null) {
            helper.setSourceOrgFieldUponInsert(newCase);
            helper.generateExternalIdForNewCase(newCase);
        }
    }

    public void beforeUpdate(Case oldCase, Case newCase) {

        helper.getQueueForCase(newCase);
        helper.getDefaultQueueForCase(oldCase, newCase);
        helper.setTotalTimeOpened(oldCase, newCase);

        if (newCase.Last_Change_Org_Id__c != oldCase.Last_Change_Org_Id__c) {
            helper.updateSourceOrgField(oldCase, newCase);
        }

        if (helper.bookings != null) {
            helper.setScheduleBookingId(newCase);
        }
    }

    public void afterInsert(Case newCase) {

        if (newCase.External_Id__c != null) {
            if (newCase.Last_Change_Org_Id__c != LAST_SOURCE_ORG_DENYS) {
                casesExternalIdsToUpsert.add(newCase.External_Id__c);
            }
        }
    }

    public void afterUpdate(Case oldCase, Case newCase) {
        if (newCase.External_Id__c != null) {
            if (helper.isSensitiveDataChanged(oldCase, newCase) && newCase.Last_Change_Org_Id__c != LAST_SOURCE_ORG_DENYS) {
                casesExternalIdsToUpsert.add(newCase.External_Id__c);
            }
        }
    }

    public void afterDelete(Case oldCase) {

        if (oldCase.External_Id__c != null && oldCase.Last_Change_Org_Id__c != LAST_SOURCE_ORG_DENYS) {
            casesExternalIdsToDelete.add(oldCase.External_Id__c);
        }
    }

    public void andFinally() {

        if (Trigger.isDelete) {
            if (!casesExternalIdsToDelete.isEmpty() && isDeleteRequestSend == false) {
                isDeleteRequestSend = true;
                System.enqueueJob(new DeleteCasesCalloutQueueable(casesExternalIdsToDelete));
            }
        } else {
            if (!casesExternalIdsToUpsert.isEmpty() && isUpsertRequestSend == false) {
                isUpsertRequestSend = true;
                System.enqueueJob(new UpsertCasesCalloutQueueable(casesExternalIdsToUpsert));
            }
        }
    }
}