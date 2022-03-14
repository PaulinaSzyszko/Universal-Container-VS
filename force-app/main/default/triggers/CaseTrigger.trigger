trigger CaseTrigger on Case (before insert, before update) {

    CaseTriggerHandler handler = new CaseTriggerHandler();
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.setTotalTimeOpened(Trigger.newMap, Trigger.oldMap);
        handler.beforeUpdate(Trigger.new);
        handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        handler.findScheduleBookingId(Trigger.new);
    }
}