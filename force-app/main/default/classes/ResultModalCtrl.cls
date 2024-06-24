public with sharing class ResultModalCtrl {
    // PUBLIC

    @AuraEnabled
    public static Result__c getResultDetails(Id recId) {
        try {
            return new ResultsSelector().byId(recId);
        } catch (Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }

    @AuraEnabled
    public static List<JobStep__c> getStepsOf(Id jobId) {
        try {
            return new JobStepsSelector().byJobWithResults(new Set<String>{ jobId });
        } catch (Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }
}