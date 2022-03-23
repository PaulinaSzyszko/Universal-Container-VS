trigger CaseTrigger on Case (before insert, before update) {

    CaseTriggerHandler handler = new CaseTriggerHandler();
    //handler.run();
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }

}