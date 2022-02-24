public class MaintenanceRequestHelper {
    
    private static final String REQUEST_TYPE = 'Routine Maintenance';
    private static final String NEW_STATUS = 'New';
    private static final String REQUEST_SUBJECT = 'routine checkup';
    private static final String REQUEST_ORIGIN = 'Web';
    private static final String CLOSED = 'Closed';
    private static final String REPAIR = 'Repair';
    private static final String ROUTINE_MAINTENANCE = 'Routine Maintenance';
    
    public static void createMaintenanceRequest(Map<Id, Case> oldMaintenanceRequestMap, Map<Id, Case> newMaintenanceRequestMap) {
        List<Equipment_Maintenance_Item__c> equipmentMaintain = new List<Equipment_Maintenance_Item__c>();
        Map<Id, Case> oldIdNewRequest = new Map<Id, Case>();
        List<Case> insertCaseList  = new List<Case>();
        Map<Id, List<Equipment_Maintenance_Item__c>> mapMaintainRequestEquipment = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for(Equipment_Maintenance_Item__c allWorkPart : [SELECT Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c 
                                                        FROM Equipment_Maintenance_Item__c 
                                                        WHERE Maintenance_Request__c =: oldMaintenanceRequestMap.keySet()]) {
            if(mapMaintainRequestEquipment.containsKey(allWorkPart.Maintenance_Request__c)) {
                mapMaintainRequestEquipment.get(allWorkPart.Maintenance_Request__c).add(allWorkPart);
            }
            else {
                mapMaintainRequestEquipment.put(allWorkPart.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>{allWorkPart});
            }
        }
        for (Id oldRequestId : oldMaintenanceRequestMap.keySet()) {
            Case oldRequest = oldMaintenanceRequestMap.get(oldRequestId);
            Case newRequest = newMaintenanceRequestMap.get(oldRequestId);
            if ( (oldRequest.Status != CLOSED) && 
                 (newRequest.Status == CLOSED) &&
                 ( (oldRequest.Type == REPAIR) || (oldRequest.Type == ROUTINE_MAINTENANCE) ) ) {

                Case newMaintenanceRequest = createNewRequest(oldRequest, calculateMaintenanceCycle(oldRequestId, mapMaintainRequestEquipment));
                oldIdNewRequest.put(oldRequestId, newMaintenanceRequest);
                insertCaseList.add(newMaintenanceRequest);
            }
        }

        insert insertCaseList;
        
        for(Id caseId :  mapMaintainRequestEquipment.keySet()) {
            if(oldIdNewRequest.containsKey(caseId)){
                for(Equipment_Maintenance_Item__c workPart : mapMaintainRequestEquipment.get(caseId)) {
                    Equipment_Maintenance_Item__c em = new Equipment_Maintenance_Item__c();
                    em.Maintenance_Request__c = oldIdNewRequest.get(workPart.Maintenance_Request__c).Id;
                    em.Equipment__c = workPart.Equipment__c;
                    equipmentMaintain.add(em);
                }
            }
        }
        insert equipmentMaintain;  
    }

    private static Date calculateMaintenanceCycle(Id oldRequestId, Map<Id, List<Equipment_Maintenance_Item__c>> mapMaintainRequestEquipment) {
        List<Decimal> maintenanceCycleDays = new List<Decimal>();
        Integer shortestMaintenanceCycleDay = 0;
        if (mapMaintainRequestEquipment.containsKey(oldRequestId)) {
            for (Equipment_Maintenance_Item__c wp : mapMaintainRequestEquipment.get(oldRequestId)) {
                maintenanceCycleDays.add(wp.Equipment__r.Maintenance_Cycle__c);
            }
            maintenanceCycleDays.sort();
            shortestMaintenanceCycleDay = maintenanceCycleDays[0].intValue();
        }
        Date maintenanceCycleDate = Date.today().addDays(shortestMaintenanceCycleDay);
        return maintenanceCycleDate;
    } 

    private static Case createNewRequest(Case oldRequest, Date maintenanceCycleDate) {
        Id vehicle = oldRequest.Vehicle__c; 
        Id equipment = oldRequest.Equipment__c;
        String requestOrigin = oldRequest.Origin;
        String requestSubject = String.isBlank(oldRequest.Subject) ? REQUEST_SUBJECT : oldRequest.Subject;
        Date reportDate = Date.today();
        Case newRequest = new Case(Type = REQUEST_TYPE, 
                                   Subject = requestSubject,  
                                   Origin = requestOrigin,
                                   Status = NEW_STATUS,
                                   Equipment__c = equipment,
                                   Date_Reported__c = reportDate,  
                                   Vehicle__c = vehicle,
                                   Date_Due__c = maintenanceCycleDate);
        return newRequest;
    }
}