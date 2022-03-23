public class CaseTriggerHandler {

    CaseTriggerHandlerHelper helper = new CaseTriggerHandlerHelper();

//    public void run() {
//        if (Trigger.isBefore) {
//            if (Trigger.isInsert) {
//                for (Case newCase : (List<Case>) Trigger.new) {
//                    //TODO before insert
//                }
//            } else if (Trigger.isUpdate) {
//                for (Case newCase : (List<Case>) Trigger.new) {
//                    // beforeUpdate(Trigger.oldMap.get(newCase.Id), newCase);
//                }
//            }
//        }
//    }

    public void beforeUpdate(List<Case> cases, Map<Id, Case> newCases, Map<Id, Case> oldCases) {

        helper.getQueueForCase(cases);
        helper.getDefaultQueueForCase(newCases, oldCases);
        helper.setTotalTimeOpened(newCases, oldCases);
        helper.findScheduleBookingId(cases);
        helper.updateLastChangeSourceOrgField(newCases, oldCases);
    }
}