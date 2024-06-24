import LightningDatatable from 'lightning/datatable';
import progressRing from './progressRing.html';

export default class CustomDataTable extends LightningDatatable {
    static customTypes = {
        proRing: {
            template: progressRing,
            standardCellLayout: true
        }
    };
}