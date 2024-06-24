import { LightningElement, api } from 'lwc';
import { label, schema, columns } from './constants';
import { namespace } from 'c/copadocoreUtils';
import { getSortedData } from 'c/datatableService';

import getResultDetails from '@salesforce/apex/ResultModalCtrl.getResultDetails';
import getJobSteps from '@salesforce/apex/ResultModalCtrl.getStepsOf';

export default class ResultModal extends LightningElement {
    @api recordId;

    label = label;
    schema = schema;
    columns = columns;
    modalSize = 'small';
    record = {};
    subJobSteps = [];
    isLoading = false;
    resultStatus;
    sortDirection = 'asc';
    sortedBy;
    iframeSrc;

    _interval;
    _jobStepName;
    _jobStepSubJob;
    _resultName;

    // GETTER

    get modalHeader() {
        return `${this.label.RESULT} - ${this._jobStepName}`;
    }

    get resultUrl() {
        return `/${this.recordId}`;
    }

    get viewResultLabel() {
        return `${this.label.RESULT} ${this.label.RECORD} - ${this._resultName}`;
    }

    get showErrorFields() {
        return this.resultStatus === 'Failed' || this.resultStatus === 'Cancelled';
    }

    get bannerClass() {
        const baseClass = 'slds-scoped-notification slds-media slds-media_center';
        let bannerClass = baseClass;

        if (this.resultStatus === 'Success') {
            bannerClass = `${baseClass} slds-theme_success`;
        } else if (this.resultStatus === 'Failed') {
            bannerClass = `${baseClass} slds-theme_error`;
        } else if (this.resultStatus === 'In Progress') {
            bannerClass = `${baseClass} slds-scoped-notification_light`;
        } else if (this.resultStatus === 'Cancelled') {
            bannerClass = `${baseClass} slds-scoped-notification_dark`;
        }

        return bannerClass;
    }

    get iconName() {
        const iconByStatus = {
            Success: 'utility:success',
            Failed: 'utility:error',
            Cancelled: 'utility:ban',
            'In Progress': 'utility:info'
        };

        return iconByStatus[this.resultStatus];
    }

    get iconClass() {
        return this.resultStatus === 'In Progress' ? '' : 'icon';
    }

    get hasSubJob() {
        return this._jobStepSubJob && this._jobStepSubJob.length > 0;
    }

    get stepCount() {
        return this.subJobSteps?.length;
    }

    get stepsTabHeader() {
        return `${label.ALL_STEPS_IN_EXECUTION} (${this.stepCount})`;
    }

    @api
    async show(recordId) {
        this.recordId = recordId;
        this.template.querySelector('c-copadocore-modal').show();
        this.isLoading = true;

        await this._getResultDetails();
        if (this.hasSubJob) {
            await this._getSubJobSteps();
        }
        this._getiframeSrc();

        this._interval = setInterval(async () => {
            this._getResultDetails();
            if (this.hasSubJob) {
                await this._getSubJobSteps();
            }
            if (this.resultStatus !== 'In Progress') {
                clearInterval(this._interval);
            }
        }, 3000);

        this.isLoading = false;
    }

    handleClickClose() {
        clearInterval(this._interval);
        this.template.querySelector('c-copadocore-modal').hide();
    }

    async _getResultDetails() {
        try {
            this.record = await getResultDetails({ recId: this.recordId });

            if (this.record) {
                this.resultStatus = this.record[schema.RESULT_STATUS.fieldApiName];
                this._jobStepName = this.record[`${namespace}JobStep__r`][schema.JOB_STEP_NAME.fieldApiName];
                this._resultName = this.record[schema.RESULT_NAME.fieldApiName];
                this._jobStepSubJob = this.record[`${namespace}JobStep__r`][schema.STEP_SUB_JOB.fieldApiName];
            }
        } catch (error) {
            console.error(error);
        }
    }

    async _getSubJobSteps() {
        try {
            const data = await getJobSteps({ jobId: this._jobStepSubJob });
            let records = [];

            data.forEach(step => {
                records.push({
                    stepName: step.Name,
                    stepUrl: '/' + step.Id,
                    resultName: step[`${namespace}Result__c`] ? step[`${namespace}Result__r`][schema.RESULT_NAME.fieldApiName] : '',
                    resultUrl: step[`${namespace}Result__c`] ? '/' + step[`${namespace}Result__c`] : '',
                    status: step[`${namespace}Result__c`] ? step[`${namespace}Result__r`][schema.RESULT_STATUS.fieldApiName] : '',
                    errorMessage: step[`${namespace}Result__c`] ? step[`${namespace}Result__r`][schema.RESULT_ERROR_MSG.fieldApiName] : ''
                })
            });

            this.subJobSteps = [...records];
            records = [];
        } catch (error) {
            console.error(error);
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        await this._getSubJobSteps();
        this.isLoading = false;
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;

        this.subJobSteps = [
            ...getSortedData(this.columns, this.subJobSteps, {
                name: fieldName,
                sortDirection
            })
        ];
        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
    }

    _getiframeSrc() {
        //this.iframeSrc = '/lightning/cmp/c__dynamicResultViewer?c__recordId=a1809000003b7sDAAQ';
        //this.iframeSrc = '/apex/resultComponentsPage?recordId=a1809000003b7sDAAQ&locationId=AQF.Result.Viewer&requiredInformation=Test%20Tool';
        this.iframeSrc = '/apex/resultComponentsPage?recordId=a1809000003b7sDAAQ';
    }
}