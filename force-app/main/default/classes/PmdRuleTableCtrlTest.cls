@isTest
private class PmdRuleTableCtrlTest {
    @isTest
    private static void validateGetRulesFrom() {
        System.runAs(getUser()) {
            //Setup
            ExtensionConfiguration__c extensionConfig = [SELECT Id FROM ExtensionConfiguration__c];
            //Exercise
            List<PmdRuleTableCtrl.PmdRule> rules = PmdRuleTableCtrl.getRulesFrom(extensionConfig.Id);
            // Verify
            System.assertEquals(true, rules.size() > 0, 'Pmd rules should be retrived ');
        }
    }

    @TestSetup
    private static void makeData() {
        User u = createUser('Standard User');
        insert u;

        assignPermissionSet(u, new Set<String>{ 'Copado_User', 'Copado_Job_Engine' });

        System.runAs(u) {
            createData();
        }
    }

    private static void createData() {
        ExtensionConfiguration__c extensionConfig = new ExtensionConfiguration__c(
            Name = 'Mock Configuration',
            ExtensionApplication__c = 'Test',
            ExtensionTool__c = 'None'
        );
        insert extensionConfig;

        StaticResource ruleset = [SELECT Id, Body FROM StaticResource WHERE Name = 'TestRuleset' LIMIT 1];
        String body = ruleset.Body.toString();

        ContentVersion content = new ContentVersion(Title = 'ruleset', origin = 'C', PathOnClient = 'ruleset.xml', VersionData = Blob.valueOf(body));
        insert content;

        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1];

        ContentDocumentLink link = new ContentDocumentLink(LinkedEntityId = extensionConfig.Id, ContentDocumentId = contentVersion.ContentDocumentId);
        insert link;
    }

    private static User createUser(String profileName) {
        return new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName]
            .Id,
            FirstName = profileName,
            LastName = 'LastName',
            Email = 'test@copado.com',
            Username = 'testcopadoquality@copado.com' + System.currentTimeMillis(),
            CompanyName = 'Copado',
            Title = 'Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
    }

    private static void assignPermissionSet(User u, Set<String> permSetNames) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN :permSetNames]) {
            assignments.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id));
        }
        insert assignments;
    }

    private static User getUser() {
        return [SELECT Id, Name, LastName, Email, Username FROM User WHERE Email = 'test@copado.com' LIMIT 1];
    }
}