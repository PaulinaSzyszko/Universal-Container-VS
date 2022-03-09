public with sharing class CaseRoutingConfiguration {

    private static CaseRoutingConfiguration instance;
    private Map<String, Case_Routing__mdt> configMap;

    private CaseRoutingConfiguration() {
        configMap = new Map<String, Case_Routing__mdt>();
        init();
    }

    public static CaseRoutingConfiguration getInstance() {
        if (instance == null) {
            instance = new CaseRoutingConfiguration();
        }
        return instance;
    }

    private List<Case_Routing__mdt> retrieveMetadata() {
        return [
                SELECT Id, DeveloperName, Queue_Dispatcher__c, Routing_Chinese__c, Routing_English__c,
                        Routing_French__c, Routing_German__c, Routing_Italian__c,
                        Routing_Portuguese__c
                FROM Case_Routing__mdt
        ];
    }
    private void fillConfigMap(List<Case_Routing__mdt> caseRoutingConfig) {
        for (Case_Routing__mdt routing : caseRoutingConfig) {
            configMap.put(routing.Queue_Dispatcher__c, routing);
        }
    }

    private void init() {
        fillConfigMap(retrieveMetadata());
    }

    public Case_Routing__mdt getRoutingData(String queueDispatcherApiName) {
        return configMap.get(queueDispatcherApiName);
    }

    public List<Case_Routing__mdt> getAllRoutingConfig() {
        return configMap.values();
    }

}