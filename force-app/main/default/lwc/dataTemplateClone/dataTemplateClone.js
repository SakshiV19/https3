import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import COPADO_ALERT_CHANNEL from '@salesforce/messageChannel/CopadoAlert__c';
import { reduceErrors } from 'c/copadocoreUtils';
import cloneTemplate from '@salesforce/apex/DataTemplateCloneCtrl.cloneTemplate';
import { NavigationMixin } from 'lightning/navigation';
import { createAlert } from './utils';

export default class DataTemplateClone extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;

    @api recordId;

    isExecuting = false;
    communicationId = 'DataTemplateAlerts';
    alertId = 'clone';

    @api
    invoke() {
        if (!this.isExecuting) {
            this.isExecuting = true;
            this.cloneTemplate();
        }
    }
    async cloneTemplate(event) {
        try {
            this._publishOnMessageChannel(undefined, undefined, 'remove');
            const resp = await cloneTemplate({ recordId: this.recordId });
            this._navigateToRecordViewPage(resp);
        } catch (error) {
            const errorMessage = reduceErrors(error);
            this._publishOnMessageChannel(errorMessage, 'error', 'add');
        } finally {
            this.isExecuting = false;
        }
    }

    _navigateToRecordViewPage(recordId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    _publishOnMessageChannel(message, type, operation) {
        const alertMessage = createAlert(message, type, true, this.communicationId, this.alertId, operation);
        publish(this.messageContext, COPADO_ALERT_CHANNEL, alertMessage);
    }
}