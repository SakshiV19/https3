import LightningDatatable from 'lightning/datatable';
import icon from './icon.html';

export default class TestTable extends LightningDatatable {
    static customTypes = {
        icon: {
            template: icon,
            standardCellLayout: true
        }
    };
}