# SFDC Bayer38 Pharma EMEA
This is the source tracking repo of the Salesforce implementation, for the Bayer38 Org, for the EMEA region of Pharma, created under the LowCode-NoCode initiative.

# Applications

In this org there are these main different applications created for different teams:

- UMA(User Access Management)
- GS(Goal Setter)

# Sandbox Refresh Process

The 'homework' below covers the necessary steps to follow when refreshing a higher sandbox as new.

## Manual Steps

* Remove `.invalid` on all key stakeholders for the respective sandbox: could be developers, release managers, or product owners.

* Set up the Auth Providers manually in the respective orgs.

  * Tracking them in the repository makes deployments problematic because they have to be `Executed As` a specific user, and the username
  across different orgs is inevitably going to be different.

* Enable Deliverability of All Emails in Setup:

  * Setup > Email > Deliverability > `All Email`

* Update the SFDX_<ORG-NAME>_URL secret variable in the Github Repo Secrets:

  * Step 1: generate locally on your VSCode the SFDX Url containing the secrets, according to the [docs](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_auth_sfdxurl.htm):
    `sf org display --target-org <ORG_ALIAS> --verbose --json > authFile.json`
  * Step 2: Copy the generated SFDX Url, from the automatically created file `authFile.json`, under the parameter `sfdxAuthUrl`.
  * Step 3: Replace in Github the value of the repo secret named `SFDX_<ORG_NAME>_URL`, under Settings > Secrets and Variables > Actions.

# Excluded Components

In order to mitigate some deployment issues, some components have been excluded by the automated deployment:

## Auth. Providers

* This type of metadata is to be added manually to each Sandbox, because deploying it via the metadata API, will result in an error, due to the wrong reference
  of the user configured in `Execute As`.

## Custom Object

* Voice Call(`VoiceCall`)
  * Error caused: `Invalid fullName, must end in a custom suffix (e.g. __c)`

## List Views

_All of them - as they change often and don't add any value._

## Queue-s(Groups)

* GsFeedback
* GsUserRequests

  Error caused: `Cannot find a user that matches any of the following usernames: .... remove the user from the component being deployed or create a matching user in the destination organization.`

## Page Layout

_All of them - as some of them were causing some weird issues._

Example:

* Case-Case Layout: `Invalid field:SOLUTION.ISSUE in related list:RelatedSolutionList`

## Apps

* standard__LightningInstrumentation: `Cannot create a new component with the namespace: standard. Only components in the same namespace as the organization can be created through the API`
* standard__Optimizer: `Cannot create a new component with the namespace: standard. Only components in the same namespace as the organization can be created through the API`

* GsGoalSetter: `In field: utilityBar - no FlexiPage named GoalSetter_UtilityBar found`

# Flows

_All of them - as some of them were causing some weird issues._

Example:

* GoalSetterNewGoal: `currentItem_FilterMatchingStudy (Variable) - "apexClass" is invalid. Provide the API name of an Apex class that includes an Apex data type supported in flows.`
* GoalSetter_Get_Impact_Studies: `ImpactPersonList (Variable) - "apexClass" is invalid. Provide the API name of an Apex class that includes an Apex data type supported in flows.`
* GetImpactStudiesOccupationcode: `EntityList (Variable) - "apexClass" is invalid. Provide the API name of an Apex class that includes an Apex data type supported in flows.`

# Custom Object Translations

_All of them for now - temporarily._

# Quick Actions

_All of them for now - temporarily._
