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
               
                    System.debug('Old Case preffered language: '+ oldCases.get(newCase.Id).Preferred_Language__c );
                    System.debug('Id: ' + oldCases.get(newCase.Id));
                    System.debug('New language: ' + newCase.Preferred_Language__c);
                    System.debug('Old Case queue: ' + oldCases.get(newCase.id).OwnerId);
                    System.debug('Enum: ' + Language.valueOf(oldCases.get(newCase.Id).Preferred_Language__c));
    
                    String queueDispatcherName = CaseRoutingService.getInstance().getQueueDispatcherName(oldCases.get(newCase.Id).OwnerId, Language.valueOf(oldCases.get(newCase.Id).Preferred_Language__c));
                    System.debug('queueDispatcherName: '+queueDispatcherName);
                    Id queue = CaseRoutingService.getInstance().getQueueForDispatcher(queueDispatcherName, Language.valueOf(newCase.Preferred_Language__c));
                    System.debug('queue: '+ queue);
                    newCase.OwnerId = queue;
                }
            }
        }
    }

}