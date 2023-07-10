import { LightningElement, wire } from 'lwc';
import Search from '@salesforce/label/c.Search';
import getUserEntryDetails from '@salesforce/apex/UMAHomePageController.getUserEntryDetails';
import getFilteredUserEntryDetails from '@salesforce/apex/UMAHomePageController.getFilteredUserEntryDetails';
import { refreshApex } from '@salesforce/apex';

const inputColumns = [
        { label: 'User Entry Name', fieldName: 'Name', sortable: "true"},
        { label: 'CWID', fieldName: 'CWID__c', sortable: "true"},
        { label: 'Email', fieldName: 'Email__c', sortable: "true" },
        { label: 'Company', fieldName: 'Uma_Company__c', sortable: "true" },
        { label: 'Primary Job Role', fieldName: 'Primary_Job_Role__r.Name', sortable: "true"},
        { label: 'Locations', fieldName: 'Locations__c', sortable: "true" },
        { label: 'MAPV Department', fieldName: 'MAPV_Department__r.Name', sortable: "true"},
        { label: 'MAPV Group', fieldName: 'MAPV_Group__r.Name', sortable: "true" },
        { label: 'Resource Manager (R Line)', fieldName: 'Resource_Manager__r.Name', sortable: "true" }
    ];

export default class UmaHomePage extends LightningElement {

    label = {
        Search
    };
    userEntryData;
    searchValue='';
    sortBy='';
    sortDirection='';
    inputData;
    items = [];
    page = 1;
    startingRecord = 1;
    endingRecord = 0; 
    pageSize = 50; 
    totalRecountCount = 0;
    totalPage = 0;
    columns;
    disabledNext;
    disabledPrevious;

    

    @wire (getUserEntryDetails)
    userEntryDetails(result){
        this.inputData = result;
        if (result.data) {
            this.dataWrap(result.data);

            this.error = undefined;
           
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    dataWrap(inputPara) {
        this.totalRecountCount = inputPara.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.endingRecord = this.pageSize;
        this.items = inputPara.map(
            row => Object.assign(
                {
                    "Id": row.Id,
                    "CWID__c": row.CWID__c,
                    "Email__c": row.Email__c,
                    "Uma_Company__c": row.Uma_Company__c,
                    "Primary_Job_Role__r.Name": row.Primary_Job_Role__r?.Name,
                    "Locations__c": row.Locations__c,
                    "MAPV_Department__r.Name": row.MAPV_Department__r?.Name,
                    "MAPV_Group__r.Name": row.MAPV_Group__r?.Name,
                    "Resource_Manager__r.Name": row.Resource_Manager__r?.Name,
                    
                    
                }, row)
        );
        this.columns = inputColumns;
        this.userEntryData = this.items.slice(0, this.pageSize);
        
        this.disabledPaginationButtons();
        

    }

    searchKeyword(event) {
        this.searchValue = event.target.value;
    }

    handleSearchClick() {

        getFilteredUserEntryDetails({ searchKey: this.searchValue, sortDirection: this.sortDirection, sortBy: this.sortBy })
            .then(result => {
                
                this.inputData = result;
                this.page = 1;
                this.dataWrap(result);
                

            })
            .catch(error => {
                const eve = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(eve);
            });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        //refreshApex(this.inputData);
        //if(this.searchValue!='')
        this.handleSearchClick();
        this.page = 1;   
        

        this.disabledPaginationButtons();  
        
        
    }
    
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
        this.disabledPaginationButtons();
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
        this.disabledPaginationButtons();

        
    }

    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.userEntryData = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

    disabledPaginationButtons(){
        if(this.page==1)
           this.disabledPrevious=true;
        else
            this.disabledPrevious=false;
        if(this.page==this.totalPage)
            this.disabledNext=true;
        else
            this.disabledNext=false;
    }

}