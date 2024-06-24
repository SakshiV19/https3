import { LightningElement, wire } from 'lwc';
import getTests from '@salesforce/apex/demoTests.getTests';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Test__c.Name';
const KEY_FIELD = 'Id';
export default class DatableDemo extends LightningElement {
    title = 'Demo Lightnig Datatable';
    iconName = 'standard:bot';
    enableSearch = true;
    columns = this._getColumns();
    allRows = [];
    data = [];
    searchValue;
    searchDataCount;
    keyField = KEY_FIELD;
    hasFooter = true;
    sortDirection;
    sortedBy = 'Name';

    @wire(getRecord, { recordId: 'a1r09000000CztUAAS', fields: [NAME_FIELD] })
    tests;

    get name() {
        return getFieldValue(this.tests.data, NAME_FIELD);
    }

    async connectedCallback() {
        this.allRows = await getTests();
        this.data = this.allRows;
    }

    handleApplySearch(event) {
        const searchObj = event.detail;
        this.searchValue = searchObj.searchTerm;
        this.data = [];
        this.data = searchObj.searchedData;
        this.searchDataCount = searchObj.searchDataCount;
    }

    _getColumns() {
        return [
            {
                label: 'Name',
                fieldName: 'Name',
                searchable: true,
                sortable: true
            },
            {
                label: 'Type',
                fieldName: 'Type__c'
            },
            {
                label: 'Status',
                fieldName: 'Status__c'
            }
        ];
    }

    handleClearSearch() {
        this.data = this.allRows;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allRows];

        cloneData.sort(this._sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    _sortBy(field, reverse) {
        const key = function (x) {
            return x[field];
        };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}