trigger CaseTrigger on Case (before insert, before update) {

    CaseTriggerHandler handler = new CaseTriggerHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {

        handler.setTotalTimeOpened(Trigger.newMap, Trigger.oldMap);
        handler.getQueueForCase(Trigger.new);
        handler.getDefaultQueueForCase(Trigger.newMap, Trigger.oldMap);
        handler.findScheduleBookingId(Trigger.new);
        handler.updateLastChangeSourceOrgField(Trigger.newMap, Trigger.oldMap);
    }

}