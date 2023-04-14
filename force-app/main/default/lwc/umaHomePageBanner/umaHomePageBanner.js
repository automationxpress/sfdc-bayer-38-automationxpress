import { LightningElement } from 'lwc';
import BayerRestrictedData from '@salesforce/label/c.BayerRestrictedData';
import BayerRestrictedDataOnRight from '@salesforce/label/c.BayerRestrictedDataOnRight';


export default class UmaHomePageBanner extends LightningElement {
    label = {
        BayerRestrictedData,
        BayerRestrictedDataOnRight
    };
}