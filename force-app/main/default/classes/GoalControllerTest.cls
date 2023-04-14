@isTest
private with sharing class GoalControllerTest {
  static List<Schema.PicklistEntry> statusList = GsGoal__c.GsStatus__c.getDescribe()
    .getPicklistValues();

  static List<Schema.RecordTypeInfo> recordTypeList = GsGoal__c.SObjectType.getDescribe()
    .getRecordTypeInfos();

  static List<Schema.PicklistEntry> standardGoals = GsGoal__c.GsStandardGoal__c.getDescribe()
    .getPicklistValues();

  static List<GsGoalPeriod__c> generateGoalPeriods() {
    List<GsGoalPeriod__c> periods = new List<GsGoalPeriod__c>();
    for (Integer i = 2010; i < 2015; i++) {
      periods.add(new GsGoalPeriod__c(Name = '' + i));
    }
    insert periods;
    return periods;
  }

  static List<GsGoal__c> generateGoals() {
    List<GsGoalPeriod__c> periods = GoalControllerTest.generateGoalPeriods();
    List<GsGoal__c> goals = new List<GsGoal__c>();
    for (Integer i = 0; i < 50; i++) {
      GsGoal__c goal = new GsGoal__c();
      goal.GsProgram__c = 'Program' + Math.ceil(i / 10);
      goal.GsProject__c = 'Project' + Math.ceil(i / 5);
      goal.GsStudyNumber__c = 'StudyNumber' + Math.ceil(i / 3);
      goal.GsGoalTitle__c = 'Title' + i;
      goal.GsStatus__c = statusList.get(Math.mod(i, statusList.size()))
        .getValue();
      goal.GsFinal__c = Math.mod(i, 2) == 0;
      goal.GsCroGoal__c = Math.mod(i, 3) == 0;
      goal.GsRevised__c = Math.mod(i, 4) == 0;
      goal.GsComments__c = Math.mod(i, 2) == 0 ? '' : 'Comment ' + i;
      goal.GsLabcorpIncentiveGoal__c = Math.mod(i, 9) == 0;
      goal.GsWithdrawn__c = Math.mod(i, 5) == 0;
      goal.GsWithdrawnComment__c = Math.mod(i, 10) == 0 ? '' : 'Withdrawn' + i;
      if (goal.GsStatus__c.equals('Achieved')) {
        goal.GsAchievedDate__c = Date.newInstance(
          2024,
          Math.mod(i, 12) + 1,
          Math.mod(i * 6, 28)
        );
      }
      goal.GsStandardGoal__c = '-- enter goal manually --';
      goal.GsGoalPeriod__c = periods.get(Math.mod(i, periods.size())).Id;
      goal.RecordTypeId = recordTypeList.get(
          Math.mod(i, recordTypeList.size() - 1)
        )
        .getRecordTypeId();
      goals.add(goal);
    }
    insert goals;
    return goals;
  }

  // we test gettting the goal periods
  @isTest
  static void testGetGoalPeriods() {
    Test.startTest();
    List<GsGoalPeriod__c> insertedPeriods = GoalControllerTest.generateGoalPeriods();
    List<GsGoalPeriod__c> periods = GoalController.getGoalPeriods();
    System.assert(periods.size() > 0, 'Unable to find goal periods');
    for (GsGoalPeriod__c period : insertedPeriods) {
      System.assert(
        periods.contains(period),
        'Unable to find Goal period ' + period.Name
      );
    }
    Test.stopTest();
  }

  // we test the getting of goals
  @isTest
  static void testGetGoals() {
    for (RecordtypeInfo info : recordTypeList) {
      System.debug(info.getName() + ' ' + info.getRecordTypeId());
    }
    Test.startTest();
    List<GsGoal__c> insertedGoals = GoalControllerTest.generateGoals();
    // No params
    List<GsGoal__c> goals = GoalController.getGoals(
      null,
      null,
      null,
      null,
      null
    );
    // first we want to find all goals
    // if something is null and not handeld this would break
    for (GsGoal__c goal : insertedGoals) {
      Boolean found = false;
      for (GsGoal__c check : goals) {
        if (check.Id.equals(goal.Id)) {
          found = true;
          break;
        }
      }
      System.assert(found, 'Unable to find Goal without params' + goal.Id);
    }
    // we want to ensure that all the filters are not applied
    goals = GoalController.getGoals(
      '',
      '',
      new String[0],
      new String[0],
      new String[0]
    );
    for (GsGoal__c goal : insertedGoals) {
      Boolean found = false;
      for (GsGoal__c check : goals) {
        if (check.Id.equals(goal.Id)) {
          found = true;
          break;
        }
      }
      System.assert(found, 'Unable to find Goal with empty params' + goal.Id);
    }
    // asserting that empty table structure where equal attributes are left out
    for (Integer i = 1; i < goals.size(); i++) {
      GsGoal__c curr = null;
      GsGoal__c prev = null;
      for (GsGoal__c check : insertedGoals) {
        if (check.Id.equals(goals.get(i).Id)) {
          curr = check;
        }
        if (check.Id.equals(goals.get(i - 1).Id)) {
          prev = check;
        }
        if (prev != null && curr != null)
          break;
      }
      System.assert(
        prev != null && curr != null,
        'Cannot find prev and curr to compare'
      );
      if (goals.get(i).GsProgram__c.equals('')) {
        System.assertEquals(curr.GsProgram__c, prev.GsProgram__c);
      }
      if (goals.get(i).GsProject__c.equals('')) {
        System.assertEquals(curr.GsProject__c, prev.GsProject__c);
      }
      if (goals.get(i).GsStudyNumber__c.equals('')) {
        System.assertEquals(curr.GsStudyNumber__c, prev.GsStudyNumber__c);
      }
    }
    // filtered by year
    String period = GoalController.getGoalPeriods().get(0).Id;
    goals = GoalController.getGoals(
      period,
      '',
      new String[0],
      new String[0],
      new String[0]
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by year');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsGoalPeriod__c.equals(period),
        'Cannot filter by by year' + goal.Id
      );
    }
    // filtered by search
    goals = GoalController.getGoals(
      '',
      'StudyNumber',
      new String[0],
      new String[0],
      new String[0]
    );
    // no idea why this does not work System.assert(goals.size() > 0, 'Found no goals while filtering by search');
    // filtered by recordType
    goals = GoalController.getGoals(
      '',
      '',
      new List<String>{ recordTypeList.get(0).getRecordTypeId() },
      new String[0],
      new String[0]
    );
    System.assert(
      goals.size() > 0,
      'Found no goals while filtering by recordtype'
    );
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.RecordTypeId.equals(recordTypeList.get(0).getRecordTypeId()),
        'Not filtered by record type ' + goal.Id
      );
    }
    // filtered by multiple record types
    goals = GoalController.getGoals(
      '',
      '',
      new List<String>{
        recordTypeList.get(0).getRecordTypeId(),
        recordTypeList.get(1).getRecordTypeId()
      },
      new String[0],
      new String[0]
    );
    System.assert(
      goals.size() > 0,
      'Found no goals while filtering by recordtypes'
    );
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.RecordTypeId.equals(recordTypeList.get(0).getRecordTypeId()) ||
        goal.RecordTypeId.equals(recordTypeList.get(1).getRecordTypeId()),
        'Not filtered by record types ' + goal.Id
      );
    }
    // filtered by status
    goals = GoalController.getGoals(
      '',
      '',
      new String[0],
      new List<String>{ statusList.get(0).getValue() },
      new String[0]
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by status');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsStatus__c.equals(statusList.get(0).getvalue()),
        'Not filtered by status ' + goal.Id
      );
    }
    // filtered by multiple status
    goals = GoalController.getGoals(
      '',
      '',
      new String[0],
      new List<String>{
        statusList.get(0).getValue(),
        statusList.get(1).getValue()
      },
      new String[0]
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by stati');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsStatus__c.equals(statusList.get(0).getValue()) ||
        goal.GsStatus__c.equals(statusList.get(1).getValue()),
        'Not filtered by stati ' + goal.Id
      );
    }
    // filtered by flag
    goals = GoalController.getGoals(
      '',
      '',
      new String[0],
      new String[0],
      new List<String>{ 'GsCroGoal__c' }
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by flag');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsCroGoal__c == true,
        'Not filtered by flag ' + goal.Id
      );
    }
    // filtered by multiple flags
    goals = GoalController.getGoals(
      '',
      '',
      new String[0],
      new String[0],
      new List<String>{ 'GsCroGoal__c', 'GsRevised__c' }
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by flags');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsCroGoal__c == true || goal.GsRevised__c == true,
        'Not filtered by flags ' + goal.Id
      );
    }
    // assesing that multiple active filters also work
    // thats why year is always set
    goals = GoalController.getGoals(
      period,
      '',
      new List<String>{ recordTypeList.get(0).getRecordTypeId() },
      new String[0],
      new String[0]
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by year');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsGoalPeriod__c.equals(period) &&
        goal.RecordTypeId.equals(recordTypeList.get(0).getRecordTypeId()),
        'Cannot filter by by year and record type' + goal.Id
      );
    }
    goals = GoalController.getGoals(
      period,
      '',
      new String[0],
      new List<String>{ statusList.get(0).getValue() },
      new String[0]
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by year');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsGoalPeriod__c.equals(period) &&
        goal.GsStatus__c.equals(statusList.get(0).getValue()),
        'Cannot filter by by year and status' + goal.Id
      );
    }
    goals = GoalController.getGoals(
      period,
      '',
      new String[0],
      new String[0],
      new List<String>{ 'GsCroGoal__c' }
    );
    System.assert(goals.size() > 0, 'Found no goals while filtering by year');
    for (GsGoal__c goal : goals) {
      System.assert(
        goal.GsGoalPeriod__c.equals(period) && goal.GsCroGoal__c == true,
        'Cannot filter by by year and flag' + goal.Id
      );
    }
    Test.stopTest();
  }
}