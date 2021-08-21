public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public void execute(QueueableContext context) {
        List<Product2> equipmentRecord = new List<Product2>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            List<Object> payLoad = (List<Object>) JSON.deserializeUntyped(response.getBody());
            for(Object objList : payLoad){
    			Map<String, Object> data = (Map<String,Object>)objList;
                Product2 equipment = new Product2();
                equipment.Replacement_Part__c = true;
                equipment.Cost__c = (Integer)data.get('cost');
                equipment.Current_Inventory__c = (Integer)data.get('quantity');
                equipment.Lifespan_Months__c = (Integer)data.get('lifespan');
                equipment.Maintenance_Cycle__c = (Integer)data.get('maintenanceperiod');
                equipment.Warehouse_SKU__c = (String)data.get('sku');
                equipment.Name = (String)data.get('name');
                equipmentRecord.add(equipment);
            }
            if(!equipmentRecord.isEmpty()) {
                upsert equipmentRecord Warehouse_SKU__c;
            }
        }
    }
}