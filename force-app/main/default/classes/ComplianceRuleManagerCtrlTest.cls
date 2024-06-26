@isTest
private with sharing class ComplianceRuleManagerCtrlTest {
    @TestSetup
    private static void setupData() {
        insertData();
    }

    @isTest
    private static void getComplianceFileFromBackend() {
        System.runAs(getTestUser()) {
            // Setup
            String responseBody = '[{"categoryType":"Profile","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"applicationVisibilities","metadataType":"applicationVisibility","metadataNameField":"application","fields":["application:string","default:boolean","visible:boolean"]},{"name":"classAccesses","metadataType":"classAccess","metadataNameField":"apexClass","fields":["apexClass:string","enabled:boolean"]},{"name":"customPermissions","metadataType":"customPermission","metadataNameField":"name","fields":["enabled:boolean","name:string"]},{"name":"externalDataSourceAccesses","metadataType":"externalDataSourceAccess","metadataNameField":"externalDataSource","fields":["enabled:boolean","externalDataSource:string"]},{"name":"fieldLevelSecurities","metadataType":"fieldLevelSecurity","metadataNameField":"field","fields":["editable:boolean","field:string","hidden:boolean","readable:boolean"]},{"name":"fieldPermissions","metadataType":"fieldPermission","metadataNameField":"field","fields":["editable:boolean","field:string","hidden:boolean","readable:boolean"]},{"name":"layoutAssignments","metadataType":"layoutAssignment","metadataNameField":"layout","fields":["layout:string","recordType:string"]},{"name":"objectPermissions","metadataType":"objectPermission","metadataNameField":"object","fields":["allowCreate:boolean","allowDelete:boolean","allowEdit:boolean","allowRead:boolean","modifyAllRecords:boolean","object:string","viewAllRecords:boolean"]},{"name":"pageAccesses","metadataType":"pageAccess","metadataNameField":"apexPage","fields":["apexPage:string","enabled:boolean"]},{"name":"profileActionOverrides","metadataType":"profileActionOverride","metadataNameField":"actionName","fields":["actionName:string","content:string","formFactor:string","pageOrSobjectType:string","recordType:string","type:string"]},{"name":"recordTypeVisibilities","metadataType":"recordTypeVisibility","metadataNameField":"recordType","fields":["default:boolean","personAccountDefault:boolean","recordType:string","visible:boolean"]},{"name":"tabVisibilities","metadataType":"TabVisibility","metadataNameField":"tab","fields":["tab:string","visibility:string"]},{"name":"userPermissions","metadataType":"userPermission","metadataNameField":"name","fields":["enabled:boolean","name:string"]}]},{"categoryType":"Certificate","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"Certificate","metadataType":"Certificate","metadataNameField":"masterLabel","fields":["caSigned:boolean","encryptedWithPlatformEncryption:boolean","expirationDate:dateTime","keySize:int","privateKeyExportable:boolean"]}]},{"categoryType":"CustomObject","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"value","metadataType":"valueSetDefinition","metadataNameField":"fullName","fields":["fullName:string","color:string","default:boolean","description:string","isActive:boolean","label:string"]},{"name":"fields","metadataType":"customField","metadataNameField":"fullName","fields":["fullName:string","caseSensitive:boolean","customDataType:string","defaultValue:string","deleteConstraint:string","deprecated:boolean","description:string","displayFormat:string","displayLocationInDecimal:boolean","encrypted:boolean","externalDeveloperName:string","externalId:boolean","fieldManageability:string","formula:string","formulaTreatBlankAs:string","fullName:string","globalPicklist:string","indexed:boolean","inlineHelpText:string","isFilteringDisabled:boolean","isNameField:boolean","isSortingDisabled:boolean","reparentableMasterDetail:boolean","label:string","length:int","maskChar:string","maskType:string","metadataRelationship​ControllingField:string","populateExistingRows:boolean","precision:int","referenceTargetField:string","referenceTo:string","relationshipLabel:string","relationshipName:string","relationshipOrder:int","required:boolean","scale:int","startingNumber:int","stripMarkup:boolean","summarizedField:string","summaryForeignKey:string","summaryOperation:string","trackFeedHistory:boolean","trackHistory:boolean","trackTrending:boolean","trueValueIndexed:boolean","type:string","unique:boolean","visibleLines:int","writeRequiresMasterRead:boolean"]}]},{"categoryType":"CspTrustedSite","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"CspTrustedSite","metadataType":"cspTrustedSite","metadataNameField":"","fields":["description:string","endpointUrl:string","isActive:boolean"]}]},{"categoryType":"NamedCredential","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"NamedCredential","metadataType":"NamedCredential","metadataNameField":"","fields":["fullName:string","allowMergeFieldsInBody:boolean","allowMergeFieldsInHeader:boolean","authProvider:string","certificate:string","endpoint:string","generateAuthorizationHeader:boolean","label:string","oauthRefreshToken:string","oauthScope:string","oauthToken:string","password:string","principalType:string","protocol:string","username:string"]}]},{"categoryType":"Network","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"branding","metadataType":"Branding","metadataNameField":"","fields":["loginFooterText:string","loginLogo:string","pageFooter:string","pageHeader:string","primaryColor:string","primaryComplementColor:string","quaternaryColor:string","quaternaryComplementColor:string","secondaryColor:string","tertiaryColor:string","tertiaryComplementColor:string","zeronaryColor:string","zeronaryComplementColor:string"]},{"name":"networkMemberGroups","metadataType":"NetworkMemberGroup","metadataNameField":"","fields":["permissionSet:string","profile:string"]}]},{"categoryType":"PermissionSet","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"applicationVisibilities","metadataType":"applicationVisibility","metadataNameField":"application","fields":["application:string","visible:boolean"]},{"name":"classAccesses","metadataType":"classAccess","metadataNameField":"apexClass","fields":["apexClass:string","enabled:boolean"]},{"name":"customPermissions","metadataType":"customPermission","metadataNameField":"name","fields":["name:string","enabled:boolean"]},{"name":"externalDataSourceAccesses","metadataType":"externalDataSourceAccess","metadataNameField":"externalDataSource","fields":["externalDataSource:string","enabled:boolean"]},{"name":"fieldPermissions","metadataType":"fieldPermission","metadataNameField":"field","fields":["editable:boolean","field:string","readable:boolean"]},{"name":"objectPermissions","metadataType":"objectPermission","metadataNameField":"object","fields":["allowCreate:boolean","allowDelete:boolean","allowEdit:boolean","allowRead:boolean","modifyAllRecords:boolean","object:string","viewAllRecords:boolean"]},{"name":"tabSettings","metadataType":"tabSetting","metadataNameField":"tab","fields":["tab:string","visibility:string"]},{"name":"pageAccesses","metadataType":"pageAccess","metadataNameField":"apexPage","fields":["apexPage:string","enabled:boolean"]},{"name":"recordTypeVisibilities","metadataType":"recordTypeVisibility","metadataNameField":"recordType","fields":["recordType:string","visible:boolean"]},{"name":"userPermissions","metadataType":"userPermission","metadataNameField":"name","fields":["name:string","enabled:boolean"]}]},{"categoryType":"SamlSsoConfig","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"SamlSsoConfig","metadataType":"SamlSsoConfig","metadataNameField":"name","fields":["fullName:string","attributeName:string","attributeNameIdFormat:string","decryptionCertificate:string","errorUrl:string","executionUserId:string","identityLocation:string","identityMapping:string","issuer:string","loginUrl:string","logoutUrl:string","name:string","oauthTokenEndpoint:string","redirectBinding:boolean","requestSignatureMethod:string","salesforceLoginUrl:string","samlEntityId:string","samlJitHandlerId:string","samlVersion:string","userProvisioning:boolean","validationCert:string"]}]},{"categoryType":"Settings","nodes":[{"name":"name","metadataType":"name","metadataNameField":"","fields":["value:string"]},{"name":"dispositions","metadataType":"FileUploadAndDownloadSettings","metadataNameField":"fileType","fields":["behavior:string","filetype:string","securityRiskFileType:boolean"]},{"name":"ipRanges","metadataType":"IpRange","metadataNameField":"","fields":["description:string","start:string","end:string"]},{"name":"passwordPolicies","metadataType":"passswordPolicy","metadataNameField":"","fields":["apiOnlyUserHomePageURL:string","complexity:string","expiration:string","minimumPasswordLifetime:boolean","historyRestriction:string","lockoutInterval:string","maxLoginAttempts:string","minimumPasswordLength:string","obscureSecretAnswer:boolean","passwordAssistanceMessage:string","passwordAssistanceURL:string","questionRestriction:string"]},{"name":"sessionSettings","metadataType":"sessionSettings","metadataNameField":"","fields":["disableTimeoutWarning:boolean","enableCSPOnEmail:boolean","enableCSRFOnGet:boolean","enableCSRFOnPost:boolean","enableCacheAndAutocomplete:boolean","enableClickjackNonsetupSFDC:boolean","enableClickjackNonsetupUser:boolean","enableClickjackNonsetupUserHeaderless:boolean","enableClickjackSetup:boolean","enablePostForSessions:boolean","enableSMSIdentity:boolean","enforceIpRangesEveryRequest:boolean","forceLogoutOnSessionTimeout:boolean","forceRelogin:boolean","hstsOnForcecomSites:boolean","lockSessionsToDomain:boolean","lockSessionsToIp:boolean","logoutURL:boolean","requireHttpOnly:boolean","requireHttps:boolean","sessionTimeout:string"]},{"name":"preferences","metadataType":"OrganizationSettingsDetail","metadataNameField":"","fields":["settingName:string","setttingValue:boolean"]}]}]';
            MockHttpResponseGenerator mockResponse = new MockHttpResponseGenerator(200, 'Complete', responseBody, null);
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // Exercise
            Test.startTest();
            String response = ComplianceRuleManagerCtrl.getComplianceFileFromBackend();
            Test.stopTest();

            // Verify
            System.assertEquals(responseBody, response, 'Expected compliance file is: ' + responseBody + ' and received is: ' + response);
        }
    }

    @isTest
    private static void deleteCriterias() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();
            Compliance_Rule_Criteria__c criteria = new Compliance_Rule_Criteria__c();
            criteria.Compliance_Rule__c = complianceRule.Id;
            insert criteria;

            // Exercise
            ComplianceRuleManagerCtrl.deleteCriterias(new List<Compliance_Rule_Criteria__c>{ criteria });

            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);

            // Verify
            System.assert(currentCriterias.isEmpty(), 'Expected criterias to be empty after a successful deletion');
        }
    }

    @isTest
    private static void saveTwoCriteriasWhenZeroLegacyCriteriaExists() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);

            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2 };

            String criteriaLogic = '1 AND 2';

            // Exercise
            ComplianceRuleManagerCtrl.saveCriterias(criterias, criteriaLogic, 'TestMetadata');

            // Verify
            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);

            Integer expectedCriteriaSize = 2;
            String expectedMetadataType = 'TestMetadata';
            String expectedFilterCriteria = currentCriterias.get(0).Name + ' AND ' + currentCriterias.get(1).Name;

            assertErrors(currentCriterias, expectedCriteriaSize, expectedMetadataType, expectedFilterCriteria);
        }
    }

    @isTest
    private static void saveOneCriteriaWhenZeroLegacyCriteriaExists() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1 };

            String criteriaLogic = '1';

            // Exercise
            ComplianceRuleManagerCtrl.saveCriterias(criterias, criteriaLogic, 'TestMetadata');

            // Verify
            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);

            Integer expectedCriteriaSize = 1;
            String expectedMetadataType = 'TestMetadata';
            String expectedFilterCriteria = currentCriterias.get(0).Name;

            assertErrors(currentCriterias, expectedCriteriaSize, expectedMetadataType, expectedFilterCriteria);
        }
    }

    @isTest
    private static void saveTwoCriteriaWhenTwoLegacyCriteriaExists() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);

            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2 };
            insert criterias;

            String criteriaLogic = '1 AND 2';

            // Exercise
            ComplianceRuleManagerCtrl.saveCriterias(criterias, criteriaLogic, 'TestMetadata');

            // Verify
            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);

            Integer expectedCriteriaSize = 2;
            String expectedMetadataType = 'TestMetadata';
            String expectedFilterCriteria = currentCriterias.get(0).Name + ' AND ' + currentCriterias.get(1).Name;

            assertErrors(currentCriterias, expectedCriteriaSize, expectedMetadataType, expectedFilterCriteria);
        }
    }

    @isTest
    private static void saveTwoCriteriasWhenOneLegacyCriteriaExists() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);
            insert criteria1;

            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2 };

            String criteriaLogic = '1 AND 2';

            // Exercise
            ComplianceRuleManagerCtrl.saveCriterias(criterias, criteriaLogic, 'TestMetadata');

            // Verify
            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);

            Integer expectedCriteriaSize = 2;
            String expectedMetadataType = 'TestMetadata';
            String expectedFilterCriteria = currentCriterias.get(0).Name + ' AND ' + currentCriterias.get(1).Name;

            assertErrors(currentCriterias, expectedCriteriaSize, expectedMetadataType, expectedFilterCriteria);
        }
    }

    @isTest
    private static void saveCriteriasWhenCriteriaLogicIsCustom() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);
            Compliance_Rule_Criteria__c criteria3 = createCriteria(complianceRule.Id, TEST_VALUE + '3', 3);

            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2, criteria3 };
            insert criterias;

            String criteriaLogic = '1 OR (2 AND 3)';

            // Exercise
            ComplianceRuleManagerCtrl.saveCriterias(criterias, criteriaLogic, 'TestMetadata');

            // Verify
            List<Compliance_Rule_Criteria__c> currentCriterias = getCriteriasById(complianceRule.Id);
            System.assertEquals(3, currentCriterias.size(), 'Expected criterias length to be 1');

            String expectedFilterCriteria =
                currentCriterias.get(0).Name +
                ' OR ' +
                '(' +
                currentCriterias.get(1).Name +
                ' AND ' +
                currentCriterias.get(2).Name +
                ')';

            System.assertEquals(
                expectedFilterCriteria,
                currentCriterias.get(0).Compliance_Rule__r.Filter_Criteria__c,
                'Expected filter criteria: ' +
                expectedFilterCriteria +
                ' and received: ' +
                currentCriterias.get(0).Compliance_Rule__r.Filter_Criteria__c
            );
        }
    }

    @isTest
    private static void validateCriterias() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);

            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2 };

            String criteriaLogic = '1 AND 2';

            // Exercise
            Exception ex;
            try {
                ComplianceRuleManagerCtrl.validateCriterias(criterias, criteriaLogic);
            } catch (Exception e) {
                ex = e;
            }

            // Verify
            System.assert(ex == null, 'Validation status should be positive');
        }
    }

    @isTest
    private static void validateCriteriasFailsWhenEmptyField() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, '', 1);
            Compliance_Rule_Criteria__c criteria2 = createCriteria(complianceRule.Id, TEST_VALUE + '2', 2);
            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1, criteria2 };

            String criteriaLogic = '1 AND 2';

            // Exercise
            Exception ex;
            try {
                ComplianceRuleManagerCtrl.validateCriterias(criterias, criteriaLogic);
            } catch (Exception e) {
                ex = e;
            }

            // Verify
            String expectedErrorRow = String.format(Label.CCH_NONVALID_CRITERIA, new List<String>{ '1' });
            System.assertEquals(expectedErrorRow, ex.getMessage(), 'Expected: ' + expectedErrorRow);
        }
    }

    @isTest
    private static void validateCriteriasFailsWhenIncorrectLogic() {
        System.runAs(getTestUser()) {
            // Setup
            Compliance_Rule__c complianceRule = getTestComplianceRule();

            Compliance_Rule_Criteria__c criteria1 = createCriteria(complianceRule.Id, TEST_VALUE, 1);
            List<Compliance_Rule_Criteria__c> criterias = new List<Compliance_Rule_Criteria__c>{ criteria1 };

            String criteriaLogic = '1 AND 2';

            // Exercise
            Exception ex;
            try {
                ComplianceRuleManagerCtrl.validateCriterias(criterias, criteriaLogic);
            } catch (Exception e) {
                ex = e;
            }

            // Verify
            System.assertEquals(
                Label.CCH_NONVALID_CRITERIA_LOGIC_REFERENCES,
                ex.getMessage(),
                'Expected: ' + Label.CCH_NONVALID_CRITERIA_LOGIC_REFERENCES
            );
        }
    }

    @isTest
    private static void validatePermissionsHappyPath() {
        System.runAs(getTestUser()) {
            // Exercise
            String error = ComplianceRuleManagerCtrl.validatePermissions();

            // Verify
            System.assert(String.isBlank(error), 'There should not be any error in the permission validation');
        }
    }

    private static void assertErrors(
        List<Compliance_Rule_Criteria__c> criterias,
        Integer expectedCriteriaSize,
        String expectedMetadataType,
        String expectedFilterCriteria
    ) {
        System.assertEquals(expectedCriteriaSize, criterias.size(), 'Expected criterias length to be ' + expectedCriteriaSize);
        System.assertEquals(
            expectedMetadataType,
            criterias.get(0).Compliance_Rule__r.Metadata_Type__c,
            'Expected metadata type: ' +
            expectedMetadataType +
            ' and received: ' +
            criterias.get(0).Compliance_Rule__r.Metadata_Type__c
        );
        System.assertEquals(
            expectedFilterCriteria,
            criterias.get(0).Compliance_Rule__r.Filter_Criteria__c,
            'Expected filter criteria: ' +
            expectedFilterCriteria +
            ' and received: ' +
            criterias.get(0).Compliance_Rule__r.Filter_Criteria__c
        );
        System.assert(criterias.get(0).Compliance_Rule__r.Is_Valid__c, 'Expected compliance rule to be valid');
        System.assertEquals(
            'Number of groups',
            criterias.get(0).Compliance_Rule__r.Record_Count_Criteria__c,
            'Expected record count criteria to be "Number of groups"'
        );
        System.assertEquals(
            'Greater or Equal',
            criterias.get(0).Compliance_Rule__r.Matching_Criteria__c,
            'Expected matching criteria to be "Greater or Equal"'
        );
        System.assertEquals(1, criterias.get(0).Compliance_Rule__r.Record_Count__c, 'Expected Record Count to be 1');
    }

    private static void insertData() {
        User adminUser = setupUser();
        System.runAs(adminUser) {
            TestUtilities.assignLicense(String.valueOf(adminUser.Username), true, true, true, true, true);

            Personal_Settings__c personalSettings = Personal_Settings__c.getInstance();
            personalSettings.API_Key__c = 'Test API Key';
            upsert personalSettings;

            Compliance_Rule__c complianceRuleTest = getShapedComplianceRule();
            insert complianceRuleTest;
        }
    }

    private static User setupUser() {
        ITestDefaults userCreation = new CopadoSetupTestDefaults.UserDefaults().createRunAsUsers().executeDML();
        User adminUser = userCreation.getRunAsUsers().get('Admin')[0];

        return adminUser;
    }

    private static User getTestUser() {
        User testUser = [SELECT Id, Name, LastName, Email, Username FROM User WHERE Email = 'test@test.org' LIMIT 1].get(0);
        TestUtilities.assignLicense(String.valueOf(testUser.Username), true, true, true, true, true);

        return testUser;
    }

    private static Compliance_Rule_Criteria__c createCriteria(Id ruleId, String value, Decimal order) {
        return TestDataFactory.newCriteria(ruleId, 'testNode', 'testField', 'testOperator', value, order);
    }

    private static Compliance_Rule__c getShapedComplianceRule() {
        String namespace = [SELECT COUNT() FROM ApexClass WHERE Name = 'CopadoSetupController' AND NamespacePrefix = 'copado'] == 1 ? 'copado__' : '';

        return new Compliance_Rule__c(
            Active__c = true,
            Action__c = Schema.getGlobalDescribe()
                    .get(namespace + 'Compliance_Rule__c')
                    .getDescribe()
                    .fields.getMap()
                    .get(namespace + 'Action__c')
                    .getDescribe()
                    .getPicklistValues()[0]
                .getValue(),
            Error_Message__c = 'test error message',
            Record_Count__c = 1,
            Record_Count_Criteria__c = 'Number of groups',
            RecordTypeId = Schema.SObjectType.Compliance_Rule__c.getRecordTypeInfosByName().get('Copado').getRecordTypeId(),
            Risk_Details__c = 'test risk details',
            Severity__c = 'Low'
        );
    }

    private static Compliance_Rule__c getTestComplianceRule() {
        return [SELECT Id FROM Compliance_Rule__c LIMIT 1].get(0);
    }

    private static List<Compliance_Rule_Criteria__c> getCriteriasById(Id id) {
        return [
            SELECT
                Id,
                Name,
                Compliance_Rule__r.Metadata_Type__c,
                Compliance_Rule__r.Filter_Criteria__c,
                Compliance_Rule__r.Is_Valid__c,
                Compliance_Rule__r.Record_Count_Criteria__c,
                Compliance_Rule__r.Matching_Criteria__c,
                Compliance_Rule__r.Record_Count__c
            FROM Compliance_Rule_Criteria__c
            WHERE Compliance_Rule__c = :id
        ];
    }

    private static final String TEST_VALUE = 'testValue';
}