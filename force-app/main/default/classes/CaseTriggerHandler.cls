public class CaseTriggerHandler {

    private Set<String> caseExternalIdsToDelete;
    private Set<String> casesExternalIdsToUpsert;


    CaseTriggerHandlerHelper helper;

    public CaseTriggerHandler() {
        caseExternalIdsToDelete = new Set<String>();
        casesExternalIdsToUpsert = new Set<String>();
        helper = new CaseTriggerHandlerHelper();
    }

    public void run() {

        if (Trigger.isBefore) {
            bulkBefore();
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    //TODO before insert
                }
            } else if (Trigger.isUpdate) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    beforeUpdate((Case) Trigger.oldMap.get(newCase.Id), newCase);
                }
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                for (Case newCase : (List<Case>) Trigger.new) {
                    //TODO after insert
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

    public void beforeUpdate(Case oldCase, Case newCase) {

        helper.updateSourceOrgField(oldCase, newCase);
        helper.getQueueForCase(newCase);
        helper.setGuiNumberForNewCase(newCase);
        helper.getDefaultQueueForCase(oldCase, newCase);
        helper.setTotalTimeOpened(oldCase, newCase);

        if (newCase.Booking_number_from_contact_form__c != null && newCase.Schedule_Booking__c == null) {
            System.debug(newCase);
            helper.setScheduleBookingId(newCase);
        }
    }

    public void bulkBefore() {
        helper.bookings = new List<Schedule_Booking__c>([SELECT Name, Id FROM Schedule_Booking__c]);
    }

    public void afterInsert(Case newCase) {

    }

    public void afterUpdate(Case oldCase, Case newCase) {
        if (helper.isSensitiveDataChanged(oldCase, newCase)) {
            System.debug('afterUpdate');

            casesExternalIdsToUpsert.add(newCase.External_Id__c);
            System.debug(casesExternalIdsToUpsert);
//            if (newCase.Last_Change_Org_Id__c != 'DENYS') {
//                casesExternalIdsToUpsert.add(newCase.External_Id__c);
//            }
        }


    }
    public void afterDelete(Case oldCase) {
        if (oldCase.External_Id__c != null) {
            caseExternalIdsToDelete.add(oldCase.External_Id__c);
        }
    }

    public void andFinally() {

        if (Trigger.isUpdate) {
            System.debug('Upsert');
            if (!casesExternalIdsToUpsert.isEmpty()) {
                System.debug(casesExternalIdsToUpsert);
                UCDCaseCalloutService.sendUpsertCallout(casesExternalIdsToUpsert);
            }
        }
        if (Trigger.isDelete) {
            if (!caseExternalIdsToDelete.isEmpty()) {
                UCDCaseCalloutService.sendDeleteCallout(caseExternalIdsToDelete);
            }
        }
    }

}