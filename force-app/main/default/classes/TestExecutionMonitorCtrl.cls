public with sharing class TestExecutionMonitorCtrl {
    //PUBLIC
    @AuraEnabled
    public static ExecutionDetails getExecutionDetails(Id testId) {
        ExecutionDetails result;

        if (String.isNotBlank(testId)) {
            List<Test__c> tests = new TestsSelector().byIds(new Set<Id>{ testId });
            result = initExecutionDetails(tests[0]);
        }

        return result;
    }
    //PRIVATE

    private static ExecutionDetails initExecutionDetails(Test__c test) {
        ExecutionDetails result;

        if (String.isNotBlank(test.LatestJobExecution__c)) {
            result = new ExecutionDetails(test.LatestJobExecution__c, test.LatestJobExecution__r.Status__c, test.LatestJobExecution__r.Name);
        }

        return result;
    }

    //INNER
    @TestVisible
    private class ExecutionDetails {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String name;
        public ExecutionDetails(Id id, String status, String name) {
            this.id = id;
            this.status = status;
            this.name = name;
        }
    }
}