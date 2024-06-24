import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { labels } from './constants';
import { namespace } from 'c/copadocoreUtils';

import JOB_EXECUTION_OBJECT from '@salesforce/schema/JobExecution__c';

import fetchJobDetails from '@salesforce/apex/MonitorCtrl.fetchJobDetails';

export default class Monitor extends NavigationMixin(LightningElement) {
    @api fieldApiName = 'Last_Promotion_Execution_Id__c';
    @api recordId;
    @api objectApiName; // For future use
    @api noJobTitle = labels.Job_Execution_Not_Started;
    @api noJobMessage = labels.Live_Message_Component_Message;

    job;
    noStepsMessage;

    offset = 5;
    label = labels;
    isLoading = false;
    eventChannel = `/event/${namespace}Event__e`;

    _isUserWorking = false;

    async connectedCallback() {
        this.isLoading = true;

        await this._getJobDetails();

        if ((!this.job || this.job.isUnfinished)) {
            this.template.querySelector('c-platform-event-subscriber').subscribe();
        }

        this.isLoading = false;
    }


    async refreshManually() {
        this.isLoading = true;

        try {
            await this._getJobDetails();
        } catch (error) {
            console.error(error);
        }

        this.isLoading = false;
    }


    setUserWorking(event) {
        this._isUserWorking = event.detail;
    }


    scrollToCurrentStep() {
        if (!this._isUserWorking) {
            const stepContainer = this.template.querySelector(`[id^="jobsteps"]`);
            const allSteps = Array.prototype.slice.call(stepContainer.children);
            const currentStep = allSteps.find((step) => {
                return step.jobStep.resultDetail?.status === 'In Progress';
            });
            const scrollPosition = currentStep ? currentStep.offsetTop - this.offset : 0;

            stepContainer.scrollTop = scrollPosition;
        }
    }


    async handlePlatformEvent(event) {
        if (!this.job?.stepDetails?.length || this._isRelevant(event)) {
            await this._getJobDetails();
        }
    }


    navigateToJobExecution() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.job.id,
                objectApiName: JOB_EXECUTION_OBJECT,
                actionName: 'view'
            }
        });
    }


    async _getJobDetails() {
        const job = (this.job = await fetchJobDetails({
            recordId: this.recordId,
            fieldApiName: this.fieldApiName
        }));
        if (job) {
            if (job.status === 'Successful') {
                job.message = 'Completed';
                job.iconName = 'utility:success';
                job.iconVariant = 'success';
            } else if (job.status === 'Error') {
                job.message = 'There was a problem';
                job.iconName = 'utility:error';
                job.iconVariant = 'error';
            } else {
                job.isUnfinished = true;
            }
            job.templateLink = `/${job.template}`;
            this.noStepsMessage = job?.template ? `${job.title} is empty` : labels.Nothing_to_execute;
            this.job = job;
        }
    }


    _isRelevant(event) {
        const message = event.detail.response;
        const fieldName = (!!namespace ? namespace : '') + 'Topic_Uri__c';
        const topicUri = message.data.payload[fieldName];

        return this.job.stepDetails.some((element) => {
            return topicUri.includes('step-monitor') && topicUri.includes(element.id);
        });
    }
}