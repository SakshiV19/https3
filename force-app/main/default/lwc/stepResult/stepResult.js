import { LightningElement, api } from 'lwc';
import { labels } from './constants';

export default class StepResult extends LightningElement {
    step;
    result;

    label = labels;
    customIconColor = '#025fb2';

    @api
    get jobStep() {
        return this.step;
    }
    set jobStep(value) {
        const jobStep = { ...value };
        jobStep.link = `/${jobStep.id}`;
        jobStep.result = `/${jobStep.resultDetail?.id}`;
        jobStep.isInProgress = jobStep.resultDetail?.status === 'In Progress';
        jobStep.isNotStarted = !jobStep.resultDetail || jobStep.resultDetail?.status === 'Not Started';
        jobStep.isFinished = ['Success', 'Failed', 'Cancelled'].includes(jobStep.resultDetail?.status);
        jobStep.isManualTask = jobStep.type === 'Manual';

        this.step = jobStep;
        this.result = { ...jobStep.resultDetail };
    }

    renderedCallback() {
        if (this.step.resultDetail?.status === 'Success') {
            this.template.querySelector('.step').classList.toggle('success');
        }
        if (this.step.resultDetail?.status === 'Failed') {
            this.template.querySelector('.step').classList.toggle('failed');
        }
    }

    get finishedIconVariant() {
        const variantByStatus = {
            Success: 'success',
            Failed: 'error'
        };

        return variantByStatus[this.step.resultDetail?.status];
    }

    get finishedIconName() {
        const iconByStatus = {
            Success: 'utility:success',
            Failed: 'utility:error',
            Cancelled: 'utility:ban'
        };

        return iconByStatus[this.step.resultDetail?.status];
    }

    toggleHistory() {
        this.template.querySelector('.step').classList.toggle('slds-is-open');
        this.template.querySelector('.historyBtn').classList.toggle('historyBtn-open');
        this.dispatchEvent(new CustomEvent('userworking', { detail: this.template.querySelector('.step').classList.contains('slds-is-open') }));
    }

    refreshManually() {
        this.dispatchEvent(new CustomEvent('refresh'));
    }

    handleMenuSelect(event) {
        const selectedItem = event.detail.value;

        if (selectedItem === labels.UPDATE_MANUAL_TASK_BUTTON) {
            this.template.querySelector('c-copadocore-modal').show();
        }
    }

    hideModal() {
        this.template.querySelector('c-copadocore-modal').hide();
    }

    saveManualTask() {
        this.template.querySelector('c-complete-manual-task').saveManualTaskFromCustomModal();
    }
}