import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { wire, LightningElement, api } from "lwc";
import { reduceErrors } from "c/ldsUtils";
import GOAL_OBJECT from "@salesforce/schema/GsGoal__c";
import STATUS_FIELD from "@salesforce/schema/GsGoal__c.GsStatus__c";

// we have to defnie all the things which should not be visible
const excludeTypes = ["Master", "Country Recruitment Goal", "Covance Goal"];
const excludeFlags = [
  "Admin Goal",
  "Covance Goal",
  "Created after freeze",
  "D Goal",
  "Quality Goal",
  "Revised",
  "SharePoint Migrated",
  "Deleted"
];

export default class GoalFilterList extends LightningElement {
  // We fetch the object information about the goal object
  @wire(getObjectInfo, { objectApiName: GOAL_OBJECT })
  getObjectinformation({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.recordTypeId = data.defaultRecordTypeId;
      // all recordTypes will be added if they are not on the exclude list
      this.recordTypeOptions = Object.values(data.recordTypeInfos)
        .filter((d) => !excludeTypes.includes(d.name))
        .map((type) => ({ label: type.name, value: type.recordTypeId }));
      this.recordTypeSelection = [];
      // flags are all boolean properties that are not on the exclusion list
      this.flagOptions = Object.values(data.fields)
        .filter(
          (field) =>
            field.dataType === "Boolean" && !excludeFlags.includes(field.label)
        )
        .map((field) => ({ label: field.label, value: field.apiName }));
      this.flagSelection = [];
    }
  }
  recordTypeId;
  // picklist values are only available on a specifc record type (we use the default one)
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: STATUS_FIELD
  })
  getStatusValues({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.statusOptions = data.values;
      this.statusSelection = [];
    }
  }

  // handle the selections and emit specifcx events
  handleRecordTypeSelection(event) {
    event.stopPropagation();
    const evt = new CustomEvent("recordtypechange", {
      detail: {
        selection: event.detail.value
      }
    });
    this.recordTypeSelection = event.detail.value;
    this.dispatchEvent(evt);
  }
  handleStatusSelection(event) {
    event.stopPropagation();
    const evt = new CustomEvent("statuschange", {
      detail: {
        selection: event.detail.value
      }
    });
    this.statusSelection = event.detail.value;
    this.dispatchEvent(evt);
  }
  handleFlagSelection(event) {
    event.stopPropagation();
    const evt = new CustomEvent("flagchange", {
      detail: {
        selection: event.detail.value
      }
    });
    this.flagSelection = event.detail.value;
    this.dispatchEvent(evt);
  }

  // when the reset button is clicked on the selection block revert the local selction
  @api reset() {
    this.recordTypeSelection = [];
    this.statusSelection = [];
    this.flagSelection = [];
  }

  error;

  recordTypeOptions;
  recordTypeSelection;

  statusOptions;
  statusSelection;

  flagOptions;
  flagSelection;

  get errors() {
    if (this.error) {
      return reduceErrors(this.error);
    }
    return [];
  }

  // jsut a helper that the template shows the correct loading state
  /** @return {boolean} */
  get isLoading() {
    return (
      this.recordTypeSelection === undefined &&
      this.statusSelection === undefined &&
      this.flagSelection === undefined &&
      this.error === undefined
    );
  }

  /** @return {boolean} */
  get hasFailed() {
    return this.error !== undefined;
  }

  /** @return {boolean} */
  get hasSucceeded() {
    return (
      this.recordTypeSelection !== undefined &&
      this.statusSelection !== undefined &&
      this.flagSelection !== undefined
    );
  }
}