@isTest
private class MonitorCtrlTest {
    @TestSetup
    private static void setupData() {
        TestUtilities.getAllMultilicense();
        User user = (User) new User_t()
            .assign(new PermissionSetAssignment_t().copadoUser())
            .assign(new PermissionSetAssignment_t().functions())
            .assign(new PermissionSetAssignment_t().jobEngine())
            .assign(new PermissionSetAssignment_t().qualityGatesReadOnly())
            .persist();
        System.runAs(user) {
            new CopadoLicense().user(user).enableAll().persist();
            data();
        }
    }

    @IsTest
    private static void execute() {
        // Setup
        System.runAs(getRunAsUser()) {
            List<Environment__c> environments = [SELECT Id, Name, Type__c, Platform__c FROM Environment__c];
            Project__c project = [SELECT Id FROM Project__c LIMIT 1];
            JobTemplate__c promotionJobTemplate = [SELECT Id, Name FROM JobTemplate__c WHERE Name = :'JOB_TEMPLATE_PROMOTION' LIMIT 1];

            new Promotion().projectId(project.Id).sourceEnvId(environments[0].Id).status('Draft').persist();
            Promotion__c promotion = [SELECT Id FROM Promotion__c LIMIT 1];
            
            User_Story__c userStory = [SELECT Id FROM User_Story__c LIMIT 1];
            PromotedUserStoriesDatatableController.addSelectedUserStoriesToPromotion(promotion.Id, new List<Id>{ userStory.Id });

            // Exercise
            Test.startTest();
            RunPromoteJobTemplateHandler.execute(promotion.Id);
            Test.getEventBus().deliver();

            JobExecution__c jobExecution = new JobExecutionsSelector().byPromotionId(promotion.Id);
            String fieldName = (String) SObjectType.Promotion__c.fields.Last_Promotion_Execution_Id__c.getLocalName();

            MonitorCtrl.JobDetails actualResult = MonitorCtrl.fetchJobDetails(promotion.Id, fieldName);
            Test.stopTest();

            // Verify
            System.assertEquals(jobExecution.Status__c, actualResult.status, 'Same as job execution status');
            System.assertEquals(promotionJobTemplate.Id, actualResult.template, 'Same as promotion template');
            System.assertEquals(promotionJobTemplate.Name, actualResult.title, 'Same as promotion template name');
            System.assertEquals(jobExecution.Id, actualResult.id, 'Same as job execution id');
            System.assertEquals(2, actualResult.stepDetails.size(), 'Job execution has steps');
        }
    }

    private static User getRunAsUser() {
        return [SELECT Id, Email FROM User WHERE Profile.Name = 'Standard User' ORDER BY CreatedDate DESC LIMIT 1];
    }

    private static void data() {
        Personal_Settings__c ps = Personal_Settings__c.getInstance();
        if (String.isBlank(ps.API_Key__c)) {
            ps.API_Key__c = DeployAPI.encryptAPIKey('99999999999999999999');
            upsert ps;
        }

        //Environment creation
        new Environment().name('dev1').type('Production/Developer').platform('Other');
        new Environment().name('uat').type('Production/Developer').platform('Other').persist();
        List<Environment__c> environments = [SELECT Id, Name, Type__c, Platform__c FROM Environment__c ORDER BY CreatedDate];
        
        //Org Credential validation
        List<Org__c> credentials = [
            SELECT Id, Name, Username__c, Oauth_Signature__c, Validated_Date__c, Disable_Validation__c, SFDC_Org_ID__c
            FROM Org__c
            WHERE Platform__c = 'Other'
        ];
        for (Org__c org : credentials) {
            org.Username__c = UserInfo.getUserName();
            org.SFDC_Org_ID__c = UserInfo.getOrganizationId() + '_' + UserInfo.getUserId();
            org.Oauth_Signature__c = org.Name;
            org.Validated_Date__c = System.now();
            org.Disable_Validation__c = true;
            break;
        }
        update credentials;

        // Function creation
        String namespace = namespacePrefix();
        new Function()
            .name('mulePromotion')
            .apiName('mulePromotion')
            .script('echo hello world $par1')
            .type('Custom')
            .paramaters(
                '[{"name": "SourceDBName", "defaultValue": "{!$Source.Property.DBName}", "required": true},' +
                '{"name": "DestinationDBProvider", "defaultValue": "{!$Destination.Property.DB-Provider}", "required": true},' +
                '{"name": "PipelineUsername", "defaultValue": "{!$Pipeline.Property.Username}", "required": true},' +
                '{"name": "UserEmail", "defaultValue": "{!$User.Property.Email}", "required": true},' +
                '{"name": "LogLevel", "defaultValue": "ERROR", "required": false}]'
            )
            .options(
                '[{"name": "gitUrl", "value": "xxxxxx", "sensitive": true},' +
                '{"name": "gitUsername", "value": "", "sensitive": true},' +
                '{"name": "gitPassword", "value": "", "sensitive": true},' +
                '{"name": "branchName", "value": "", "sensitive": false}]'
            )
            .callbackType('ApexClass')
            .apexClass(namespace + 'FunctionStepExecutionCallback')
            .persist();

        new JobTemplate()
            .name('JOB_TEMPLATE_PROMOTION')
            .mockAutomation('Promotion')
            .volumeOptions('[{ "name": "volumeEnabled", "value": "false" }]')
            .add(new JobStep().order(1).type('Function').configJson('{"functionName":"mulePromotion","parameters":[]}'))
            .add(new JobStep().order(2).type('Manual').configJson('{"functionName":"mulePromotion","parameters":[]}'))
            .persist();
        
        // Deployment flow creation
        new Pipeline()
            .active(true)
            .mainBranch('master')
            .setPlatform('Other')
            .add(new Connection().sourceId(environments[0].Id).destinationId(environments[1].Id).branch('uat'))
            .add(new Project().add(new UserStory().status('Approved').credentialId(credentials[0].Id).readyToPromote(true)))
            .persist();
    }

    private static String namespacePrefix() {
        return Settings.ns.replace('__', '.');
    }
}