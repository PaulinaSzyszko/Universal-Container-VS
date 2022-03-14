public class CaseTriggerHandler {

    public void beforeUpdate(List<Case> cases) {
        for (Case newCase : cases) {
            if (newCase.OwnerId.getSobjectType() != User.getSObjectType()) {             
                Id queueLanguageId = CaseRoutingService.getInstance().getQueueForCase(newCase);
                if (queueLanguageId != null) {
                    newCase.OwnerId = queueLanguageId;
                }
            }
        }
    }

    public void beforeUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases) {
        for (Case newCase : newCases.values()) {
            if(newCase.OwnerId.getSobjectType() != User.getSObjectType()){
                if (newCase.Preferred_Language__c != oldCases.get(newCase.Id).Preferred_Language__c) {
                    String queueDispatcherName = CaseRoutingService.getInstance().getQueueDispatcherName(oldCases.get(newCase.Id).OwnerId, Language.valueOf(oldCases.get(newCase.Id).Preferred_Language__c));
                    Id queue = CaseRoutingService.getInstance().getQueueForDispatcher(queueDispatcherName, Language.valueOf(newCase.Preferred_Language__c));
                    newCase.OwnerId = queue;
                }
            }
        }
    }

    private String calculateTotalTimeOpened(Long timeOpenedMilis) {

        Long seconds = timeOpenedMilis / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24; 
        Long secondsLeft = Math.mod(seconds, 60);
        Long minutesLeft = Math.mod(minutes, 60);
        Long horusLeft = Math.mod(hours, 24);

        return 'D: ' + String.valueOf(days) + ' H: ' +  String.valueOf(horusLeft) + ' M: ' + String.valueOf(minutesLeft);
    }

    public void setTotalTimeOpened(Map<Id, Case> newCases, Map<Id, Case> oldCases) {

        for (Id newCaseId : newCases.keySet()) {
            if (newCases.get(newCaseId).isClosed != oldCases.get(newCaseId).isClosed) {
                if (newCases.get(newCaseId).isClosed) {
                    if (newCases.get(newCaseId).Recent_closed_Date__c != null) {

                        Long newTotal = newCases.get(newCaseId).Total_open_case__c.longValue() + (Datetime.now().getTime() - newCases.get(newCaseId).Recent_closed_Date__c.getTime());
                        newCases.get(newCaseId).Total_time_opened__c =  calculateTotalTimeOpened(newTotal);
                        newCases.get(newCaseId).Total_open_case__c = newTotal;
                    } else {
                        Long newTotal = Datetime.now().getTime() - newCases.get(newCaseId).CreatedDate.getTime();
                        newCases.get(newCaseId).Total_open_case__c = newTotal;
                        newCases.get(newCaseId).Total_time_opened__c =  calculateTotalTimeOpened(newTotal);
                    }
                }
                newCases.get(newCaseId).Recent_closed_Date__c = Datetime.now();
            }
        }
    }

    public void findScheduleBookingId(List<Case> cases){

        for (Case newCase: cases ){
            String findBookingName = newCase.Booking_number_from_contact_form__c;          
            List< Schedule_Booking__c> scheduleBooking =[SELECT Name FROM Schedule_Booking__c WHERE Name =:findBookingName];
            if (scheduleBooking.size() >0){
                newCase.Schedule_Booking__c = scheduleBooking.get(0).Id; 
            }
        }
    }
}