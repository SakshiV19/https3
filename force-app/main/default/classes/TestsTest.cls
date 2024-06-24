@isTest
private with sharing class TestsTest {
    private static final String MOCK_TEST = 'Mock Test';
    private static final String MOCK_ACCEPTANCE_CRITERIA = '{"minimumCoverage": 80}';
    private static final String MOCK_ACCEPTANCE_CRITERIA2 = '{"minimumCoverage": 90}';

    @isTest
    private static void acceptanceCriteriaOnInsert() {
        System.runAs(getTestUser()) {
            // Setup
            ExtensionConfiguration__c extensionConfiguration = createExtensionConfiguration();
            Test__c test = createTest(extensionConfiguration.Id);

            // Exercise
            insert test;

            // Verify
            Test__c latestTest = getTest(test.Id);
            System.assertEquals(
                MOCK_ACCEPTANCE_CRITERIA,
                latestTest.AcceptanceCriteria__c,
                'Acceptance critera should be inherit from Extension Configuration'
            );
        }
    }

    @isTest
    private static void acceptanceCriteriaOnExtensionConfigUpdate() {
        System.runAs(getTestUser()) {
            // Setup
            Exception expectedException = null;
            Test__c test = createTest(createExtensionConfiguration().Id);
            insert test;

            test = getTest(test.Id);
            System.assertEquals(
                MOCK_ACCEPTANCE_CRITERIA,
                test.AcceptanceCriteria__c,
                'Acceptance critera should be inherit from Extension Configuration'
            );

            ExtensionConfiguration__c extensionConfiguration2 = createExtensionConfiguration();
            extensionConfiguration2.AcceptanceCriteria__c = MOCK_ACCEPTANCE_CRITERIA2;
            update extensionConfiguration2;

            // Exercise
            try {
                test.ExtensionConfiguration__c = extensionConfiguration2.Id;
                update test;
            } catch (Exception ex) {
                expectedException = ex;
            }

            // Verify
            System.assertNotEquals(null, expectedException, 'There is an exception here.');
            System.assert(
                expectedException.getMessage()
                    .contains('This Tool Configuration cannot be modified. Please create a new Test and select the Tool Configuration needed.'),
                'Error message.'
            );
        }
    }

    @isTest
    private static void acceptanceCriteriaOnACUpdate() {
        System.runAs(getTestUser()) {
            // Setup
            Test__c test = createTest(createExtensionConfiguration().Id);
            insert test;

            // Exercise
            test.AcceptanceCriteria__c = MOCK_ACCEPTANCE_CRITERIA2;
            update test;

            // Verify
            Test__c latestTest = getTest(test.Id);
            System.assertEquals(MOCK_ACCEPTANCE_CRITERIA2, latestTest.AcceptanceCriteria__c, 'Acceptance critera should be updated');
        }
    }

    @isTest
    private static void testReadinessBeforeInsert() {
        System.runAs(getTestUser()) {
            // Setup
            TestTool__mdt mockTestTool = insertMockTestTool();
            Test__c test = createTest(createExtensionConfiguration().Id);

            // Exercise
            insert test;

            // Verify
            Test__c latestTest = getTest(test.Id);
            System.assertEquals(mockTestTool.Automate_Test_Readiness__c, latestTest.ReadyToRun__c, 'Ready to Run value should match with Test Tool Automate Readiness value');
        }
    }

    @TestSetup
    private static void setupData() {
        TestUtilities.getAllMultilicense();
        User user = (User) new User_t().assign(new PermissionSetAssignment_t().copadoUser()).persist();
        System.runAs(user) {
            new CopadoLicense().user(user).enableAll().persist();
        }
    }

    private static ExtensionConfiguration__c createExtensionConfiguration() {
        ExtensionConfiguration__c result = new ExtensionConfiguration__c(
            ExtensionTool__c = 'Manual Tests',
            ExtensionApplication__c = 'Test',
            Active__c = true,
            AcceptanceCriteria__c = MOCK_ACCEPTANCE_CRITERIA
        );

        insert result;
        return result;
    }

    private static Test__c createTest(Id extensionConfigId) {
        return new Test__c(Name = MOCK_TEST, ExtensionConfiguration__c = extensionConfigId);
    }

    private static Test__c getTest(Id testId) {
        return [SELECT Id, AcceptanceCriteria__c, ReadyToRun__c FROM Test__c WHERE Id = :testId LIMIT 1];
    }

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Profile.Name = 'Standard User' ORDER BY CreatedDate DESC LIMIT 1];
    }

    private static TestTool__mdt insertMockTestTool() {
        TestTool__mdt mockTestTool = new TestTool__mdt(MasterLabel = 'Manual Tests', TestType__c = 'Functional Test', Automate_Test_Readiness__c = false);
        TestToolsSelector.mock(new List<TestTool__mdt>{ mockTestTool });
        return mockTestTool;
    }
}