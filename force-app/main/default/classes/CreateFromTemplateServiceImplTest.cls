@IsTest
// TO BE DELETED
private class CreateFromTemplateServiceImplTest {
    @TestSetup
    private static void setupData() {
        TestUtilities.getAllMultilicense();
        User user = (User) new User_t()
            .assign(new PermissionSetAssignment_t().copadoUser())
            .assign(new PermissionSetAssignment_t().jobEngine())
            .persist();
        System.runAs(user) {
            new CopadoLicense().user(user).enableAll().persist();
            createData();
        }
    }

    @IsTest
    private static void executeWithoutRequiredParams() {
        System.runAs(getUser()) {
            // Setup
            Exception expectedException;

            Git_Commit__c gitCommit = new Git_Commit__c();
            insert gitCommit;

            Jobs.ExecutionCreateFromTemplateRequest request = new Jobs.ExecutionCreateFromTemplateRequest();
            request.parentId = gitCommit.Id;

            // Exercise
            Test.startTest();
            try {
                Jobs.Execution.createFromTemplate(request);
            } catch (Exception ex) {
                expectedException = ex;
            }
            Test.stopTest();

            // Verify
            System.assertNotEquals(null, expectedException, 'An exception should be thrown.');
            System.assertEquals('Missing required parameters : Template Name', expectedException.getMessage(), 'Exception messages match.');
        }
    }

    @IsTest
    private static void executeWithInvalidTemplateName() {
        // Setup
        Exception expectedException;

        Git_Commit__c gitCommit = new Git_Commit__c();
        insert gitCommit;

        Jobs.ExecutionCreateFromTemplateRequest request = new Jobs.ExecutionCreateFromTemplateRequest();
        request.parentId = gitCommit.Id;
        request.templateAPIName = 'Invalid Template';

        // Exercise
        try {
            Jobs.Execution.createFromTemplate(request);
        } catch (Exception ex) {
            expectedException = ex;
        }

        // Verify
        List<String> invalidTemplates = new List<String>{ request.templateAPIName };
        String expectedMessage = String.format(Label.InvalidTemplateId, new List<String>{ invalidTemplates.toString() });
        System.assertNotEquals(null, expectedException, 'An exception should be thrown');
        System.assertEquals(expectedMessage, expectedException.getMessage(), 'Exception message matches');
    }

    @IsTest
    private static void execute() {
        System.runAs(getUser()) {
            // Setup
            Git_Commit__c gitCommit = new Git_Commit__c();
            insert gitCommit;

            Jobs.ExecutionCreateFromTemplateRequest request = new Jobs.ExecutionCreateFromTemplateRequest();
            request.parentId = gitCommit.Id;
            request.templateAPIName = jobTemplateApiName().ApiName__c;
            request.steps = steps(2);

            // Exercise
            Test.startTest();
            Jobs.ExecutionCreateFromTemplateResult result = Jobs.Execution.createFromTemplate(request);
            Test.stopTest();

            // Verify
            List<JobStep__c> jobSteps = [SELECT Name, Order__c FROM JobStep__c WHERE JobExecution__c = :result.jobExecution.id];
            System.assertEquals(6, jobSteps.size(), 'Total step count should be 6');
            System.assertEquals(gitCommit.Id, result.jobExecution.ParentRecord_Id__c, 'Parent Id matches.');
            System.assertEquals(jobTemplateApiName().Id, result.jobExecution.Template__c, 'Template Id matches');
            System.assertEquals('Not Started', result.jobExecution.Status__c, 'Job Execution status is Not Started.');
        }
    }

    @IsTest
    private static void executeWithJobTemplateSteps() {
        System.runAs(getUser()) {
            // Setup
            String skipStepCondition = '{$User.Name.matches("' + UserInfo.getFirstName() + '*' + '")}';

            Git_Commit__c gitCommit = new Git_Commit__c();
            insert gitCommit;

            Jobs.ExecutionCreateFromTemplateRequest request = new Jobs.ExecutionCreateFromTemplateRequest();
            request.parentId = gitCommit.Id;
            request.templateAPIName = jobTemplateApiName().ApiName__c;

            // Exercise
            Test.startTest();
            Jobs.ExecutionCreateFromTemplateResult result = Jobs.Execution.createFromTemplate(request);
            Test.stopTest();

            // Verify
            List<JobStep__c> jobSteps = [SELECT Name, Order__c, SkipCondition__c FROM JobStep__c WHERE JobExecution__c = :result.jobExecution.id];
            System.assertEquals(2, jobSteps.size(), 'Total step count should be 2');
            System.assertEquals('S2', jobSteps[0].Name, 'Step 1 name should be S2');
            System.assertEquals(1, jobSteps[0].Order__c, 'The order of S2 should be 1');
            System.assertEquals('S1', jobSteps[0].Name, 'Step 2 name should be S1');
            System.assertEquals(2, jobSteps[0].Order__c, 'The order of S1 should be 2');
            System.assertEquals(skipStepCondition, jobSteps[0].SkipCondition__c, 'Step 2 skip condition matches');
            System.assertEquals(gitCommit.Id, result.jobExecution.ParentRecord_Id__c, 'Parent Id matches.');
            System.assertEquals(jobTemplateApiName().Id, result.jobExecution.Template__c, 'Template Id matches');
            System.assertEquals('Not Started', result.jobExecution.Status__c, 'Job Execution status is Not Started.');
        }
    }

    // HELPER

    private static User getUser() {
        return [SELECT Id, Email FROM User WHERE Profile.Name = 'Standard User' ORDER BY CreatedDate DESC LIMIT 1];
    }

    private static void createData() {
        String firstNamePattern = UserInfo.getFirstName() + '*';

        new JobTemplate()
            .name('JT')
            .apiName('JT_1')
            .version(1)
            .volumeOptions('[{}]')
            .add(new JobStep().order(1).name('S2').resourceObservations('Local branch ready'))
            .add(new JobStep().order(2).name('S1').skipCondition('{$User.Name.matches("' + firstNamePattern + '")}'));

        SObject userStory = new UserStory().persist();

        new JobStep().order(1).type('Manual').name('Step1').userStory(userStory.Id).executionSequence('before');
        new JobStep().order(2).type('Manual').name('Step2').userStory(userStory.Id).executionSequence('before').persist();
    }

    private static User_Story__c getUserStory() {
        return [SELECT Id, Environment__c, Project__c FROM User_Story__c LIMIT 1];
    }

    private static List<JobStep__c> getJobSteps() {
        return new JobStepsSelector().byParent(getUserStory().Id);
    }

    private static JobTemplate__c jobTemplateApiName() {
        return [SELECT Id, ApiName__c FROM JobTemplate__c LIMIT 1];
    }

    private static List<Jobs.ExecutionStep> steps(Integer count) {
        List<Jobs.ExecutionStep> result = new List<Jobs.ExecutionStep>();

        for (Integer i = 0; i < count; i++) {
            Jobs.ExecutionStep execStep = new Jobs.ExecutionStep();
            execStep.resourceObservation = 'Local branch ready';
            execStep.sequence = 'before';
            execStep.steps = getJobSteps();
            result.add(execStep);
        }
        return result;
    }
}