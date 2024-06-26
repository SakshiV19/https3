@IsTest
private with sharing class CloneAutomationTemplateTest {
    @TestSetup
    private static void setupData() {
        List<User> users = TestDataFactory.createUsers();
        TestUtilities.enableLicenses(2, 2, 2, 2, 2);
        FeatureManagement.setPackageIntegerValue('CBM_Branches', 2);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Copado_User'];
        insert new PermissionSetAssignment(AssigneeId = users[0].Id, PermissionSetId = ps.Id);
    }

    @IsTest
    private static void cloneAutomationTemplate() {
        User sysUser = [SELECT Id, Name, LastName, Email, Username FROM User WHERE Email = 'test1@test1.com' LIMIT 1];
        TestUtilities.assignLicense(String.valueOf(sysUser.Username), true, true, true, true, true);

        System.runAs(sysUser) {
            List<Environment__c> environments = TestDataFactory.createEnvironments(3);

            List<Org__c> orgs = TestDataFactory.createOrgCredentials(3, sysUser.Username, environments);
            String automationDeploymentRecordTypeId = Schema.Sobjecttype.Deployment__c.getRecordTypeInfosByDeveloperName()
                .get('Automation_Template')
                .getRecordTypeId();
            Deployment__c automationTemplate = TestDataFactory.createDeployment('Test Dev 1', automationDeploymentRecordTypeId, orgs[2].Id);

            String advancedDeploymentRecordTypeId = Schema.Sobjecttype.Deployment__c.getRecordTypeInfosByDeveloperName()
                .get('Advanced_multi_step')
                .getRecordTypeId();
            Deployment__c advancedDeployment = TestDataFactory.createDeployment('Test Dev 2', advancedDeploymentRecordTypeId, orgs[2].Id);
            insert new List<Deployment__c>{ automationTemplate, advancedDeployment };

            Destination_Org__c destinationOrg = TestDataFactory.createDestinationOrg(advancedDeployment.Id, orgs[1].Id);
            insert destinationOrg;

            Step__c automationTemplateStep = TestDataFactory.createStep(automationTemplate.Id, 'Step 1', 'Apex', 'Not Started', 1, null, '');
            Step__c advancedDeploymentStep = TestDataFactory.createStep(advancedDeployment.Id, 'Step 1', 'Automation', 'Not Started', 1, null, '');
            advancedDeploymentStep.dataJson__c = '{"automationId":"' + automationTemplate.Id + '"}';
            insert new List<Step__c>{ automationTemplateStep, advancedDeploymentStep };

            String automationStepAttachmentBody = 'System.debug("test automation ");';
            Attachment automationStepAttachment = TestDataFactory.createAttachment('Apex', automationTemplateStep.Id, automationStepAttachmentBody);

            String advancedStepAttachmentBody = '"{\"automationId\":\"' + automationTemplate.Id + '\"}"';
            Attachment advancedStepAttachment = TestDataFactory.createAttachment('Apex', advancedDeploymentStep.Id, advancedStepAttachmentBody);
            insert new List<Attachment>{ automationStepAttachment, advancedStepAttachment };

            Test.startTest();
            List<CloneAutomationTemplate.InvocableVariables> variables = new List<CloneAutomationTemplate.InvocableVariables>();
            CloneAutomationTemplate.InvocableVariables firstSet = new CloneAutomationTemplate.InvocableVariables();
            firstSet.automationTemplateId = automationTemplate.Id;
            variables.add(firstSet);
            List<String> expectedAutomationIds = CloneAutomationTemplate.execute(variables);
            System.assertNotEquals(expectedAutomationIds[0], automationTemplate.Id, 'Cloned automation id is different');
            List<Deployment__c> deployments = [SELECT Id FROM Deployment__c WHERE RecordTypeId = :automationDeploymentRecordTypeId ];
            System.assertEquals(2, deployments.size(), 'There are 2 automation deployments, one is main other is cloned one');
            Test.stopTest();
        }
    }
}