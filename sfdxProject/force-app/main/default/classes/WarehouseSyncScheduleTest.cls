@IsTest
public class WarehouseSyncScheduleTest {
    // implement scheduled code here
    public static String CRON_EXP = '0 0 1 * * ?';

    @IsTest
    static void testWarehouseSyncSchedule() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new WarehouseSyncSchedule());
        // Verify the scheduled job has not run yet.
        List<Product2> equipments = [SELECT Id
            FROM Product2 LIMIT 1];
        System.assertEquals(0, equipments.size(), 'Equipment exist before job has run');
        // Stopping the test will run the job synchronously
        Test.stopTest();
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
                            FROM CronTrigger ORDER BY CreatedDate DESC LIMIT 1];

        System.assertEquals(1, jobs.size(), 'Job is not Present in the queue');
    }
}