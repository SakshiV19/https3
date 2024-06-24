@isTest
private class TestExecutionMonitorCtrlTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void getExecutionDetails() {
        System.runAs(getUser()) {
            //SETUP
            Test__c test = getTest();

            //Exercise
            TestExecutionMonitorCtrl.ExecutionDetails details = TestExecutionMonitorCtrl.getExecutionDetails(test.Id);

            //VERIFY
            assertTest(test, details);
        }
    }

    @isTest
    private static void getExecutionDetailsWithEmptyJob() {
        System.runAs(getUser()) {
            //SETUP
            Test__c test = getTest();
            test.LatestJobExecution__c = null;
            update test;

            //Exercise
            TestExecutionMonitorCtrl.ExecutionDetails details = TestExecutionMonitorCtrl.getExecutionDetails(test.Id);

            //VERIFY

            System.assertEquals(true, details == null, 'Execution Details should be null');
        }
    }

    @isTest
    private static void getExecutionDetailsWithNullTest() {
        System.runAs(getUser()) {
            //Exercise
            TestExecutionMonitorCtrl.ExecutionDetails details = TestExecutionMonitorCtrl.getExecutionDetails(null);

            //VERIFY
            System.assertEquals(true, details == null, 'Execution Details should be null');
        }
    }

    private static void assertTest(Test__c test, TestExecutionMonitorCtrl.ExecutionDetails executionDetails) {
        System.assertEquals(true, executionDetails != null, 'Execution Details can not be null');
        System.assertEquals(
            test.LatestJobExecution__c,
            executionDetails.id,
            'Expected ' +
            test.LatestJobExecution__c +
            ' but found ' +
            executionDetails.id
        );
        System.assertEquals(
            test.LatestJobExecution__r.Name,
            executionDetails.name,
            'Expected ' +
            test.LatestJobExecution__r.Name +
            ' but found ' +
            executionDetails.name
        );
        System.assertEquals(
            test.LatestJobExecution__r.Status__c,
            executionDetails.status,
            'Expected ' +
            test.LatestJobExecution__r.Status__c +
            ' but found ' +
            executionDetails.status
        );
    }

    @TestSetup
    private static void setupData() {
        insertData();
    }

    private static void insertData() {
        System.runAs(createTestUserWithPermissionSets()) {
            ExtensionConfiguration__c extensionConfig = createExtensionConfigurations();
            Test__c test = createTest(extensionConfig.Id);

            JobExecution__c jobExecution = createJob();

            test.LatestJobExecution__c = jobExecution.Id;
            update test;
        }
    }

    private static User createTestUserWithPermissionSets() {
        User result = TestDataFactory.createUsers()[0];

        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name IN ('Copado_User', 'Copado_Functions', 'Copado_Job_Engine')];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet permissionSet : permissionSets) {
            assignments.add(new PermissionSetAssignment(AssigneeId = result.Id, PermissionSetId = permissionSet.Id));
        }
        insert assignments;

        return result;
    }

    private static ExtensionConfiguration__c createExtensionConfigurations() {
        ExtensionConfiguration__c extensionConfig = new ExtensionConfiguration__c(
            Name = 'Test',
            ExtensionApplication__c = 'Test',
            ExtensionTool__c = 'Manual Tests',
            Active__c = true
        );
        insert extensionConfig;
        return extensionConfig;
    }

    private static Test__c createTest(Id extensionConfigId) {
        Test__c test = new Test__c(Name = 'Mock Test', ExtensionConfiguration__c = extensionConfigId);

        insert test;
        return test;
    }

    private static JobExecution__c createJob() {
        JobTemplate__c template = new JobTemplate__c();
        template.Name = 'Sample';
        template.Version__c = 1;
        insert template;

        JobStep__c step = new JobStep__c(Name = 'step3', JobTemplate__c = template.Id, Type__c = 'Manual', Order__c = 1);
        insert step;

        JobExecution__c execution = new JobExecution__c();
        execution.Template__c = template.Id;
        insert execution;
        return execution;
    }

    private static Test__c getTest() {
        return [SELECT Id, LatestJobExecution__c, LatestJobExecution__r.Name, LatestJobExecution__r.Status__C FROM Test__c LIMIT 1];
    }

    private static User getUser() {
        return [SELECT Id, Name, LastName, Email, Username FROM User WHERE Email = 'test1@test1.com' LIMIT 1];
    }
}