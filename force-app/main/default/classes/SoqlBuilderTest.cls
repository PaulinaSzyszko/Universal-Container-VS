/**
 * Created by SZYSZPA on 10-Feb-22.
 */
@IsTest
public with sharing class SoqlBuilderTest {

    @isTest public static void testBuildQuery() {

        String query = new SoqlBuilder()
                .addField('Id')
                .addField('Name')
                .addField('Start_Date__c')
                .addField('End_Date__c')
                .addField('Route__r.Arrival_Port__c')
                .addField('Route__r.Departure_Port__c')
                .addField('Route__r.Name')
                .addField('Vessel__r.Name')
                .fromx('Schedule__c')
                .addWhere('Route__r.Arrival_Port__c', 'Hamburg', '=')
                .addWhere('Route__r.Departure_Port__c', 'Gdynia', '=')
                .addWhere('Start_Date__c', Date.valueOf('2022-01-15'), '>=')
                .addWhere('End_Date__c', Date.valueOf('2022-02-28'), '<=')
                .build();

        System.assertEquals('SELECT ' +
                'Id, ' +
                'Name, ' +
                'Start_Date__c, ' +
                'End_Date__c, ' +
                'Route__r.Arrival_Port__c, ' +
                'Route__r.Departure_Port__c, ' +
                'Route__r.Name,' +
                ' Vessel__r.Name ' +
                'FROM Schedule__c ' +
                'WHERE Route__r.Arrival_Port__c = \'Hamburg\' ' +
                'AND Route__r.Departure_Port__c = \'Gdynia\' ' +
                'AND Start_Date__c >= 2022-01-15 ' +
                'AND End_Date__c <= 2022-02-28',
                query);
    }
}