import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { namespace, reduceErrors, formatLabel } from 'c/copadocoreUtils';

import getPipelineData from '@salesforce/apex/PipelineLaunchWizardCtrl.getPipelineData';
import validateRepository from '@salesforce/apex/PipelineLaunchWizardCtrl.validateRepository';

import { label, constants } from './constants';

import { createPipelineStructure } from './utils';

export default class PipelineResumeWizard extends NavigationMixin(LightningElement) {
    @api recordId;

    label = label;
    constants = constants;

    pipeline;
    stages = [];
    pipelineBuilderPage;
    gitRepositoryId;

    // counters
    environmentsCount = 1;
    streamsCount = 1;

    // type options
    type = constants.PIPELINE_TYPE_SEQUENTIAL;
    sequentialPreview = constants.PIPELINE_PREVIEW_IMAGES + '/sequential.svg';
    parallelPreview = constants.PIPELINE_PREVIEW_IMAGES + '/parallel.svg';

    showError = false;
    errorMessage;
    showGitAuthenticationComponent = false;
    showGoToPipelineBuilderButton = false;
    running = false;
    showNextButton = false;

    get title() {
        return formatLabel(label.TITLE, this.showGoToPipelineBuilderButton ? [2] : [1]);
    }

    get developmentEnvironmentsLabel() {
        return this.isSequential ? label.DEVELOPMENT_ENVIRONMENTS : label.DEVELOPMENT_ENVIRONMENTS_PER_STREAM;
    }

    get developmentEnvironmentsHelptext() {
        return this.isSequential ? label.DEVELOPMENT_ENVIRONMENTS_HELPTEXT : label.DEVELOPMENT_ENVIRONMENTS_PER_STREAM_HELPTEXT;
    }

    get finishWizardLabel() {
        return this.pipelineBuilderPage ? label.GO_TO_PIPELINE_BUILDER : label.SAVE;
    }

    get environmentsCounterInputClasses() {
        return 'cds-counter-icon counter-minus-icon' + (this.environmentsCount === 1 ? ' disabled' : '');
    }

    get streamsCounterInputClasses() {
        return 'cds-counter-icon counter-minus-icon' + (this.streamsCount === 1 ? ' disabled' : '');
    }

    get isSequential() {
        return this.type === constants.PIPELINE_TYPE_SEQUENTIAL;
    }

    get sequentialCardClass() {
        return 'cds-radio-card' + (this.isSequential ? ' selected' : '');
    }

    get isParallel() {
        return this.type === constants.PIPELINE_TYPE_PARALLEL;
    }

    get parallelCardClass() {
        return 'cds-radio-card' + (this.isParallel ? ' selected' : '');
    }

    get finishWizardButtonDisabled() {
        return this.running;
    }

    // PUBLIC

    async connectedCallback() {
        const data = await getPipelineData({ pipelineId: this.recordId });
        this.pipeline = data.pipeline;
        this.stages = data.stages;
        this.pipelineBuilderPage = data.pipelineBuilderPage;
        this.gitRepositoryId = data.gitRepositoryId;
        const result = await this._validateRepository();
        if (result) {
            if (!data.hasConnections) {
                this.showGoToPipelineBuilderButton = true;
                this.show();
            }
        } else {
            this.showGitAuthenticationComponent = true;
            this.show();
        }
    }

    @api show() {
        this.template.querySelector('c-cds-modal').show();
    }

    @api hide() {
        this.template.querySelector('c-cds-modal').hide();
    }

    handleChangePipelineType(event) {
        this.type = event.currentTarget.dataset.name;
        this._reset();
    }

    increaseEnvironmentsCount() {
        this.environmentsCount++;
    }

    handleDataFromAuthentication() {
        this.showNextButton = true;
    }

    decreaseEnvironmentsCount() {
        if (this.environmentsCount > 0) {
            this.environmentsCount--;
        }
    }
    handleChangeEnvironmentsCount(event) {
        const inputVal = parseInt(event.target.value, 10);
        this.environmentsCount = isNaN(inputVal) ? 0 : inputVal; // Ensure the environmentsCount is a number
    }

    increaseStreamsCount() {
        this.streamsCount++;
    }

    decreaseStreamsCount() {
        if (this.streamsCount > 0) {
            this.streamsCount--;
        }
    }

    handleChangeStreamsCount(event) {
        const inputVal = parseInt(event.target.value, 10);
        this.streamsCount = isNaN(inputVal) ? 0 : inputVal; // Ensure the environmentsCount is a number
    }

    handleClickCancel() {
        this.hide();
    }

    handleNext() {
        this.showGitAuthenticationComponent = false;
        this.showNextButton = false;
        this.showGoToPipelineBuilderButton = true;
    }

    async finishWizard() {
        try {
            this.running = true;
            await createPipelineStructure(this.pipeline, this.stages, this.environmentsCount, this.streamsCount);
            if (this.pipelineBuilderPage) {
                this._navigateToPipelineBuilder(this.pipelineBuilderPage);
            } else {
                this._navigateToPipelineRecord(this.pipeline.Id);
            }
        } catch (error) {
            this.errorMessage = reduceErrors(error);
            this.showError = true;
        } finally {
            this.running = false;
        }
    }

    _navigateToPipelineBuilder(pageName) {
        const parameters = {};
        parameters[`${namespace || 'c__'}recordId`] = this.pipeline.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: pageName
            },
            state: parameters
        });
    }

    _navigateToPipelineRecord(pipelineId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: pipelineId,
                actionName: 'view'
            }
        });
    }

    _reset() {
        this.environmentsCount = 1;
        this.streamsCount = 1;
    }

    async _validateRepository() {
        const result = await validateRepository({
            repositoryId: this.gitRepositoryId
        });

        return result;
    }
}