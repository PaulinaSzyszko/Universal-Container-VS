public with sharing class FindRoutes {

    @AuraEnabled
    public static List<RouteSearch> getRoutes(Date startDate, Date endDate, String departure, String arrival) {

        String query = new SoqlBuilder()
                .addField('Id')
                .addField('Name')
                .addField('Start_Date__c')
                .addField('End_Date__c')
                .addField('Route__r.Arrival_Port__c')
                .addField('Route__r.Departure_Port__c')
                .addField('Route__r.Name')
                .addField('Vessel__r.Name')
                .addField('Status__c')
                .fromx('Schedule__c')
                .addWhere('Route__r.Arrival_Port__c', arrival, '=')
                .addWhere('Route__r.Departure_Port__c', departure, '=')
                .addWhere('Start_Date__c', startDate, '>=')
                .addWhere('End_Date__c', endDate, '<=')
                .addWhere('Status__c', 'Before departure', '=')
                .build();

        System.debug(query);

        List<Schedule__c> schedules = Database.query(query);
        List<RouteSearch> routes = new List<RouteSearch>();

        for (Schedule__c schedule : schedules) {
            RouteSearch route = new RouteSearch();
            route.id = schedule.Id;
            route.name = schedule.Name;
            route.startDate = schedule.Start_Date__c;
            route.endDate = schedule.End_Date__c;
            route.vessel = schedule.Vessel__r.Name;
            route.route = schedule.Route__r.Name;
            routes.add(route);
        }
        return routes;
    }

}