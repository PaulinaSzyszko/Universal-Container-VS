@IsTest
private class CaseRoutingConfigurationTest {

    @IsTest static void shouldGetCorrectConfigurationGivenExitingQueueDispatcher() {
        String queueDispatcherName = 'Customer_Support_Department';
        Case_Routing__mdt expectedRouting = [
                SELECT Id
                FROM Case_Routing__mdt
                WHERE Queue_Dispatcher__c = :queueDispatcherName
        ];

        Case_Routing__mdt routing = CaseRoutingConfiguration.getInstance().getRoutingData(queueDispatcherName);
        System.assertEquals(expectedRouting.Id, routing.Id);
    }

    @IsTest static void shouldReturnNullGivenNotExitingQueueDispatcher() {
        Case_Routing__mdt routing = CaseRoutingConfiguration.getInstance().getRoutingData('Not exiting queue dispatcher');
        System.assertEquals(null, routing);
    }
}