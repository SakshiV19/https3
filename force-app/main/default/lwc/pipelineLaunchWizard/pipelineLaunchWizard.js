import { LightningElement, api } from 'lwc';
import validateUserPermissions from '@salesforce/apex/PipelineLaunchWizardCtrl.validateUserPermissions';
import getFieldsFromFieldSet from '@salesforce/apex/PipelineLaunchWizardCtrl.getFieldsFromFieldSet';
import validateRepository from '@salesforce/apex/PipelineLaunchWizardCtrl.validateRepository';

import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';

import { uniqueKey, namespace, reduceErrors, formatLabel, handleAsyncError } from 'c/copadocoreUtils';
import search from '@salesforce/apex/CustomLookupComponentHelper.search';
import { label, schema, constants } from './constants';

export default class PipelineLaunchWizard extends NavigationMixin(LightningElement) {
    label = label;
    schema = schema;
    constants = constants;

    showSpinner = true;
    userHasPermission = false;

    // Inputs
    projectName = constants.EMPTY_STRING;
    platform = constants.EMPTY_STRING;
    gitRepositoryId;
    gitRepositoryType = this.gitRepositoryOptions[0].value;

    // Error handling
    showError = false;
    errorMessage;
    showErrorDetail = false;

    // Additional Fields
    pipelineObject = schema.PIPELINE_OBJECT;
    platformField = schema.PIPELINE_PLATFORM_FIELD;
    fieldSetInformation;
    additionalFields = [];

    // PRIVATE
    _additionalPipelineFields = {};
    _fieldSetName = namespace + constants.FIELDSET_NAME;
    _recordTypeId;

    get title() {
        return this.userHasPermission ? formatLabel(label.TITLE, [1]) : label.NEW_PIPELINE;
    }

    get cancelButtonLabel() {
        return this.userHasPermission ? label.CANCEL : label.CLOSE;
    }

    get gitRepositoryOptions() {
        return [
            { label: label.CREATE_NEW_GIT_REPOSITORY_RECORD, value: constants.GIT_REPOSITORY_TYPE_NEW },
            { label: label.SELECT_FROM_EXISTING_GIT_REPOSITORIES, value: constants.GIT_REPOSITORY_TYPE_EXISTING }
        ];
    }

    get nextDisabled() {
        return (
            this.showSpinner ||
            this.projectName === constants.EMPTY_STRING ||
            this.platform === constants.EMPTY_STRING ||
            (this.gitRepositoryType !== constants.GIT_REPOSITORY_TYPE_NEW && this.gitRepositoryId === undefined)
        );
    }

    get showAdditionalFields() {
        return this.fieldSetInformation && this.fieldSetInformation.fields.length;
    }

    get showGitRepository() {
        return this.gitRepositoryType === constants.GIT_REPOSITORY_TYPE_EXISTING;
    }

    // PUBLIC

    async connectedCallback() {
        try {
            await this._validatePermissions();
            this.show();
            if (this.userHasPermission) {
                await this._getAdditionalFields();
            }
        } catch (error) {
            this.errorMessage = reduceErrors(error);
            this.showError = true;
        } finally {
            this.showSpinner = false;
        }
    }

    @api show() {
        this.template.querySelector('c-cds-modal').show();
    }

    @api hide() {
        this.template.querySelector('c-cds-modal').hide();
    }

    handleClickCancel() {
        this.hide();
        this._navigateToListView();
    }

    async handleNext() {
        try {
            this.showSpinner = true;
            if (this.gitRepositoryType === constants.GIT_REPOSITORY_TYPE_NEW) {
                await this._createPipeline(true);
            } else if (this.gitRepositoryId) {
                const result = await this._validateRepository();
                if (result) {
                    await this._createPipeline(false);
                } else {
                    this._showRepositoryValidationError();
                }
            }
        } catch (error) {
            this.errorMessage = reduceErrors(error);
            this.showError = true;
        } finally {
            this.showSpinner = false;
        }
    }

    handleChange(event) {
        switch (event.target.name) {
            case constants.INPUT_PROJECT_NAME:
                this.projectName = event.target.value;
                break;
            case constants.INPUT_GIT_REPOSITORY_TYPE:
                this.gitRepositoryType = event.target.value;
                break;
            default:
                break;
        }
    }

    handlePlatformChange(event) {
        this.platform = event.detail.value;
    }

    handleAdditionalFieldChange(event) {
        if (this.additionalFields.length && this.additionalFields.some(record => record.name === event.target.fieldName)) {
            const changedField = this.additionalFields.find(record => record.name === event.target.fieldName);
            if (event.detail.checked) {
                this._additionalPipelineFields[changedField.name] = event.detail.checked;
            } else if (this._additionalPipelineFields[changedField.name] === true) {
                this._additionalPipelineFields[changedField.name] = event.detail.checked;
            } else {
                this._additionalPipelineFields[changedField.name] =
                    typeof event.detail.value === 'string' ? event.detail.value : event.detail.value[0];
            }
        }
    }

