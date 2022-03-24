trigger CaseTrigger on Case (before insert, before update, after update, after insert, after delete) {

    CaseTriggerHandler handler = new CaseTriggerHandler();
    handler.run();
}