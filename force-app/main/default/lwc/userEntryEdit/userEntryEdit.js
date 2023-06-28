import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveUserEntryData from '@salesforce/apex/UserEntryEditController.saveUserEntryData';
import getUserEntryData from '@salesforce/apex/UserEntryEditController.getUserEntryData';
import refreshRoleMatricesData from '@salesforce/apex/UserEntryEditController.refreshRoleMatricesData';
import submitForApproval from '@salesforce/apex/UserEntryEditController.submitForApproval';
import getResourceManager from '@salesforce/apex/AzureActiveDirectoryService.getResourceManager';
import USER_ENTRY_OBJECT from '@salesforce/schema/User_Entry__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UserEntryIsLockedForEditing from '@salesforce/label/c.UserEntryIsLockedForEditing';
import Cancel from '@salesforce/label/c.Cancel';
import Save from '@salesforce/label/c.Save';
import Add from '@salesforce/label/c.Add';
import Delete from '@salesforce/label/c.Delete';
import Save_and_Submit_for_Approval from '@salesforce/label/c.Save_and_Submit_for_Approval';
import WarningMsg_Time_Tracking_Required from '@salesforce/label/c.WarningMsg_Time_Tracking_Required';



const myLearningProgramColumns = [

    { fieldName: 'name', label: 'Name', type: 'text' },
    {
        label: 'Status',
        initialWidth: 100,
        type: 'customIcon',
        typeAttributes: {
            iconName: { fieldName: 'iconName' },
            title: { fieldName: 'iconTitle' },
            variant: { fieldName: 'iconVariant' }
        }
    }
];
const primaRoleColumns = [

    { fieldName: 'name', label: 'Name', type: 'text' },
    {
        label: 'Status',
        initialWidth: 100,
        type: 'customIcon',
        typeAttributes: {
            iconName: { fieldName: 'iconName' },
            title: { fieldName: 'iconTitle' },
            variant: { fieldName: 'iconVariant' }
        }
    }
];
const primaSecurityGroupColumns = [

    { fieldName: 'name', label: 'Name', type: 'text' },
    {
        label: 'Status',
        initialWidth: 100,
        type: 'customIcon',
        typeAttributes: {
            iconName: { fieldName: 'iconName' },
            title: { fieldName: 'iconTitle' },
            variant: { fieldName: 'iconVariant' }
        }
    }
];

export default class UserEntryEdit extends LightningElement {
    label = {
        UserEntryIsLockedForEditing,
        Cancel,
        Save,
        Add,
        Delete,
        Save_and_Submit_for_Approval,
        WarningMsg_Time_Tracking_Required,

    };

    @api userEntryId;

    userEntryObjectInfo;
    myLearningProgramColumns = myLearningProgramColumns;
    primaRoleColumns = primaRoleColumns;
    primaSecurityGroupColumns = primaSecurityGroupColumns;
    myLearningProgramData = [];
    primaRoleData = [];
    primaSecurityGroupData = [];
    jobRoleData;
    isStaffStatusLeft = false;
    isStaffStatusLongTermLeave = false;
    isLocked = false;
    firstName;
    lastName;
    email;
    cwid;
    primaryJobRole;
    primaryJobRoleValue;
    selectedMAPVDepartmentId;
    selectedMAPVGroupId;
    selectedUmaCompany;
    selectedLocations;
    resourceManagerId;
    submittedForApproval = false;
    runApprovalProcess;
    approvalStatus;
    savingStatus;
    showSavingStatus = false;
    grantAccessToUma;
    timeTrackingRequired;
    workingHours;
    isGrantAccessToUmaDisabled;
    showWarningMsg;
    isNew = true;
    

