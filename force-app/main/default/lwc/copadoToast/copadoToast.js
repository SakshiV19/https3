import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CopadoToast extends LightningElement {
    @api variant;
    @api message;
    @api title;
    @api mode;

    connectedCallback() {
        const evt = new ShowToastEvent({
            title: this._title || '',
            message: this.message || '',
            variant: this.variant || 'info',
            mode: this.mode || 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}