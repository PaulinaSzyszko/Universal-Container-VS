public with sharing class CaseRoutingService {

    private static final Map<Language, SObjectField> languageToQueueMap = new Map<Language, SObjectField>{
            Language.ENGLISH => Case_Routing__mdt.Routing_English__c,
            Language.GERMAN => Case_Routing__mdt.Routing_German__c,
            Language.CHINESE => Case_Routing__mdt.Routing_Chinese__c,
            Language.FRENCH => Case_Routing__mdt.Routing_French__c,
            Language.ITALIAN => Case_Routing__mdt.Routing_Italian__c,
            Language.PORTUGUESE => Case_Routing__mdt.Routing_Portuguese__c
    };

    private static CaseRoutingService instance;
    private static Map<Id, Group> queues;
    private static Map<String, Group> developerNameMap; //change queueByDeveloperNameMap

    public static CaseRoutingService getInstance() {
        if (CaseRoutingService.instance == null) {
            CaseRoutingService.instance = new CaseRoutingService();

        }
        return CaseRoutingService.instance;
    }

    public Id getQueueForCase(Case newCase) {
        if (!queues.containsKey(newCase.OwnerId)) {
            return null;
        }

        Case_Routing__mdt configuration = CaseRoutingConfiguration.getInstance().getRoutingData(queues.get(newCase.OwnerId).DeveloperName);
        System.debug('configuration z CaseRouting_mdt ' + configuration);
        if (configuration != null) {

            SObjectField languageToGet = languageToQueueMap.get(Language.valueOf(newCase.Preferred_Language__c));
            system.debug('preferred language: ' + languageToGet);
            String config = (String) configuration.get(languageToGet);
            System.debug('configuration: ' + config);
            Group routedQueue = developerNameMap.get(config);
            System.debug('routedQueue: ' + routedQueue);
            return routedQueue != null ? routedQueue.Id : null;
        }
        return null;
    }

    public String getQueueDispatcherName(Id languageBasedQueueName, Language queueLanguage) {

        String  changeLanguageBasedToString =queues.get(languageBasedQueueName).DeveloperName;

        for (Case_Routing__mdt routing : CaseRoutingConfiguration.getInstance().getAllRoutingConfig()) {
            SObjectField routingFieldBasedOnLanguage = languageToQueueMap.get(queueLanguage);
            System.debug('routing based language: ' + routingFieldBasedOnLanguage);
            System.debug('language based queue name: ' + changeLanguageBasedToString);
            System.debug('routing get: ' + routing.get(routingFieldBasedOnLanguage));

            if (routingFieldBasedOnLanguage != null && routing.get(routingFieldBasedOnLanguage) == changeLanguageBasedToString) {
                system.debug('Queue dispatcher: ' + routing.Queue_Dispatcher__c);
                return routing.Queue_Dispatcher__c;
            }
        }
        return null;
    }

    public Id getQueueForDispatcher(String queueDispatcher, Language language) {
        Case_Routing__mdt configuration = CaseRoutingConfiguration.getInstance().getRoutingData(queueDispatcher);
        if (configuration != null) {

            SObjectField languageToGet = languageToQueueMap.get(language);
            String config = (String) configuration.get(languageToGet);
            Group routedQueue = developerNameMap.get(config);

            return routedQueue != null ? routedQueue.Id : null;
        }
        return null;
    }

    private CaseRoutingService() {
        queues = new Map <Id, Group>([SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']);
        developerNameMap = new Map<String, Group>();

        for (Group queue : queues.values()) {
            developerNameMap.put(queue.DeveloperName, queue);
        }
    }

}