    @wire(getObjectInfo, { objectApiName: USER_ENTRY_OBJECT })
    wireUserEntryObjectInfo({ data, error }) {
        if (data) {
            this.userEntryObjectInfo = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }


    connectedCallback() {
        if(this.userEntryId!='' && this.userEntryId!=null){
            this.isNew = false;
        }
        getUserEntryData({ userEntryId: this.userEntryId })
            .then(result => {
                this.isLocked = result.isLocked;
                this.isStaffStatusLeft = result.isStaffStatusLeft;
                this.isStaffStatusLongTermLeave = result.isStaffStatusLongTermLeave;
                this.isGrantAccessToUmaDisabled = result.isStaffStatusCurrent == false;
                this.setJobRoleData(result.jobRoles);
                this.primaryJobRoleValue = result.primaryJobRole;
                this.primaryJobRole = result.primaryJobRoleId;
                this.selectedMAPVDepartmentId = result.MAPVDepartment;
                this.selectedMAPVGroupId = result.MAPVGroup;
                this.selectedUmaCompany=result.umaCompany;
                this.approvalStatus = result.approvalStatus;
                this.selectedLocations = result.locations;
                this.timeTrackingRequired = result.timeTrackingRequired;
                this.workingHours = result.workingHours;
                if (this.approvalStatus == 'Pending for Approval') {
                    this.submittedForApproval = true;
                }

                this.setMyLearningProgramData(result.myLearningPrograms);
                this.setPrimaRoleData(result.primaRoles);
                this.setPrimaSecurityGroupData(result.primaSecurityGroups);

            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    getRoleMatrixData() {
        if (this.selectedMAPVDepartmentId != null && this.selectedMAPVGroupId != null && this.selectedUmaCompany != null && this.isStaffStatusLeft != null && this.isStaffStatusLongTermLeave != null && this.primaryJobRole != null) {
            var userEntryDetails = {
                userEntryId: this.userEntryId,
                isStaffStatusLeft: this.isStaffStatusLeft,
                isStaffStatusLongTermLeave: this.isStaffStatusLongTermLeave,
                MAPVDepartment: this.selectedMAPVDepartmentId,
                MAPVGroup: this.selectedMAPVGroupId,
                umaCompany: this.selectedUmaCompany,
                primaryJobRoleId: this.primaryJobRole,
                jobRoles: this.jobRoleData,
                timeTrackingRequired: this.timeTrackingRequired,
                workingHours: this.workingHours
            };
            refreshRoleMatricesData({ userEntryDetails: userEntryDetails })
                .then(result => {
                    this.setMyLearningProgramData(result.myLearningPrograms);
                    this.setPrimaRoleData(result.primaRoles);
                    this.setPrimaSecurityGroupData(result.primaSecurityGroups);
                }).catch(error => {
                    this.showError(error.body.message);
                });
        }


    }

    setJobRoleData(jobRoles) {

        this.jobRoleData = [];
        jobRoles.forEach(jobRole => {
            this.jobRoleData.push({
                Id: jobRole.Id,
                name: jobRole.Name
            });
        })
    }

    setMyLearningProgramData(myLearningPrograms) {
        this.myLearningProgramData = [];
        myLearningPrograms.forEach(myLearningProgram => {
            this.myLearningProgramData.push(myLearningProgram);
        })
    }

    setPrimaRoleData(primaRoles) {
        this.primaRoleData = [];
        primaRoles.forEach(primaRole => {
            this.primaRoleData.push(primaRole);
        })
    }

    setPrimaSecurityGroupData(primaSecurityGroups) {
        this.primaSecurityGroupData = [];
        primaSecurityGroups.forEach(primaSecurityGroup => {
            this.primaSecurityGroupData.push(primaSecurityGroup);
        });
    }

    handleStaffStatusChanged(event) {
        this.isStaffStatusLeft = event.detail.value == 'Current' ? false : true;//
        this.isStaffStatusLongTermLeave = event.detail.value == 'Long-Term Leave' ? true : false;
        this.setGrantAccessToUma(event.detail.value);
        this.getRoleMatrixData();
    }

    setGrantAccessToUma(status){
        if(status == 'Current'){
            this.isGrantAccessToUmaDisabled = false;
        } else {
            this.grantAccessToUma = 'No';
            this.isGrantAccessToUmaDisabled = true;
        }
    }

    handleUserSelected(event) {
        this.firstName = event.detail.firstName;
        this.lastName = event.detail.lastName;
        this.email = event.detail.email;
        this.cwid = event.detail.cwid;

        getResourceManager({ userPrincipalName: event.detail.userPrincipalName })
            .then(result => {
                this.resourceManagerId = result;
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    handleJobRoleAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.removeJobRole(row.id);
                break;
            default:
        }
    }


    removeJobRole(rowId) {
        let temp = [];
        this.jobRoleData.forEach(jobRole => {
            if (jobRole.id != rowId) {
                temp.push(jobRole);
            }
        })
        this.jobRoleData = temp;
    }


    handleCancel(event) {
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.populateFields(fields);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSave(event) {
        this.showSavingStatus = true;
        this.savingStatus = "Saving...";
        this.validateFields();
        this.runApprovalProcess = false;
        
    }

    handleSaveAndSubmitForApproval(event) {
        this.showSavingStatus = true;
        this.savingStatus = "Saving...";
        this.validateFields();
        this.runApprovalProcess = true;
    }

    populateFields(fields) {
        fields.Primary_Job_Role__c = this.primaryJobRole;
        fields.MAPV_Department__c = this.selectedMAPVDepartmentId;
        fields.MAPV_Group__c = this.selectedMAPVGroupId;
        fields.Uma_Company__c=this.selectedUmaCompany;
        fields.Locations__c = this.selectedLocations;
    }

    validateFields() {
        this.template.querySelectorAll('c-single-select-lookup').forEach(element => {
            element.validateFields();
        });
        this.template.querySelectorAll('c-user-entry-searchable-picklist').forEach(element => {
            element.validateFields();
        });
        this.template.querySelectorAll('c-multi-select-picklist').forEach(element => {
            element.validateFields();
        });
    }

    handleSuccess(event) {
        
        this.userEntryId = event.detail.id;
        var jobRoles = [];
        this.jobRoleData.forEach(jobRole => {
            jobRoles.push({ Id: jobRole.Id });
        });

        var userEntryData = {
            userEntryId: event.detail.id,
            isStaffStatusLeft: this.isStaffStatusLeft,
            isStaffStatusLongTermLeave: this.isStaffStatusLongTermLeave,
            jobRoles: jobRoles,
            primaryJobRole: this.primaryJobRole,
            locations: this.selectedLocations,

            myLearningPrograms: this.myLearningProgramData,
            primaRoles: this.primaRoleData,
            primaSecurityGroups: this.primaSecurityGroupData

        };

        saveUserEntryData({ userEntryData: userEntryData })
            .then(() => {
                if (this.runApprovalProcess) {
                    this.submitForApproval();
                }
                const saveSuccessEvent = new CustomEvent('savesuccess', {
                    detail: { recordId: this.userEntryId }
                });
                this.dispatchEvent(saveSuccessEvent);
                this.savingStatus = "Saved.";
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    submitForApproval() {
        submitForApproval({ recordId: this.userEntryId })
            .then(result => {
                this.showToastMessage('User Entry Submitted Successfully for Approval!');
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    handleErrors(event) {
        this.showSavingStatus = false;
    }

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    showToastMessage(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'Success'
        });
        this.dispatchEvent(evt);
    }

    handleMultiSelectLookupRetrieve(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.jobRoleData = args.map(
            row => Object.assign(
                {
                    "Id": row.value,
                    "name": row.label
                })
        );
        this.combinedJobRole();
        this.getRoleMatrixData();
    }


    handleMultiSelectLookupRemove(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));

        this.jobRoleData = args.map(
            row => Object.assign(
                {
                    "Id": row.value,
                    "name": row.label
                })
        );
        this.combinedJobRole();
        this.getRoleMatrixData();
    }

    handleMultiSelectPicklistRetrieve(event) {
        this.selectedLocations = JSON.parse(JSON.stringify(event.detail.finalStr));

    }

    handleMultiSelectPicklistRemove(event) {
        this.selectedLocations = JSON.parse(JSON.stringify(event.detail.finalStr));

    }

    singleSelectEventHandler(event) {
        this.primaryJobRole = event.detail.selectedRecordId;
        this.primaryJobRoleValue = event.detail.selectedValue;
        if(this.primaryJobRole!= null){
            this.showWarningMsg = true;
        }
        this.combinedJobRole();
        this.getRoleMatrixData();


    }

    combinedJobRole() {
        var jobRoles = [];
        this.jobRoleData.forEach(jobRole => {
            jobRoles.push({
                Id: jobRole.Id,
                Value: jobRole.name
            })
        });
        jobRoles.push({
            Id: this.primaryJobRole,
            Value: this.primaryJobRoleValue
        });
    }
    handleCompanyChange(event){
        this.selectedUmaCompany=event.target.value;
        this.getRoleMatrixData();
    }
    handleRecordSelected(event) {
        this.updateRecordSelections(event);
        this.showWarningMsg=true;
    }

    handleRecordRemoved(event) {
        this.updateRecordSelections(event);
    }

    handleResourceManagerChange(event){
        if(event.target.value !=''){
            this.showWarningMsg=true;
        }
    }

    handleCWIDChange(){
        this.showWarningMsg=true;
    }

    handleWorkingHoursChange(){
        this.showWarningMsg=true;
    }

    handleCostCenterChange(){
        this.showWarningMsg=true;
    }

    updateRecordSelections(event) {
        let objectName = event.detail.objectName;
        let selectedId = event.detail.selectedId;

        if (objectName == "MAPV_Department__c") {
            this.selectedMAPVDepartmentId = selectedId;
            if (this.selectedMAPVDepartmentId) {
                this.getRoleMatrixData();
            }
        } else if (objectName == "MAPV_Group__c") {
            this.selectedMAPVGroupId = selectedId;
            if (this.selectedMAPVGroupId) {
                this.getRoleMatrixData();
            }
        }
    }
}