    async handleLookupSearch(event) {
        const lookupElement = event.target;

        const safeSearch = handleAsyncError(this._search, {
            title: label.ERROR_SEARCHING_RECORDS
        });

        const queryConfig = {
            searchField: schema.GIT_REPOSITORY_NAME_FIELD.fieldApiName,
            objectName: schema.GIT_REPOSITORY_OBJECT.objectApiName,
            searchKey: event.detail.searchTerm,
            extraFilterType: undefined,
            filterFormattingParameters: undefined
        };

        const result = await safeSearch(this, { queryConfig, objectLabel: label.GIT_REPOSITORY });
        if (result) {
            lookupElement.setSearchResults(result);
        }
    }

    getSelectedId(lookupData) {
        if (lookupData.detail.length) {
            this.gitRepositoryId = lookupData.detail[0];
        } else {
            this._reset();
        }
    }

    // PRIVATE

    async _validatePermissions() {
        const result = await validateUserPermissions();
        this.userHasPermission = result;
        if (!this.userHasPermission) {
            this.showError = true;
            this.errorMessage = label.MISSING_PERMISSIONS;
        }
    }

    async _validateRepository() {
        const result = await validateRepository({
            repositoryId: this.gitRepositoryId
        });

        return result;
    }

    async _createPipeline(createRepository) {
        if (createRepository) {
            const newRepo = await this._createGitRepository();
            this.gitRepositoryId = newRepo.id;
        }
        const fields = this._pipelineFields();
        const recordInput = { apiName: schema.PIPELINE_OBJECT.objectApiName, fields };
        const pipeline = await createRecord(recordInput);
        if (pipeline.id) {
            await this._createProject(pipeline.id);
            this._navigateToPipelineRecord(pipeline.id);
        }
    }

    async _createProject(pipelineId) {
        const fields = this._projectFields(pipelineId);
        const recordInput = { apiName: schema.PROJECT_OBJECT.objectApiName, fields };
        await createRecord(recordInput);
    }

    async _createGitRepository() {
        const fields = this._gitRepositoryFields();
        const recordInput = { apiName: schema.GIT_REPOSITORY_OBJECT.objectApiName, fields };
        const repository = await createRecord(recordInput);
        return repository;
    }

    async _createGitRepository() {
        const fields = this._gitRepositoryFields();
        const recordInput = { apiName: schema.GIT_REPOSITORY_OBJECT.objectApiName, fields };
        const repository = await createRecord(recordInput);
        return repository;
    }

    _pipelineFields() {
        const fields = {};
        fields[schema.PIPELINE_NAME_FIELD.fieldApiName] = this.projectName;
        fields[schema.PIPELINE_PLATFORM_FIELD.fieldApiName] = this.platform;
        fields[schema.PIPELINE_MAIN_BRANCH_FIELD.fieldApiName] = constants.MAIN_BRANCH;
        if (this.gitRepositoryId) {
            fields[schema.PIPELINE_GIT_REPOSITORY_FIELD.fieldApiName] = this.gitRepositoryId;
        }
        Object.assign(fields, this._additionalPipelineFields);
        return fields;
    }

    _projectFields(pipelineId) {
        const fields = {};
        fields[schema.PROJECT_NAME_FIELD.fieldApiName] = this.projectName;
        fields[schema.PROJECT_PIPELINE__FIELD.fieldApiName] = pipelineId;
        return fields;
    }

    _gitRepositoryFields() {
        const fields = {};
        fields[schema.GIT_REPOSITORY_NAME_FIELD.fieldApiName] = this.projectName;
        return fields;
    }

    _search(self, queryConfig) {
        return search(queryConfig);
    }

    async _getAdditionalFields() {
        const fieldSetData = await getFieldsFromFieldSet({
            fieldSet: this._fieldSetName
        });

        if (fieldSetData.fields.length) {
            this.fieldSetInformation = fieldSetData;
            this.additionalFields = [...fieldSetData.fields];
        }
    }

    _navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: schema.PIPELINE_OBJECT.objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
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

    _showErrorOnLookup(repositoryId) {
        const lookupElement = this.template.querySelector(`c-lookup[data-repoid="${repositoryId}"]`);
        if (lookupElement) {
            lookupElement.errors = [{ id: uniqueKey('lookup-error'), message: label.NOT_AUTHENTICATED }];
        }
    }

    _cleanErrorOnLookup(repositoryId) {
        const lookupElement = this.template.querySelector(`c-lookup[data-repoid="${repositoryId}"]`);
        if (lookupElement) {
            lookupElement.errors = [];
        }
    }

    _showRepositoryValidationError() {
        this.showError = true;
        this.errorMessage = label.GIT_REPOSITORY_VALIDATION_ERROR;
        this.showErrorDetail = true;
        this._showErrorOnLookup(this.gitRepositoryId);
    }

    _reset() {
        this.showError = false;
        this.errorMessage = undefined;
        this.showErrorDetail = false;

        if (this.gitRepositoryId) {
            this._cleanErrorOnLookup(this.gitRepositoryId);
            this.gitRepositoryId = undefined;
        }
    }
}