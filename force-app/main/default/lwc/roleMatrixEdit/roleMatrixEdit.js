import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import ROLE_MATRIX_OBJECT from '@salesforce/schema/Role_Matrix__c';
import MYLEARNING_PROGRAM_OBJECT from '@salesforce/schema/MyLearning_Program__c';
import MYLEARNING_PROGRAM_NAME_FIELD from '@salesforce/schema/MyLearning_Program__c.Name';
import PRIMA_ROLE_OBJECT from '@salesforce/schema/Prima_Role__c';
import PRIMA_ROLE_NAME_FIELD from '@salesforce/schema/Prima_Role__c.Name';
import PRIMA_SECURITY_GROUP_OBJECT from '@salesforce/schema/Prima_Security_Group__c';
import PRIMA_SECURITY_GROUP_NAME_FIELD from '@salesforce/schema/Prima_Security_Group__c.Name';
import getRoleMatrixData from '@salesforce/apex/RoleMatrixEditController.getRoleMatrixData';
import saveRoleMatrixData from '@salesforce/apex/RoleMatrixEditController.saveRoleMatrixData';
import Add from '@salesforce/label/c.Add';
import Cancel from '@salesforce/label/c.Cancel';
import Save from '@salesforce/label/c.Save';
import Delete from '@salesforce/label/c.Delete';


export default class RoleMatrixEdit extends LightningElement {
    @api roleMatrixId;
    roleMatrixObjectInfo;
    myLearningProgramObjectInfo;
    primaRoleObjectInfo;
    primaSecurityGroupObjectInfo;
    myLearningProgramColumns;
    primaRoleColumns;
    primaSecurityGroupColumns;
    myLearningProgramData;
    primaRoleData;
    primaSecurityGroupData;
    isMyLearningProgramPopUp = false;
    isPrimaRolePopUp = false;
    isPrimaSecurityGroupPopUp = false;
    isGlobalJobRole = false;
    isRequiredCompany = true;
    isCheckedCompany = false;
    isDisableMAPVDep = false;
    isDisableMAPVGroup = false;
    selectedMyLearningProgramId;
    selectedPrimaRoleId;
    selectedPrimaSecurityGroupId;
    error;
    jobRoleId;
    roleMatrixTypeValue = '';

    label = {
        Add,
        Cancel,
        Save,
        Delete
    };

