public with sharing class DailyDepartureReminderScheduler implements Schedulable {
    
    /**
     * Requirement 10.4: Scheduled Automations Execution Interface
     * Purpose: Runs automated flight tracking processes daily at 7 AM.
     */
    public void execute(SchedulableContext sc) {
        System.debug('Daily departure scheduler engine triggered background operations.');
        
        // Enqueue background processing tasks directly out of the daily schedule loop [10.4]
        DuffelCacheRefreshJob primaryMaintenanceTask = new DuffelCacheRefreshJob();
        System.enqueueJob(primaryMaintenanceTask);
    }
}