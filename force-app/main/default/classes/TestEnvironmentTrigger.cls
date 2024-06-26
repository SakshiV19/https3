@IsTest
private class TestEnvironmentTrigger {
    @TestSetup 
    private static void setupData() {
        TestUtilities.setTestSettingsEE();
    }
    
    
    @IsTest
    private static void insertInValidEnvironment() {
        
        // Setup
		Exception expectedException = null;
        

		// Exercise
        try {
            Environment__c e = new Environment__c();
            e.Name = 'env1';
            e.Org_ID__c = 'InValidOrgId';
            insert e;
        }
        catch(Exception ex) {
            expectedException = ex;
        }

		
        // Verify
        System.assertNotEquals(null, expectedException);
    }
    
    
    @IsTest
    private static void updateEnvironmentWithExistingOrg() {
        
        // Setup
        Environment__c e = new Environment__c();
        e.Name = 'env1';
        e.Org_ID__c = '000000000000000000';
        insert e;
        
        Org__c o = new Org__c();
        o.Name = 'env1-org1';
        o.Environment__c = e.Id;
        o.Validated_Date__c = System.now();
        o.SFDC_Org_Id__c = '000000000000000000_100000000000000001';
        insert o;
        

		// Exercise
        e.Org_ID__c = '000000000000000001';
        update e;
        
		
        // Verify
        Org__c result = [SELECT Validated_Date__c, Oauth_Signature__c, SFDC_Org_Id__c FROM Org__c WHERE Id = :o.Id];

        System.assertEquals(null, result.Validated_Date__c);
        System.assertEquals(null, result.Oauth_Signature__c);
        System.assertEquals('000000000000000001_100000000000000001', result.SFDC_Org_Id__c);
    }
    
    /*
    static testMethod void test_environmentCreation(){
        List<Environment__c> envs = new List<Environment__c>();

        Environment__c e;

        e = new Environment__c();
        e.Name = 'env1';
        e.Org_ID__c = '000000000000000000';
        envs.add(e);

        e = new Environment__c();
        e.Name = 'env1';
        e.Org_ID__c = '000000000000000001';
        envs.add(e);

        insert envs;

        List<Org__c> orgs = new List<Org__c>();

        Org__c o;

        o = new Org__c();
        o.Name = 'env1-org1';
        o.Environment__c = envs.get(0).Id;
        o.Validated_Date__c = System.now();
        o.SFDC_Org_Id__c = '000000000000000000_100000000000000001';
        orgs.add(o);

        o = new Org__c();
        o.Name = 'env1-org2';
        o.Environment__c = envs.get(0).Id;
        o.Validated_Date__c = System.now();
        o.SFDC_Org_Id__c = '000000000000000000_100000000000000002';
        orgs.add(o);

        o = new Org__c();
        o.Name = 'env2-org1';
        o.Environment__c = envs.get(1).Id;
        o.Validated_Date__c = System.now();
        o.SFDC_Org_Id__c = '000000000000000001_100000000000000001';
        orgs.add(o);

        insert orgs;

        envs.get(0).Org_ID__c = '000000000000000010';
        update envs.get(0);

        List<Id> envIds = new List<Id>();
        envIds.add(envs.get(0).Id);
        envIds.add(envs.get(1).Id);
        orgs = [select Id, SFDC_Org_Id__c, Validated_Date__c, oauth_signature__c FROM Org__c WHERE Environment__c IN :envIds ORDER BY Name];
        system.assertEquals(orgs.get(0).SFDC_Org_Id__c, '000000000000000010_100000000000000001');
        system.assertEquals(orgs.get(1).SFDC_Org_Id__c, '000000000000000010_100000000000000002');
        system.assertEquals(orgs.get(2).SFDC_Org_Id__c, '000000000000000001_100000000000000001');
        system.assertEquals(orgs.get(0).Validated_Date__c, null);
        system.assertEquals(orgs.get(1).Validated_Date__c, null);
        system.assertNotEquals(orgs.get(2).Validated_Date__c, null);
        system.assertEquals(orgs.get(0).oauth_signature__c, null);
        system.assertEquals(orgs.get(1).oauth_signature__c, null);

    }
*/
}