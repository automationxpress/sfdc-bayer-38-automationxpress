import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getFilteredRoleMatrixDetails from '@salesforce/apex/RoleMatrixController.getFilteredRoleMatrixDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import ROLE_MATRIX_OBJECT from '@salesforce/schema/Role_Matrix__c';
import Delete from '@salesforce/label/c.Delete';
import AreYouSureYouWantToDeleteThis from '@salesforce/label/c.AreYouSureYouWantToDeleteThis';
import Search from '@salesforce/label/c.Search';
import Next from '@salesforce/label/c.Next';
import Previous from '@salesforce/label/c.Previous';
import Create_New_Role_Matrix from '@salesforce/label/c.Create_New_Role_Matrix';

export default class RoleMatrixDisplay extends LightningElement {

    @track roleMatrixData = [];
    @track items = [];
    @track columns;
    roleMatrixObjectInfo;
    wiredRoleMatrixList = [];
    error;
    searchValue='';
    currentValue=''
    page = 1;
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
    totalRecountCount = 0;
    totalPage = 0;
    selectedRoleMatrixId;
    isRoleMatrixEditPopUp = false;
    isRoleMatrixDeletePopUp = false;
    roleMatrixDeleteTitle;
    roleMatrixDeleteMessage;
    isCreateable = false;

    label = {
        Delete,
        AreYouSureYouWantToDeleteThis,
        Search,
        Next,
        Previous,
        Create_New_Role_Matrix
    };

    inputData = [];

    @wire(getObjectInfo, { objectApiName: ROLE_MATRIX_OBJECT })
    wireRoleMatrixObjectInfo({ data, error }) {
        if (data) {
            this.roleMatrixObjectInfo = data;
            this.isCreateable = data.createable;
            this.roleMatrixDeleteTitle = this.label.Delete + " " + this.roleMatrixObjectInfo.label;
            this.roleMatrixDeleteMessage = this.label.AreYouSureYouWantToDeleteThis + " " + this.roleMatrixObjectInfo.label + "?";
            this.setRoleMatrxColumns();
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getFilteredRoleMatrixDetails,{searchKey:'$currentValue'})
    roleMatrixDetails(result) {
        this.wiredRoleMatrixList = result;
        if (result.data) {
            this.error = undefined;
            this.dataWrap(result.data);
            this.page=1;
        }
        else if (result.error) {
            this.error = result.error;
            this.roleMatrixData = undefined;
        }
    }

    dataWrap(inputPara) {
        this.totalRecountCount = inputPara.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.endingRecord = this.pageSize;
        this.items = inputPara.map(
            row => Object.assign(
                {
                    "Id": row.roleMatrixRecord.Id,
                    "Job_Role__r.Name": row.roleMatrixRecord.Job_Role__r?.Name,
                    "MAPV_Department__r.Name": row.roleMatrixRecord.MAPV_Department__r?.Name,
                    "MAPV_Group__r.Name": row.roleMatrixRecord.MAPV_Group__r?.Name,
                    "Uma_Company__c":row.roleMatrixRecord.Uma_Company__c,
                    "Comments__c": row.roleMatrixRecord.Comments__c,
                    "Main_Role_Add_on_Formula__c": row.roleMatrixRecord.Main_Role_Add_on_Formula__c,
                    "Role_Matrix_MyLearning_Programs__r": row.myLearningString,
                    "Role_Matrix_Prima_Role__r": row.primaRoleString,
                    "Role_Matrix_Prima_SG__r": row.primaSecurityGroupString,
                }, row)
        );
        refreshApex(this.wiredRoleMatrixList);
        this.roleMatrixData = this.items.slice(0, this.pageSize);
    }

    searchKeyword(event) {
        this.searchValue = event.target.value;
        
    }

    handleSearchClick(event) {
        this.currentValue=this.searchValue;
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.roleMatrixData = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

    handelCreateNewRoleMatrix() {
        this.selectedRoleMatrixId = null;
        this.showRoleMatrixEditPopUp();
    }

    handleRowActions(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.selectedRoleMatrixId = row.Id;
                this.showRoleMatrixEditPopUp();
                
                break;
            case 'delete':
                this.selectedRoleMatrixId = row.Id;
                this.showRoleMatrixDeletePopUp();
                break;
            default:
        }
    }

    handleRoleMatrixSave() {
        refreshApex(this.wiredRoleMatrixList);
        this.hideRoleMatrixEditPopUp();
    }

    handleRoleMatrixDelete() {
        deleteRecord(this.selectedRoleMatrixId)
            .then(() => {
                this.hideRoleMatrixDeletePopUp();
                refreshApex(this.wiredRoleMatrixList);
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    showRoleMatrixEditPopUp() {
        this.isRoleMatrixEditPopUp = true;
    }

    showRoleMatrixDeletePopUp() {
        this.isRoleMatrixDeletePopUp = true;
    }

    hideRoleMatrixEditPopUp() {
        this.isRoleMatrixEditPopUp = false;
    }

    hideRoleMatrixDeletePopUp() {
        this.isRoleMatrixDeletePopUp = false;
    }

    setRoleMatrxColumns() {
        this.columns = [
            { label: 'Job Role', fieldName: 'Job_Role__r.Name', type: 'text', wrapText: true },
            { label: 'MAPV Department', fieldName: 'MAPV_Department__r.Name', type: 'text', wrapText: true },
            { label: 'MAPV Group', fieldName: 'MAPV_Group__r.Name', type: 'text', wrapText: true },
            { label: 'Main Role/Add-on', fieldName: 'Main_Role_Add_on_Formula__c', type: 'text' },
            { label: 'Company', fieldName: 'Uma_Company__c', type: 'text', fixedWidth: 110 },
            { label: 'MyLearning Program', fieldName: 'Role_Matrix_MyLearning_Programs__r', type: 'text', wrapText: true },
            { label: 'PRIMA Roles', fieldName: 'Role_Matrix_Prima_Role__r', type: 'text', wrapText: true, initialWidth: 250 },
            { label: 'PRIMA Security Groups', fieldName: 'Role_Matrix_Prima_SG__r', type: 'text', wrapText: true, initialWidth: 250},
            { label: 'Comments', fieldName: 'Comments__c', type: 'text', wrapText: false },
        ];

        const actions = [];
        if (this.roleMatrixObjectInfo.updateable) {
            actions.push({ label: 'Edit', name: 'edit' });
        }
        if (this.roleMatrixObjectInfo.deletable) {
            actions.push({ label: 'Delete', name: 'delete' });
        }
        if (actions.length > 0) {
            this.columns.push({
                type: 'action',
                typeAttributes: { rowActions: actions, menuAlignment: 'right' }
            });
        }
    }
}