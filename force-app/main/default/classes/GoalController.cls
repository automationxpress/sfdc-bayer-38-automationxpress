public with sharing class GoalController {
  @AuraEnabled(cacheable=true)
  public static List<GsGoal__c> getGoals(
    String year,
    String searchInput,
    List<String> recordTypes,
    List<String> status,
    List<String> flags
  ) {
    try {
      // we initialize a list of goals to be returned
      List<GsGoal__c> goals = new List<GsGoal__c>();
      // we have to compile a dynamic SOQL string
      String whereSearch = '';
      // we always check if the value is not present as it will not be filtered
      // if it is present we add it to searchstring with the appropriate search params
      // if the string is empty a WHERE has to be added otherwise only ANDs
      if (year != null && !year.equals('')) {
        whereSearch +=
          (whereSearch.equals('') ? ' WHERE ' : ' AND ') +
          'GsGoalPeriod__c = :year';
      }
      if (recordTypes != null && recordTypes.size() != 0) {
        whereSearch +=
          (whereSearch.equals('') ? ' WHERE ' : ' AND ') +
          'RecordTypeId IN :recordTypes';
      }
      if (status != null && status.size() != 0) {
        whereSearch +=
          (whereSearch.equals('') ? ' WHERE ' : ' AND ') +
          'GsStatus__c IN :status';
      }
      if (flags != null) {
        for (String flag : flags) {
          whereSearch +=
            (whereSearch.equals('') ? ' WHERE ' : ' AND ') +
            flag +
            ' = TRUE';
        }
      }
      // The fields we want to slect
      String fields = 'GsProgram__c, GsProject__c, GsStudyNumber__c, GsGoalTitle__c, GsTargetFormula__c, GsStatus__c, GsFinal__c, GsCroGoal__c, GsRevised__c, GsComments__c, GsLabcorpIncentiveGoal__c, GsWithdrawn__c, GsWithdrawnComment__c, GsAchievedDate__c, RecordType.Name, Id, GsGoalPeriod__c';
      // The list will be filled either using SOSL or SOQL dependent on if there is a search phrase present
      if (searchInput != null && !searchInput.equals('')) {
        String query =
          'FIND :searchInput' +
          ' RETURNING GsGoal__c(' +
          fields +
          whereSearch +
          ' ORDER BY GsProgram__c, GsProject__c, GsStudyNumber__c)';
        goals = Search.query(query)[0];
      } else {
        String query =
          'SELECT ' +
          fields +
          ' FROM GsGoal__c' +
          whereSearch +
          ' ORDER BY GsProgram__c, GsProject__c, GsStudyNumber__c';
        goals = Database.query(query);
      }
      Integer sameProgram = 0;
      Integer sameProject = 0;
      Integer sameStudy = 0;
      // we iterate over all goals
      // if the previous entry has the same Program, Project and/or Study we null the field
      // so it appears in the frontend as a wonderful table wherer doubled entries are not shown
      for (Integer i = 1; i < goals.size(); i++) {
        GsGoal__c goal = goals[i];
        if (
          goal.GsProgram__c != null &&
          goal.GsProgram__c.equals(goals[sameProgram].GsProgram__c)
        ) {
          goal.GsProgram__c = '';
          if (
            goal.GsProject__c != null &&
            goal.GsProject__c.equals(goals[sameProject].GsProject__c)
          ) {
            goal.GsProject__c = '';
            if (
              goal.GsStudyNumber__c != null &&
              goal.GsStudyNumber__c.equals(goals[sameStudy].GsStudyNumber__c)
            ) {
              goal.GsStudyNumber__c = '';
            } else {
              sameStudy = i;
            }
          } else {
            sameProject = i;
            sameStudy = i;
          }
        } else {
          sameProgram = i;
          sameProject = i;
          sameStudy = i;
        }
      }
      return goals;
    } catch (Exception e) {
      HandleCustomException.logException(e);
      throw e;
    }
  }

  @AuraEnabled(cacheable=true)
  // we simply return all goal periods from the database using SOQL
  public static List<GsGoalPeriod__c> getGoalPeriods() {
    try {
      return [
        SELECT Name, Id
        FROM GsGoalPeriod__c
        ORDER BY Name
      ];
    } catch (Exception e) {
      HandleCustomException.logException(e);
      throw e;
    }
  }
}