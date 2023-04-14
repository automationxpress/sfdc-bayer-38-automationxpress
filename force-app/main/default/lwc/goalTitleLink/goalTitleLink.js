import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// This compoment takes a record id and renders a correct lnk to this goal record
// It injects an event handler which leads to js driven navigation int he brwoser
// check the links below how this is done
export default class GoalTitleLink extends NavigationMixin(LightningElement) {
  @api recordId;

  url;

  connectedCallback() {
    // https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate_basic
    // and https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type
    this.goalRecodPageRef = {
      type: "standard__recordPage",
      attributes: {
        objectApiName: "GsGoal__c",
        actionName: "view",
        recordId: this.recordId
      }
    };
    this[NavigationMixin.GenerateUrl](this.goalRecodPageRef).then(
      (url) => (this.url = url)
    );
  }

  handleClick(evt) {
    // Stop the event's default behavior.
    // Stop the event from bubbling up in the DOM.
    evt.preventDefault();
    evt.stopPropagation();
    this[NavigationMixin.Navigate](this.goalRecodPageRef);
  }
}