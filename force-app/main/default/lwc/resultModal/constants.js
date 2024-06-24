import RESULT from '@salesforce/label/c.Result';
import CLOSE from '@salesforce/label/c.CLOSE';
import STATUS from '@salesforce/label/c.STATUS';
import RECORD from '@salesforce/label/c.Record';
import EXECUTION_OUTCOME from '@salesforce/label/c.ExecutionOutcome';
import LOGS from '@salesforce/label/c.Logs';
import ALL_STEPS_IN_EXECUTION from '@salesforce/label/c.AllStepsInExecution';
import JOB_STEP from '@salesforce/label/c.JobStep';
import ERROR from '@salesforce/label/c.ERROR';
import MESSAGE from '@salesforce/label/c.MESSAGE';
import JOB_STEPS from '@salesforce/label/c.Job_Steps';
import REFRESH from '@salesforce/label/c.REFRESH';

import RESULT_OBJ from '@salesforce/schema/Result__c';
import RESULT_NAME from '@salesforce/schema/Result__c.Name';
import RESULT_STATUS from '@salesforce/schema/Result__c.Status__c';
import RESULT_PROGRESS_STATUS from '@salesforce/schema/Result__c.Progress_Status__c';
import RESULT_ERROR_CODE from '@salesforce/schema/Result__c.Error_Code__c';
import RESULT_ERROR_MSG from '@salesforce/schema/Result__c.Error_Message__c';
import RESULT_EXTERNAL_RESULT_LINK from '@salesforce/schema/Result__c.Link__c';
import JOB_STEP_NAME from '@salesforce/schema/JobStep__c.Name';
import STEP_SUB_JOB from '@salesforce/schema/JobStep__c.Sub_Job_Execution__c';

export const label = {
    RESULT,
    CLOSE,
    STATUS,
    RECORD,
    EXECUTION_OUTCOME,
    LOGS,
    ALL_STEPS_IN_EXECUTION,
    JOB_STEP,
    ERROR,
    MESSAGE,
    JOB_STEPS,
    REFRESH
};

export const schema = {
    RESULT_OBJ,
    RESULT_NAME,
    RESULT_STATUS,
    RESULT_PROGRESS_STATUS,
    RESULT_ERROR_CODE,
    RESULT_ERROR_MSG,
    RESULT_EXTERNAL_RESULT_LINK,
    JOB_STEP_NAME,
    STEP_SUB_JOB
};

export const columns = [
    {
        label: JOB_STEP, fieldName: 'stepUrl', type: 'url', hideDefaultActions: true, typeAttributes: {
            label: { fieldName: 'stepName' },
            target: '_blank'
        }, sortable: "true"
    },
    {
        label: RESULT, fieldName: 'resultUrl', type: 'url', hideDefaultActions: true, typeAttributes: {
            label: { fieldName: 'resultName' },
            target: '_blank'
        }
    },
    { label: STATUS, fieldName: 'status', type: 'text', hideDefaultActions: true },
    { label: `${ERROR} ${MESSAGE}`, fieldName: 'errorMessage', type: 'text', hideDefaultActions: true }
];