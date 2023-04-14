public virtual class TriggerHandler {
    
    public void run(){
        if(Trigger.isBefore && Trigger.isInsert){
            beforeInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate){
            beforeUpdate(Trigger.newMap, Trigger.oldMap);
        } else if(Trigger.isBefore && Trigger.isDelete){
            beforeDelete(Trigger.oldMap);
        } else if(Trigger.isAfter && Trigger.isInsert){
            afterInsert(Trigger.newMap);
        } else if(Trigger.isAfter && Trigger.isUpdate){
            afterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if(Trigger.isAfter && Trigger.isDelete){
            afterDelete(Trigger.oldMap);
        } else if(Trigger.isAfter && Trigger.isUndelete){
            afterUndelete(Trigger.oldMap);
        }
    }

    public virtual void beforeInsert(List<SObject> newRecords) {}

    public virtual void beforeUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {}

    public virtual void beforeDelete(Map<Id, SObject> oldRecords) {}

    public virtual void afterInsert(Map<Id, SObject> newRecords) {}

    public virtual void afterUpdate(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {}

    public virtual void afterDelete(Map<Id, SObject> oldRecords) {}

    public virtual void afterUndelete(Map<Id, SObject> oldRecords) {}
}