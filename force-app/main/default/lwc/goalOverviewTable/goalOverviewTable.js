import { api, LightningElement, wire } from "lwc";
import { reduceErrors } from "c/ldsUtils";
import getGoals from "@salesforce/apex/GoalController.getGoals";

// The column headers displayed in the table
const COLUMNS = ["Program", "Project", "Study", "Goal", "Target"];
// The flag configuration meaning when will this flag be present and which information should be visible next to it
export const flags = [
  {
    label: "Key Goal",
    field: "GsKeyGoal__c"
  },
  {
    label: "CRO Goal",
    field: "GsCroGoal__c"
  },
  {
    label: "Incentive Goal",
    field: "GsLabcorpIncentiveGoal__c"
  },
  {
    label: "Withdrawn",
    field: "GsWithdrawn__c",
    additionalInfo: (goal) => goal.GsWithdrawnComment__c ?? goal.GsComments__c
  },
  {
    label: "Revised",
    field: "GsRevised__c",
    additionalInfo: (goal) => goal.GsComments__c
  }
];
// which colors does one of the status badges have
export const statusColor = {
  "On Track": "on-track-color slds-text-color_inverse",
  Achieved: "slds-theme_success",
  "At Risk": "slds-theme_warning",
  "Not Achieved": "slds-theme_error"
};

export default class GoalOverviewTable extends LightningElement {
  columns = COLUMNS;
  // The search options available as params
  /** @type {number} */
  @api year;
  /** @type {string} */
  @api search;
  /** @type {string[]} */
  @api recordtypes;
  /** @type {string[]} */
  @api flags;
  /** @type {string[]} */
  @api status;

  // getting the goals from the apex controller
  @wire(getGoals, {
    year: "$year",
    searchInput: "$search",
    recordTypes: "$recordtypes",
    status: "$status",
    flags: "$flags"
  })
  goals;

  // this getter returns the dta in a better format for our consumption
  get data() {
    return this.goals.data.map((goal) => ({
      // take all the data
      ...goal,
      // apply classes to omit border if necessary
      sameProgram: goal.GsProgram__c === "" ? "empty" : "",
      sameProject: goal.GsProject__c === "" ? "empty" : "",
      sameStudy: goal.GsStudyNumber__c === "" ? "empty" : "",
      // all the flags done by applying the flags to the data record
      flags: flags.map((f) => ({
        label: f.label,
        visible: goal[f.field],
        additionalInfo: f.additionalInfo ? f.additionalInfo(goal) : false
      })),
      // applying additional data for the status flag
      statusFlag:
        goal.GsStatus__c !== undefined
          ? {
              label: goal.GsStatus__c,
              color: `slds-m-around_xx-small ${
                statusColor[goal.GsStatus__c] ?? ""
              }`,
              additionalInfo:
                goal.GsStatus__c === "Achieved" ? goal.GsAchievedDate__c : false
            }
          : false
    }));
  }

  get errors() {
    if (this.goals.error) {
      return reduceErrors(this.goals.error);
    }
    return [];
  }

  // just getters to correctly identify the current state of the loading operation

  /** @return {boolean} */
  get isLoading() {
    return (
      this.goals === undefined ||
      (this.goals.error === undefined && this.goals.data === undefined)
    );
  }

  /** @return {boolean} */
  get hasFailed() {
    return this.goals !== undefined && this.goals.error !== undefined;
  }

  /** @return {boolean} */
  get hasSucceeded() {
    return this.goals !== undefined && this.goals.data !== undefined;
  }
}