global with sharing class AddDynamicJobStep implements MCCallback {
    global void execute(Function__c function, Result__c result, String status) {
        try {
            if (status == 'Success') {
                id jobExecutionId = new ResultsSelector().byIds(new Set<Id>{ result.Id })[0].JobStep__r.JobExecution__c;
                if (isConditionMet(result.Id)) {
                    injectSteps(jobExecutionId);
                }
            }
        } catch (Exception ex) {
            throw new ApplicationException(ex.getMessage() + '' + ex.getStackTraceString());
        }
    }

    // PRIVATE

    private Boolean isConditionMet(Id resultId) {
        Boolean result;

        List<ContentDocumentLink> fileLink = new ContentDocumentLinksSelector()
            .byLinkedEntityIdAndTitle(new Set<Id>{ resultId }, 'evaluation-result.json');

        if (!fileLink.isEmpty()) {
            String fileContent = new ContentVersionsSelector().byContentDocumentIdWithLatest(new Set<Id>{ fileLink[0].ContentDocumentId })[0]
                .VersionData.toString();

            if (String.isNotBlank(fileContent)) {
                Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped(fileContent);
                result = (Boolean) jsonObj.get('metadata');
            }
        }

        return result;
    }

    private void injectSteps(id jobId) {
        List<Jobs.ExecutionStep> execSteps = new List<Jobs.ExecutionStep>();
        List<JobStep__c> steps = new JobStepsSelector().byTemplateApiName('SR_JT_1');

        Jobs.ExecutionStep eStep = new Jobs.ExecutionStep();
        eStep.sequence = 'after';
        eStep.steps = steps;
        execSteps.add(eStep);

        Jobs.Execution.addSteps(new Jobs.AddStepsRequest(jobId, execSteps));
    }
}