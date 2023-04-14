import { LightningElement, wire, api } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { reduceErrors } from "c/ldsUtils";

export default class PicklistValuesByRecordType extends LightningElement {
  @api fieldApiName;
  @api fieldLabel;
  @api objApiName;
  @api recTypeId;
  @api selectedValue;
  @api isRequired = false;
  @api placeholder = "--None--";

  //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_wire_adapters_picklist_values_record
  @wire(getPicklistValuesByRecordType, {
    objectApiName: "$objApiName",
    recordTypeId: "$recTypeId"
  })
  picklistValues;

  get errors() {
    return reduceErrors(this.picklistValues.error);
  }

  get options() {
    if (this.picklistValues.data) {
      return this.picklistValues.data.picklistFieldValues[this.fieldApiName]
        .values;
    }
    return [];
  }

  handleChange(event) {
    //https://developer.salesforce.com/docs/component-library/bundle/lightning-flow-support/documentation
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "selectedValue",
      event.detail.value === "" ? undefined : event.detail.value
    );
    this.dispatchEvent(attributeChangeEvent);
  }

  //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_flow_validate_user_input_for_custom_components
  @api validate() {
    if (this.isRequired === false) {
      return { isValid: true };
    }
    if (this.selectedValue !== undefined) {
      return { isValid: true };
    }
    return {
      isValid: false,
      errorMessage: "Please select a picklist value"
    };
  }

  /** @return {boolean} */
  get isLoading() {
    return (
      this.picklistValues.error === undefined &&
      this.picklistValues.data === undefined
    );
  }

  /** @return {boolean} */
  get hasFailed() {
    return this.picklistValues.error !== undefined;
  }

  /** @return {boolean} */
  get hasSucceeded() {
    return this.picklistValues.data !== undefined;
  }
}