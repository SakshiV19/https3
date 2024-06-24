public with sharing class SetTestReadinessIndicator {
    List<Test__c> newtests;

    //CTOR

    public SetTestReadinessIndicator(List<Test__c> newtests) {
        this.newtests = newtests;       
    }

    //PUBLIC

    public void execute() {
        Map<String, TestTool__mdt> testToolByLabel = initTestToolsAvailable();
        Map<Id, ExtensionConfiguration__c> extensionConfigById = new ExtensionConfigurationsSelector().getExtensionConfigsByIds(newtests, null);

        for (Test__c test : newtests) {
            TestTool__mdt testTool = testToolByLabel.get(extensionConfigById.get(test.ExtensionConfiguration__c).ExtensionTool__c);

            test.ReadyToRun__c = testTool.Automate_Test_Readiness__c && (String.isBlank(testTool.Test_Readiness_Logic__c) ? true : runToolAction(testTool?.Test_Readiness_Logic__c));
        }
    }

    //PRIVATE

    private Map<String, TestTool__mdt> initTestToolsAvailable() {
        Map<String, TestTool__mdt> testToolsAvailable = new Map<String, TestTool__mdt>();

        List<TestTool__mdt> testTools = new TestToolsSelector().getAll();
        for (TestTool__mdt testTool : testTools) {
            testToolsAvailable.put(testTool.MasterLabel, testTool);
        }
        return testToolsAvailable;
    }

    private Boolean runToolAction(String toolAction) {
        Boolean result;
        if (String.isNotBlank(toolAction)) {
            Type callbackClass = typeByName(toolAction);
            result = ((TestReadinessInterface) callbackClass.newInstance()).execute();
        }
        return result;
    }

    private Type typeByName(String toolAction) {
        String namespace = toolAction.contains('.') ? toolAction.substringBefore('.') : '';
        String className = toolAction.contains('.') ? toolAction.substringAfter('.') : toolAction;

        Type result = Type.forName(namespace, className);
        if (result == null) {
            throw new ApplicationException(Label.InvalidCallback + ' ' + toolAction);
        }

        return result;
    }
}