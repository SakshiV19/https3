@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class MonitorCtrl {
    //PUBLIC

    @AuraEnabled
    public static JobDetails fetchJobDetails(Id recordId, String fieldApiName) {
        JobDetails result = null;

        String jobId = getJobId(recordId, fieldApiName);

        if (String.isNotBlank(jobId)) {
            JobExecution__c job = new JobExecutionsSelector().byId(jobId);
            result = new JobDetails(job);
            result.stepDetails = getStepDetails(result.id);
        }

        return result;
    }

    // PRIVATE

    private static String getJobId(Id recordId, String fieldApiName) {
        String objectApiName = recordId.getSobjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
        String query = String.format(
            'SELECT {0} FROM {1} WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1',
            new List<String>{ fieldApiName, objectApiName }
        );
        List<SObject> parentRecord = Database.query(query);

        return parentRecord.isEmpty() ? null : (String) parentRecord[0].get(fieldApiName);
    }

    private static List<StepDetails> getStepDetails(Id jobId) {
        List<StepDetails> result = new List<StepDetails>();
        Set<Id> resultIds = new Set<Id>();

        List<JobStep__c> steps = fetchSteps(jobId);

        for (JobStep__c step : steps) {
            if (step.Type__c == 'Function') {
                resultIds.add(step.Result__c);
            }
        }

        Map<Id, List<History>> resultHistoryByResultId = getResultHistory(resultIds);

        for (JobStep__c step : steps) {
            StepDetails stepDetails = new StepDetails(step);
            if (step.Result__c != null) {
                ResultDetail resultDetail = new ResultDetail(step);
                resultDetail.histories = resultHistoryByResultId.get(step.Result__c);
                if (resultDetail.histories == null) {
                    resultDetail.histories = new List<History>{
                        new History(step.Result__r.CreatedDate, step.ResultDataJson__c)
                    };
                }
                stepDetails.resultDetail = resultDetail;
            }

            stepDetails.status = getStepStatus(step);
            result.add(stepDetails);
        }

        return result;
    }

    private static Map<Id, List<History>> getResultHistory(Set<Id> ids) {
        Map<Id, List<History>> result = new Map<Id, List<History>>();
        Set<String> trackedFields = new Set<String>{ 'Progress_Status__c', Settings.ns + 'Progress_Status__c' };

        for (Result__History history : [
            SELECT ParentId, CreatedDate, NewValue
            FROM Result__History
            WHERE ParentId IN :ids AND Field IN :trackedFields
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate
        ]) {
            if (result.containsKey(history.ParentId)) {
                result.get(history.ParentId).add(new History(history));
            } else {
                result.put(history.ParentId, new List<History>{ new History(history) });
            }
        }

        return result;
    }

    private static String getStepStatus(JobStep__c step) {
        String result = step.Status__c;

        if (step.Result__c == null) {
            result = 'Not Started';
        } else if (step.Type__c == 'Manual') {
            result = step.Status__c == 'In Progress' ? 'Pending' : step.Status__c;
        } else if (step.Status__c == 'In Progress' && String.isNotBlank(step.Result__r.Progress_Status__c)) {
            result = step.Result__r.Progress_Status__c;
        }

        return result;
    }

    private static List<JobStep__c> fetchSteps(String jobId) {
        return [
            SELECT
                Name,
                Type__c,
                Status__c,
                Result__c,
                Result__r.Name,
                ResultDataJson__c,
                Result__r.CreatedDate,
                Result__r.Status__c,
                Result__r.Progress_Status__c,
                JobExecution__r.Template__r.Name
            FROM JobStep__c
            WHERE JobExecution__c = :jobId
            WITH SECURITY_ENFORCED
            ORDER BY Order__c
        ];
    }

    public class JobDetails {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String template;
        @AuraEnabled
        public Datetime lastModifiedDate;
        @AuraEnabled
        public List<StepDetails> stepDetails;

        public JobDetails(JobExecution__c job) {
            this.id = job.Id;
            this.status = job.Status__c;
            this.template = job.Template__c;
            this.title = job.Template__r?.Name;
            this.lastModifiedDate = job.LastModifiedDate;
        }
    }

    public class StepDetails {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public ResultDetail resultDetail;

        public StepDetails(JobStep__c step) {
            this.id = step.Id;
            this.name = step.Name;
            this.type = step.Type__c;
            this.status = step.Status__c;
        }
    }

    public class ResultDetail {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Datetime createdDate;
        @AuraEnabled
        public List<History> histories;

        public ResultDetail(Result__c result) {
            this.id = result.Id;
            this.name = result.Name;
            this.status = result.Status__c;
            this.createdDate = result.CreatedDate;
        }

        public ResultDetail(JobStep__c step) {
            this.id = step.Result__c;
            this.name = step.Result__r?.Name;
            this.status = step.Result__r?.Status__c;
            this.createdDate = step.Result__r?.CreatedDate;
        }
    }

    public class History {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Datetime createdDate;

        public History(Datetime createdDate, String value) {
            this.value = value;
            this.createdDate = createdDate;
        }

        public History(Result__History history) {
            this.value = (String) history.NewValue;
            this.createdDate = history.CreatedDate;
        }
    }
}