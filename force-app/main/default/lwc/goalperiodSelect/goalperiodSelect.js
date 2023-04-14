import { wire, LightningElement } from "lwc";
import { reduceErrors } from "c/ldsUtils";
import getGoalPeriods from "@salesforce/apex/GoalController.getGoalPeriods";

// This renders a selection of all available goalperiods
export default class GoalperiodSelect extends LightningElement {
  // the value of the selection
  value;

  // this fetches all of the goal periods from the server and calls the function
  @wire(getGoalPeriods) getPeriods({ error, data }) {
    // we encountered and render them
    if (error) {
      this.errors = reduceErrors(error);
    } else if (data) {
      // we get the current year
      const year = new Date().getFullYear();
      // this is okay as we know we have to compare a number and a string to get the current goal period
      // eslint-disable-next-line eqeqeq
      const val = data.find((p) => p.Name == year)?.Id;
      // if the current year has a goal period we set the value and dispatch an event upwards as it "changed"
      if (val) {
        this.value = val;
        const evt = new CustomEvent("change", {
          detail: { value: this.value }
        });
        this.dispatchEvent(evt);
      }
      // we map the data to be displayable
      this.data = data.map((p) => ({ label: p.Name, value: p.Id }));
    }
  }
  // any errors we might encounter while fetching the data
  errors;
  // the data we actually got
  data;

  // on change we only set the value for our rendering
  // the event bubbling handles the rest
  onChange(event) {
    this.value = event.detail.value;
  }

  // Those getters are in place so the template renders the correct state based on the data fetching
  /** @return {boolean} */
  get isLoading() {
    return this.errors === undefined && this.data === undefined;
  }

  /** @return {boolean} */
  get hasFailed() {
    return this.errors !== undefined;
  }

  /** @return {boolean} */
  get hasSucceeded() {
    return this.data !== undefined;
  }
}