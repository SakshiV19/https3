import { LightningElement, api } from 'lwc';

export default class Sample extends LightningElement {
    @api recordId;

    get recordInfo() {
        return this.recordId;
    }
}