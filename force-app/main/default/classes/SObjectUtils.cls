public class SObjectUtils {
    
    public static Set<Id> getRecordIds(List<SObject> records){
        Set<Id> ids = new Set<Id>();
        for(SObject record : records){
            ids.add(record.Id);
        }

        return ids;
    }
}