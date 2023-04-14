import { LightningElement, api, track } from 'lwc';
import getJobRoleRecords from '@salesforce/apex/UserEntryEditController.getJobRoleRecords';
import getUserEntryData from '@salesforce/apex/UserEntryEditController.getUserEntryData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class MultiSelectLookup extends LightningElement {

    @api labelName;
    @api objectApiName;
    @api userEntryId;
    @api iconName;
    @api filterCondition;
    @track items = [];
    @track selectedItems = [];
    @track previousSelectedItems = [];
    @track globalSelectedItems = [];
    @track value = [];
    searchInput = '';
    isDialogDisplay = false;
    isDisplayMessage = false;


    connectedCallback() {

        getUserEntryData({ userEntryId: this.userEntryId })
            .then(result => {
                this.setJobRoleData(result.jobRoles);
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    setJobRoleData(jobRoles) {
        this.globalSelectedItems = jobRoles.map(
            row => Object.assign(
                {
                    "value": row.Id,
                    "label": row.Name
                })
        );


    }

    onClickHandle(event) {
        this.searchInput = '';

    }

    retrieveJobRoles() {

        getJobRoleRecords({
            filter: this.filterCondition,
            searchKey: this.searchInput,

        })
            .then(result => {
                this.items = [];
                this.value = [];
                this.previousSelectedItems = [];

                if (result.length > 0) {
                    result.map(resElement => {
                        this.items = [...this.items, {
                            value: resElement.recordId,
                            label: resElement.recordName
                        }];

                        this.globalSelectedItems.map(element => {
                            if (element.value == resElement.recordId) {
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);
                            }
                        });
                    });
                    this.isDialogDisplay = true;
                    this.isDisplayMessage = false;
                }
                else {
                    //display No records found message
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

    onChangeSearchInput(event) {

        this.searchInput = event.target.value;
        //retrieve records based on search input
        getJobRoleRecords({
            objectName: this.objectApiName,
            filter: this.filterCondition,
            searchKey: this.searchInput,

        })
            .then(result => {
                this.items = [];
                this.value = [];
                this.previousSelectedItems = [];

                if (result.length > 0) {
                    result.map(resElement => {
                        this.items = [...this.items, {
                            value: resElement.recordId,
                            label: resElement.recordName
                        }];

                        this.globalSelectedItems.map(element => {
                            if (element.value == resElement.recordId) {
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);
                            }
                        });
                    });
                    this.isDialogDisplay = true;
                    this.isDisplayMessage = false;
                }
                else {
                    //display No records found message
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
        const arrItems = this.globalSelectedItems;

        //initialize values again
        this.initializeValues();
        this.value = [];

        const evtCustomEvent = new CustomEvent('remove', {
            detail: { removeItem, arrItems }
        });
        this.dispatchEvent(evtCustomEvent);
    }

    handleDoneClick(event) {
        this.previousSelectedItems.map(p => {
            this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != p.value);
        });

        this.globalSelectedItems.push(...this.selectedItems);
        const arrItems = this.globalSelectedItems;

        this.previousSelectedItems = this.selectedItems;
        this.initializeValues();

        const evtCustomEvent = new CustomEvent('retrieve', {
            detail: { arrItems }
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

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }



}