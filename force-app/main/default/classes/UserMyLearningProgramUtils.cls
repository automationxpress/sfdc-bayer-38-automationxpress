public class UserMyLearningProgramUtils {
    public static final String STATUS_REMOVE = 'Remove';
    
    public static void validateUserMyLearningProgramsOnDelete(Map<Id, User_MyLearning_Program__c> oldUserMyLearningPrograms) {
        Boolean isToBeRemoved;
        for(User_MyLearning_Program__c userMyLearningProgram : oldUserMyLearningPrograms.values()){
            isToBeRemoved = STATUS_REMOVE.equals(userMyLearningProgram.Status__c);
            if(userMyLearningProgram.Is_Locked__c && !isToBeRemoved){
                userMyLearningProgram.addError(Label.UserMyLearningProgramCannotBeDeleted);
            }
        }
    }
}