    @wire(getObjectInfo, { objectApiName: ROLE_MATRIX_OBJECT })
    wireRoleMatrixObjectInfo({ data, error }) {
        if (data) {
            this.roleMatrixObjectInfo = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getObjectInfo, { objectApiName: MYLEARNING_PROGRAM_OBJECT })
    wireMyLearningProgramObjectInfo({ data, error }) {
        if (data) {
            this.myLearningProgramObjectInfo = data;
            this.setMyLearningProgramColumns(this.myLearningProgramObjectInfo.fields);
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getObjectInfo, { objectApiName: PRIMA_ROLE_OBJECT })
    wirePrimaRoleObjectInfo({ data, error }) {
        if (data) {
            this.primaRoleObjectInfo = data;
            this.setPrimaRoleColumns(this.primaRoleObjectInfo.fields);
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getObjectInfo, { objectApiName: PRIMA_SECURITY_GROUP_OBJECT })
    wirePrimaSecurityGroupObjectInfo({ data, error }) {
        if (data) {
            this.primaSecurityGroupObjectInfo = data;
            this.setPrimaSecurityGroupColumns(this.primaSecurityGroupObjectInfo.fields);
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getRecord, { recordId: '$selectedMyLearningProgramId', fields: [MYLEARNING_PROGRAM_NAME_FIELD] })
    wireMyLearningProgram({ data, error }) {
        if (data) {
            this.addMyLearningProgram({ id: this.selectedMyLearningProgramId, name: data.fields.Name.value });
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getRecord, { recordId: '$selectedPrimaRoleId', fields: [PRIMA_ROLE_NAME_FIELD] })
    wirePrimaRole({ data, error }) {
        if (data) {
            this.addPrimaRole({ id: this.selectedPrimaRoleId, name: data.fields.Name.value });
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getRecord, { recordId: '$selectedPrimaSecurityGroupId', fields: [PRIMA_SECURITY_GROUP_NAME_FIELD] })
    wirePrimaSecurityGroup({ data, error }) {
        if (data) {
            this.addPrimaSecurityGroup({ id: this.selectedPrimaSecurityGroupId, name: data.fields.Name.value });
        } else if (error) {
            this.error = error.body.message;
        }
    }

    connectedCallback() {
        getRoleMatrixData({ roleMatrixId: this.roleMatrixId })
            .then(result => {
                this.setMyLearningProgramData(result.myLearningPrograms);
                this.setPrimaRoleData(result.primaRoles);
                this.setPrimaSecurityGroupData(result.primaSecurityGroups);
                this.jobRoleId = result.jobRoleId;
                this.roleMatrixTypeValue = result.roleMatrixType;
                this.disableMAPV();
            }).catch(error => {
                this.showError(error.body.message);
            });
    }

    setMyLearningProgramColumns(myLearningProgramFields) {
        const actions = [
            { label: this.label.Delete, name: 'delete' },
        ];
        this.myLearningProgramColumns = [
            { fieldName: 'name', label: myLearningProgramFields.Name.label, type: 'text' },
            {
                type: 'action',
                typeAttributes: { rowActions: actions },
            }
        ];
    }

    setPrimaRoleColumns(primaRoleFields) {
        const actions = [
            { label: this.label.Delete, name: 'delete' },
        ];
        this.primaRoleColumns = [
            { fieldName: 'name', label: primaRoleFields.Name.label, type: 'text' },
            {
                type: 'action',
                typeAttributes: { rowActions: actions },
            }
        ];
    }

    setPrimaSecurityGroupColumns(primaSecurityGroupFields) {
        const actions = [
            { label: this.label.Delete, name: 'delete' },
        ];
        this.primaSecurityGroupColumns = [
            { fieldName: 'name', label: primaSecurityGroupFields.Name.label, type: 'text' },
            {
                type: 'action',
                typeAttributes: { rowActions: actions },
            }
        ];
    }

    setMyLearningProgramData(myLearningPrograms) {
        this.myLearningProgramData = [];
        myLearningPrograms.forEach(myLearningProgram => {
            this.myLearningProgramData.push({
                id: myLearningProgram.Id,
                name: myLearningProgram.Name
            });
        })
    }

    setPrimaRoleData(primaRoles) {
        this.primaRoleData = [];
        primaRoles.forEach(primaRole => {
            this.primaRoleData.push({
                id: primaRole.Id,
                name: primaRole.Name
            });
        })
    }

    setPrimaSecurityGroupData(primaSecurityGroups) {
        this.primaSecurityGroupData = [];
        primaSecurityGroups.forEach(primaSecurityGroup => {
            this.primaSecurityGroupData.push({
                id: primaSecurityGroup.Id,
                name: primaSecurityGroup.Name
            });
        })
    }

    handleRoleMatrixTypeChange(event) {
        this.roleMatrixTypeValue = event.target.value;
        return this.disableMAPV();
    }

    enableRequired() {
        if (this.isDisableMAPVGroup || this.isDisableMAPVDep) {
            this.isRequiredGroup = false;
        }
        else {
            this.isRequiredGroup = true;
        }
        if (this.isDisableMAPVDep) {
            this.isRequiredDepartment = false;
        }
        else {
            this.isRequiredDepartment = true;
        }
        if (this.isGlobalJobRole) {
            this.isRequiredCompany = false;
        }
        else {
            this.isRequiredCompany = true;
        }
    }

    disableMAPV() {

        if (this.roleMatrixTypeValue == '4-Criteria Role Matrix') {
            this.isDisableMAPVGroup = false;
            this.isDisableMAPVDep = false;
            this.isGlobalJobRole = false;
        }
        if (this.roleMatrixTypeValue == '3-Criteria Role Matrix') {
            this.isDisableMAPVGroup = true;
            this.isDisableMAPVDep = false;
            this.isGlobalJobRole = false;
            this.mapvGroupValue = null;
        }
        if (this.roleMatrixTypeValue == '2-Criteria Role Matrix') {
            this.isDisableMAPVGroup = true;
            this.isDisableMAPVDep = true;
            this.isGlobalJobRole = false;
            this.mapvGroupValue = null;
            this.mapvDepValue = null;
        }
        if (this.roleMatrixTypeValue == 'Global Job role/ Add-On role') {
            this.isDisableMAPVGroup = true;
            this.isDisableMAPVDep = true;
            this.isGlobalJobRole = true;
            this.companyValue = null;
            this.mapvGroupValue = null;
            this.mapvDepValue = null;
        }
        this.enableRequired();
    }

    showMyLearningProgramPopUp() {
        this.isMyLearningProgramPopUp = true;
    }

    showPrimaRolePopUp() {
        this.isPrimaRolePopUp = true;
    }

    showPrimaSecurityGroupPopUp() {
        this.isPrimaSecurityGroupPopUp = true;
    }

    hideMyLearningProgramPopUp() {
        this.isMyLearningProgramPopUp = false;
    }

    hidePrimaRolePopPopUp() {
        this.isPrimaRolePopUp = false;
    }

    hidePrimaSecurityGroupPopUp() {
        this.isPrimaSecurityGroupPopUp = false;
    }

    handleMyLearningProgramSelcted(event) {
        this.selectedMyLearningProgramId = event.detail[0];
        this.hideMyLearningProgramPopUp();
    }

    handlePrimaRoleSelcted(event) {
        this.selectedPrimaRoleId = event.detail[0];
        this.hidePrimaRolePopPopUp();
    }

    handlePrimaSecurityGroupSelcted(event) {
        this.selectedPrimaSecurityGroupId = event.detail[0];
        this.hidePrimaSecurityGroupPopUp();
    }

    handleMyLearningProgramAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.removeMyLearningProgram(row.id);
                break;
            default:
        }
    }

    handlePrimaRoleAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.removePrimaRole(row.id);
                break;
            default:
        }
    }

    handlePrimaSecurityGroupAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.removePrimaSecurityGroup(row.id);
                break;
            default:
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        if (this.isGlobalJobRole) {
            fields.Uma_Company__c = null;
            fields.MAPV_Department__c = null;
            fields.MAPV_Group__c = null;
        }
        if (this.isDisableMAPVDep) {
            fields.MAPV_Department__c = null;
            fields.MAPV_Group__c = null;
        }
        if (this.isDisableMAPVGroup) {
            fields.MAPV_Group__c = null;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleCancel() {
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    handleSucess(event) {
        var myLearningPrograms = [];
        this.myLearningProgramData.forEach(myLearningProgram => {
            myLearningPrograms.push({ Id: myLearningProgram.id });
        });

        var primaRoles = [];
        this.primaRoleData.forEach(primaRole => {
            primaRoles.push({ Id: primaRole.id });
        });

        var primaSecurityGroups = [];
        this.primaSecurityGroupData.forEach(primaSecurityGroup => {
            primaSecurityGroups.push({ Id: primaSecurityGroup.id });
        });

        var roleMatrixData = {
            roleMatrixId: event.detail.id,
            myLearningPrograms: myLearningPrograms,
            primaRoles: primaRoles,
            primaSecurityGroups: primaSecurityGroups
        };

        saveRoleMatrixData({ roleMatrixData: roleMatrixData })
            .then(() => {
                const saveSuccessEvent = new CustomEvent('savesuccess');
                this.dispatchEvent(saveSuccessEvent);
            }).catch(error => {
                this.showError(error.body.message);
            });


    }

    addMyLearningProgram(selectedMyLearningProgram) {
        let temp = [];
        this.myLearningProgramData.forEach(myLearningProgram => {
            temp.push(myLearningProgram);
        })
        temp.push(selectedMyLearningProgram);
        this.myLearningProgramData = temp;
    }

    addPrimaRole(selectedPrimaRole) {
        let temp = [];
        this.primaRoleData.forEach(primaRole => {
            temp.push(primaRole);
        })
        temp.push(selectedPrimaRole);
        this.primaRoleData = temp;
    }

    addPrimaSecurityGroup(selectedPrimaSecurityGroup) {
        let temp = [];
        this.primaSecurityGroupData.forEach(primaSecurityGroup => {
            temp.push(primaSecurityGroup);
        })
        temp.push(selectedPrimaSecurityGroup);
        this.primaSecurityGroupData = temp;
    }

    removeMyLearningProgram(rowId) {
        let temp = [];
        this.myLearningProgramData.forEach(myLearningProgram => {
            if (myLearningProgram.id != rowId) {
                temp.push(myLearningProgram);
            }
        })
        this.myLearningProgramData = temp;
    }

    removePrimaRole(rowId) {
        let temp = [];
        this.primaRoleData.forEach(primaRole => {
            if (primaRole.id != rowId) {
                temp.push(primaRole);
            }
        })
        this.primaRoleData = temp;
    }

    removePrimaSecurityGroup(rowId) {
        let temp = [];
        this.primaSecurityGroupData.forEach(primaSecurityGroup => {
            if (primaSecurityGroup.id != rowId) {
                temp.push(primaSecurityGroup);
            }
        })
        this.primaSecurityGroupData = temp;
    }

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}