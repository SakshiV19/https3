import CANCEL from '@salesforce/label/c.Cancel';
import CLOSE from '@salesforce/label/c.CLOSE';
import NEXT from '@salesforce/label/c.NEXT';
import NEW_PIPELINE from '@salesforce/label/c.NEW_DEPLOYMENT_FLOW';
import TITLE from '@salesforce/label/c.New_Pipeline_Wizard_Title';
import SUBTITLE from '@salesforce/label/c.New_Pipeline_Wizard_SubTitle';
import REPOSITORY_REQUIREMENTS from '@salesforce/label/c.New_Pipeline_Wizard_Repository_Requirements';
import PROJECT_NAME from '@salesforce/label/c.New_Pipeline_Wizard_Project_Name';
import PLATFORM from '@salesforce/label/c.New_Pipeline_Wizard_Platform';
import CHOOSE_GIT_REPOSITORY from '@salesforce/label/c.New_Pipeline_Wizard_Choose_Git_Repository';
import RECORD_ALREADY_EXISTS from '@salesforce/label/c.New_Pipeline_Wizard_Record_Already_Exists';
import GIT_REPOSITORY from '@salesforce/label/c.GIT_REPOSITORY';

import PROJECT_NAME_HELPTEXT from '@salesforce/label/c.Project_Name_Helptext';
import PLATFORM_HELPTEXT from '@salesforce/label/c.Platform_Helptext';
import GIT_PROVIDER_HELPTEXT from '@salesforce/label/c.Git_Provider_Helptext';
import GIT_REPOSITORY_HELPTEXT from '@salesforce/label/c.Git_Repository_Helptext';

import CREATE_NEW_GIT_REPOSITORY_RECORD from '@salesforce/label/c.Create_New_Git_Repository_Record';
import SELECT_FROM_EXISTING_GIT_REPOSITORIES from '@salesforce/label/c.Select_From_Existing_Git_Repositories';

import MISSING_PERMISSION_VALIDATION_ERROR from '@salesforce/label/c.Missing_Permissions_Validation_Error';
import GIT_REPOSITORY_VALIDATION_ERROR from '@salesforce/label/c.Git_Repository_Validation_Error';
import MISSING_PERMISSIONS from '@salesforce/label/c.Missing_Permissions';
import NOT_AUTHENTICATED from '@salesforce/label/c.Not_Authenticated';

import PLATFORM_PLACEHOLDER from '@salesforce/label/c.Platform_Placeholder';
import SELECT_GIT_PROVIDER_PLACEHOLDER from '@salesforce/label/c.Select_Git_Provider_Placeholder';
import SELECT_COPADO_REPOSITORY_PLACEHOLDER from '@salesforce/label/c.Select_Copado_Repository_Placeholder';
import ERROR_SEARCHING_RECORDS from '@salesforce/label/c.Error_Searching_Records';

import SALESFORCE_CLASSIC from '@salesforce/label/c.SALESFORCE_CLASSIC';

import PIPELINE_OBJECT from '@salesforce/schema/Deployment_Flow__c';
import PIPELINE_NAME_FIELD from '@salesforce/schema/Deployment_Flow__c.Name';
import PIPELINE_MAIN_BRANCH_FIELD from '@salesforce/schema/Deployment_Flow__c.Main_Branch__c';
import PIPELINE_PLATFORM_FIELD from '@salesforce/schema/Deployment_Flow__c.Platform__c';
import PIPELINE_GIT_REPOSITORY_FIELD from '@salesforce/schema/Deployment_Flow__c.Git_Repository__c';

import PROJECT_OBJECT from '@salesforce/schema/Project__c';
import PROJECT_NAME_FIELD from '@salesforce/schema/Project__c.Name';
import PROJECT_PIPELINE__FIELD from '@salesforce/schema/Project__c.Deployment_Flow__c';

import GIT_REPOSITORY_OBJECT from '@salesforce/schema/Git_Repository__c';
import GIT_REPOSITORY_NAME_FIELD from '@salesforce/schema/Git_Repository__c.Name';

export const label = {
    CANCEL,
    CLOSE,
    NEXT,
    NEW_PIPELINE,
    TITLE,
    SUBTITLE,
    REPOSITORY_REQUIREMENTS,
    PROJECT_NAME,
    PLATFORM,
    GIT_REPOSITORY,
    CHOOSE_GIT_REPOSITORY,
    RECORD_ALREADY_EXISTS,
    SALESFORCE_CLASSIC,

    PLATFORM_PLACEHOLDER,
    SELECT_GIT_PROVIDER_PLACEHOLDER,
    SELECT_COPADO_REPOSITORY_PLACEHOLDER,

    ERROR_SEARCHING_RECORDS,

    PROJECT_NAME_HELPTEXT,
    PLATFORM_HELPTEXT,
    GIT_PROVIDER_HELPTEXT,
    GIT_REPOSITORY_HELPTEXT,

    MISSING_PERMISSION_VALIDATION_ERROR,
    GIT_REPOSITORY_VALIDATION_ERROR,
    MISSING_PERMISSIONS,
    NOT_AUTHENTICATED,

    CREATE_NEW_GIT_REPOSITORY_RECORD,
    SELECT_FROM_EXISTING_GIT_REPOSITORIES
};

export const schema = {
    PIPELINE_OBJECT,
    PIPELINE_NAME_FIELD,
    PIPELINE_MAIN_BRANCH_FIELD,
    PIPELINE_PLATFORM_FIELD,
    PIPELINE_GIT_REPOSITORY_FIELD,
    PROJECT_OBJECT,
    PROJECT_NAME_FIELD,
    PROJECT_PIPELINE__FIELD,
    GIT_REPOSITORY_OBJECT,
    GIT_REPOSITORY_NAME_FIELD
};

const SALESFORCE_CLASSIC_OPTION_VALUE = 'Salesforce';
const SALESFORCE_2ND_GEN_OPTION_VALUE = 'Other';

const GIT_REPOSITORY_TYPE_NEW = 'newRepository';
const GIT_REPOSITORY_TYPE_EXISTING = 'existingRepository';

const EMPTY_STRING = '';

const INPUT_PROJECT_NAME = 'projectName';
const INPUT_PLATFORM = 'platform';
const INPUT_GIT_REPOSITORY_TYPE = 'gitRepositoryType';
const MAIN_BRANCH = 'main';
const FIELDSET_NAME = 'Additional_Information';

export const constants = {
    SALESFORCE_CLASSIC_OPTION_VALUE,
    SALESFORCE_2ND_GEN_OPTION_VALUE,

    EMPTY_STRING,

    INPUT_PROJECT_NAME,
    INPUT_PLATFORM,
    MAIN_BRANCH,
    INPUT_GIT_REPOSITORY_TYPE,
    FIELDSET_NAME,

    GIT_REPOSITORY_TYPE_NEW,
    GIT_REPOSITORY_TYPE_EXISTING
};