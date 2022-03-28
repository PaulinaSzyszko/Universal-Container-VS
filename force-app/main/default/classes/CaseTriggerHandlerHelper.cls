
public with sharing class CaseTriggerHandlerHelper {

    @TestVisible private static final String SOURCE_ORG_NAME = 'PAULINA';
    @TestVisible private static final String SOURCE_ORG_NAME_FILIP = 'FILIP';
    @TestVisible static final String GROUP_TYPE = 'Queue';
    @TestVisible static final String QUEUE_DEVELOPER_NAME_MAIN_QUEUE = 'Payment_Department';
    @TestVisible static final String QUEUE_DEVELOPER_NAME_ENGLISH = 'Payment_Department_English';
    @TestVisible static final String QUEUE_DEVELOPER_NAME_GERMAN = 'Payment_Department_German';

    public Map<String, Id> bookings;


    //TODO  Fix KPI 'Case Total Open Time'
    public void setTotalTimeOpened(Case oldCase, Case newCase) {

        if (newCase.isClosed != oldCase.isClosed) {
            if (newCase.isClosed) {
                System.debug(LoggingLevel.ERROR, newCase.Recent_closed_Date__c);
                if (newCase.Recent_closed_Date__c != null) {

                    Long newTotal = newCase.Total_open_case__c.longValue() + (Datetime.now().getTime() - newCase.Recent_closed_Date__c.getTime());
                    newCase.Total_time_opened__c = calculateTotalTimeOpened(newTotal);
                    newCase.Total_open_case__c = newTotal;
                } else {
                    Long newTotal = Datetime.now().getTime() - newCase.CreatedDate.getTime();
                    newCase.Total_open_case__c = newTotal;
                    newCase.Total_time_opened__c = calculateTotalTimeOpened(newTotal);
                }
            }
            newCase.Recent_closed_Date__c = Datetime.now();
        }
    }

    public void setBookings(Set<String> bookingNames) {

        bookings = new Map<String, Id>();

        for (Schedule_Booking__c booking : [SELECT Id, Name FROM Schedule_Booking__c WHERE Name IN :bookingNames]) {
            bookings.put(booking.Name, booking.Id);
        }
    }

    public void setScheduleBookingId(Case newCase) {

        if (newCase.Booking_number_from_contact_form__c != null && newCase.Schedule_Booking__c == null && bookings != null) {
            newCase.Schedule_Booking__c = bookings.get(newCase.Booking_number_from_contact_form__c);
        }
    }

    public void updateSourceOrgField(Case oldCase, Case newCase) {

        System.debug(oldCase.Last_Change_Org_Id__c);
        System.debug(newCase.Last_Change_Org_Id__c);
        //newCase.Last_Change_Org_Id__c != oldCase.Last_Change_Org_Id__c
        if (isSensitiveDataChanged(oldCase, newCase)) {
            if (RestUtilities.isRestApiContext() == false) {
                newCase.Last_Change_Org_Id__c = SOURCE_ORG_NAME;
            }
        }
    }

    public void setSourceOrgFieldUponInsert(Case newCase) {

        if (newCase.Last_Change_Org_Id__c == null) {
            newCase.Last_Change_Org_Id__c = SOURCE_ORG_NAME;
        }
    }

    public void getQueueForCase(Case newCase) {

        if (newCase.OwnerId.getSobjectType() != User.getSObjectType()) {
            Id queueLanguageId = CaseRoutingService.getInstance().getQueueForCase(newCase);
            if (queueLanguageId != null) {
                System.debug('getQueueForCase' + queueLanguageId);
                newCase.OwnerId = queueLanguageId;
            }
        }
    }

    public void generateExternalIdForNewCase(Case newCase) {
        System.debug(newCase.External_Id__c);
        if (newCase.External_Id__c == null) {
            newCase.External_Id__c = GuidGenerator.generate();
        }

    }

    public void getDefaultQueueForCase(Case oldCase, Case newCase) {

        if (newCase.OwnerId.getSobjectType() != User.getSObjectType()) {
            if (newCase.Preferred_Language__c != oldCase.Preferred_Language__c) {
                String queueDispatcherName = CaseRoutingService.getInstance().getQueueDispatcherName(oldCase.OwnerId, Language.valueOf(oldCase.Preferred_Language__c));
                Id queue = CaseRoutingService.getInstance().getQueueForDispatcher(queueDispatcherName, Language.valueOf(newCase.Preferred_Language__c));
                newCase.OwnerId = queue;
            }
        }
    }

    public Boolean isSensitiveDataChanged(Case oldCase, Case newCase) {

        return newCase.Preferred_Language__c != oldCase.Preferred_Language__c ||
                newCase.RecordTypeId != oldCase.RecordTypeId ||
                newCase.Priority != oldCase.Priority ||
                newCase.Origin != oldCase.Origin ||
                newCase.Subject != oldCase.Subject ||
                newCase.Description != oldCase.Description ||
                newCase.Comments != oldCase.Comments ||
                newCase.SuppliedEmail != oldCase.SuppliedEmail ||
                newCase.SuppliedPhone != oldCase.SuppliedPhone ||
                newCase.SuppliedName != oldCase.SuppliedName;
    }

    private String calculateTotalTimeOpened(Long timeOpenedMillis) {

        Long seconds = timeOpenedMillis / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;
        Long secondsLeft = Math.mod(seconds, 60);
        Long minutesLeft = Math.mod(minutes, 60);
        Long horusLeft = Math.mod(hours, 24);

        return 'D: ' + String.valueOf(days) + ' H: ' + String.valueOf(horusLeft) + ' M: ' + String.valueOf(minutesLeft);
    }
}







