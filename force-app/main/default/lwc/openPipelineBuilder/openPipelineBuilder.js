import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { namespace } from 'c/copadocoreUtils';

import getPipelineData from '@salesforce/apex/PipelineLaunchWizardCtrl.getPipelineData';

import { label } from './constants';

export default class OpenPipelineBuilder extends NavigationMixin(LightningElement) {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;

        getPipelineData({ pipelineId: this.recordId }).then(result => {
            this.hasStageConnections = result.hasStageConnections;
            this.pipelineBuilderPage = result.pipelineBuilderPage;
            if (!this.hasStageConnections) {
                this.showError = true;
                this.errorTitle = label.PIPELINE_BUILDER_NO_STAGES_ERROR;
                this.errorMessage = label.PIPELINE_BUILDER_NO_STAGES_ERROR_MESSAGE;
            } else if (!this.pipelineBuilderPage) {
                this.showError = true;
                this.errorTitle = label.PIPELINE_BUILDER_PLATFORM_NOT_SUPPORTED;
                this.errorMessage = label.PIPELINE_BUILDER_PLATFORM_NOT_SUPPORTED_MESSAGE;
            } else {
                this._navigateToPipelineBuilder(this.pipelineBuilderPage);
            }
        });
    }

    get recordId() {
        return this._recordId;
    }

    label = label;

    hasStageConnections = false;
    showError = false;

    pipelineBuilderPage;
    errorTitle;
    errorMessage;

    // PUBLIC

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // PRIVATE

    _navigateToPipelineBuilder(pageName) {
        const parameters = {};
        parameters[`${namespace || 'c__'}recordId`] = this.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: pageName
            },
            state: parameters
        });
    }
}