@isTest
public class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @TestSetup
    static void createData(){
        Vehicle__c vehicle = new Vehicle__c(Name = 'Toy Hauler RV', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Toy Hauler RV');
        insert vehicle;
        List<Product2> equipments = new List<Product2>();
        equipments.add(new Product2(Warehouse_SKU__c = '55d66226726b611100aaf741',name = 'Generator 1000 kW', Replacement_Part__c = true,Cost__c = 100 ,Maintenance_Cycle__c = 100));
        equipments.add(new Product2(name = 'Fuse 20B',Replacement_Part__c = true,Cost__c = 1000, Maintenance_Cycle__c = 30 ));
        insert equipments;
        Case maintenanceRequest = new Case(Subject = 'Need Assistance', Vehicle__c = vehicle.Id, Type = 'Routine Maintenance', Date_Reported__c = Date.today(), Equipment__c = equipments.get(0).Id);
        insert maintenanceRequest;
        List<Equipment_Maintenance_Item__c> joinRecords = new List<Equipment_Maintenance_Item__c>();
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(0).Id, Maintenance_Request__c = maintenanceRequest.Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(1).Id, Maintenance_Request__c = maintenanceRequest.Id));
        insert joinRecords;
    }

    @isTest
    public static void testCreateMaintenance() {
        Case maintenanceRequest = [SELECT Id, Vehicle__c, Equipment__c, Date_Due__c, 
                                    Subject, Type, Status FROM Case WHERE Subject = 'Need Assistance'];
    
                                   
        maintenanceRequest.Status = 'Closed';
        update maintenanceRequest;

        List<Case> maintenanceRequests = [SELECT Id, Vehicle__c, Equipment__c, Date_Due__c, 
        Subject, Type, Status FROM Case WHERE Subject = 'Need Assistance' ORDER BY CreatedDate ASC];

        System.assertEquals(maintenanceRequests[0].Vehicle__c, maintenanceRequests[1].Vehicle__c , 'Vehicle Should be Same');
        System.assertEquals(maintenanceRequests[0].Equipment__c, maintenanceRequests[1].Equipment__c , 'Equipment Should be Same');
        System.assertEquals(Date.today()+30, maintenanceRequests[1].Date_Due__c , 'Due Date');
        System.assertEquals(maintenanceRequests[0].Type, maintenanceRequests[1].Type , 'Type Should be Same');
        //System.assertEquals(maintenanceRequests[0].Type, maintenanceRequests[1].Type , 'Type Should be Same');
    }
}