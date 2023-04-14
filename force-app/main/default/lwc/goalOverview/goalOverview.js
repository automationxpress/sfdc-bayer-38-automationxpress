import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// This class hooks up all the selction and gives them to the data table which handles the data fetching
export default class GoalOverview extends NavigationMixin(LightningElement) {
  selectedYear = "";
  searchInput = "";
  selectedRecordTypes = [];
  selectedStatus = [];
  selectedFlags = [];

  get filterSelected() {
    return (
      this.selectedRecordTypes.length !== 0 ||
      this.selectedStatus.length !== 0 ||
      this.selectedFlags.length !== 0
    );
  }

  handleReset() {
    this.selectedRecordTypes = [];
    this.selectedStatus = [];
    this.selectedFlags = [];
    this.template.querySelector("c-goal-filter-list").reset();
  }

  onYearChange(event) {
    this.selectedYear = event.detail.value;
    event.stopPropagation();
  }

  onInputChange(event) {
    this.searchInput = event.detail.value;
  }

  onRecordTypesChange(event) {
    this.selectedRecordTypes = event.detail.selection;
  }

  onStatusChange(event) {
    this.selectedStatus = event.detail.selection;
  }

  onFlagsChange(event) {
    this.selectedFlags = event.detail.selection;
  }

  // just for navigation
  url;

  connectedCallback() {
    // https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate_basic
    // and https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type
    this.createNewGoalRef = {
      type: "standard__webPage",
      attributes: {
        url: "/flow/GoalSetterNewGoal?retURL=/lightning/n/GsGoalsClassic"
      }
    };
    this[NavigationMixin.GenerateUrl](this.createNewGoalRef).then(
      (url) => (this.url = url)
    );
  }

  handleNewGoal(evt) {
    // Stop the event's default behavior.
    // Stop the event from bubbling up in the DOM.
    evt.preventDefault();
    evt.stopPropagation();
    this[NavigationMixin.Navigate](this.createNewGoalRef);
  }
}