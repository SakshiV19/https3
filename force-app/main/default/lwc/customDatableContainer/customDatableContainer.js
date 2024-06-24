import { LightningElement } from 'lwc';

export default class CustomDatableContainer extends LightningElement {
    columns = this._getColumns();
    data = this._getData();

    _getColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'name'
            },
            {
                label: 'Email',
                fieldName: 'email'
            },
            {
                label: 'Progress Indicator',
                fieldName: 'id',
                type: 'proRing'
            }
        ];
    }

    _getData() {
        return [
            { name: 'Neha', email: 'neha@gmail.com', id: 12 },
            { name: 'Pooja', email: 'pooja@gmail.com', id: 25 },
            { name: 'Krishna', email: 'krishna@gmail.com', id: 50 }
        ];
    }
}