@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here

    @IsTest
    static void testWarehouseCalloutService() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService service = new WarehouseCalloutService();
        Test.startTest();
        System.enqueueJob(service);
        Test.stopTest();
        
        Product2 equipment = [SELECT Id, Maintenance_Cycle__c, Lifespan_Months__c, Warehouse_SKU__c FROM
                                Product2 WHERE Warehouse_SKU__c = '100003'];
        System.assertEquals(365,equipment.Maintenance_Cycle__c,'Maintenance Cycle Should be 365');
    }
}