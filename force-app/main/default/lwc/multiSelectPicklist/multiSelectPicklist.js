import { LightningElement, track, api } from 'lwc';
import getLocationOptions from '@salesforce/apex/UserEntryEditController.getLocationOptions';
import getUserEntryData from '@salesforce/apex/UserEntryEditController.getUserEntryData';


export default class MultiSelectPicklist extends LightningElement {

    @api labelName;
    @api userEntryId;
    @api iconName;
    @track items = [];
    @track selectedItems = [];
    @track previousSelectedItems = [];
    @track globalSelectedItems = [];
    @track value = [];
    searchInput = '';
    isDialogDisplay = false;
    isDisplayMessage = false;
    error;


    connectedCallback() {
        getUserEntryData({ userEntryId: this.userEntryId })
            .then(result => {
                this.setLocations(result.locations.split(';'));
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    setLocations(locations) {
        this.globalSelectedItems = locations.map(
            row => Object.assign(
                {
                    "value": row,
                    "label": row
                })
        );

    }


    onChangeSearchInput(event) {
        this.searchInput = event.target.value;
        getLocationOptions({
            searchKey: this.searchInput

        })
            .then(result => {
                this.items = [];
                this.value = [];
                this.previousSelectedItems = [];

                if (result.length > 0) {
                    result.map(resElement => {
                        this.items = [...this.items, {
                            value: resElement,
                            label: resElement
                        }];

                        this.globalSelectedItems.map(element => {
                            if (element.value == resElement) {
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);
                            }
                        });
                    });
                    this.isDialogDisplay = true;
                    this.isDisplayMessage = false;
                }
                else {
                    this.isDialogDisplay = false;
                    this.isDisplayMessage = true;
                }
            })
            .catch(error => {
                this.error = error;
                this.items = undefined;
                this.isDialogDisplay = false;
            })


    }

    handleCheckboxChange(event) {
        let selectItemTemp = event.detail.value;
        this.selectedItems = [];

        selectItemTemp.map(p => {
            let arr = this.items.find(element => element.value == p);

            if (arr != undefined) {
                this.selectedItems.push(arr);
            }
        });
    }

    handleRemoveRecord(event) {
        const removeItem = event.target.dataset.item;
        this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != removeItem);
        //initialize values again
        this.initializeValues();
        this.value = [];

        let countryString = '';
        this.globalSelectedItems.map(element => {
            countryString += element.value + ';';
        });
        let finalStr = countryString.substring(0, countryString.length - 1);

        const evtCustomEvent = new CustomEvent('remove', {
            detail: { finalStr }
        });
        this.dispatchEvent(evtCustomEvent);
    }

    handleDoneClick(event) {
        this.globalSelectedItems = [];
        this.previousSelectedItems.map(p => {
            this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != p.value);
        });

        this.globalSelectedItems.push(...this.selectedItems);
        this.previousSelectedItems = this.selectedItems;
        this.initializeValues();

        let countryString = '';
        this.globalSelectedItems.map(element => {
            countryString += element.value + ';';
        });
        let finalStr = countryString.substring(0, countryString.length - 1);

        if (finalStr) {
            this.template.querySelectorAll('lightning-input').forEach(element => {
                element.setCustomValidity('');
                element.reportValidity();
            });
        }

        const evtCustomEvent = new CustomEvent('retrieve', {
            detail: { finalStr }
        });
        this.dispatchEvent(evtCustomEvent);
    }

    //Cancel button click hides the dialog
    handleCancelClick(event) {
        this.initializeValues();
    }

    initializeValues() {
        this.searchInput = '';
        this.isDialogDisplay = false;
    }

    @api
    validateFields() {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            let pills = this.template.querySelectorAll('lightning-pill');

            if (pills.length > 0) {
                element.setCustomValidity('');
            } else {
                element.setCustomValidity('Select locations.');
            }
            element.reportValidity();
        });
    }

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

}