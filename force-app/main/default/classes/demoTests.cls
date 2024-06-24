public with sharing class demoTests {
    
    @AuraEnabled(cacheable=true)
    public static List<Test__c> getTests() {
        try {
            return [SELECT Id, Name, Type__c, Status__c FROM Test__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}