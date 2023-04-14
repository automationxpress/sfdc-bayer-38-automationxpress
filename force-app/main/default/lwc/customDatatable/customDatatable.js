import LightningDatatable from 'lightning/datatable';
import customIconTemplate from './customIcon.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        customIcon: {
            template: customIconTemplate,
            typeAttributes: ['iconName', 'title', 'variant'],
        }
    };
}