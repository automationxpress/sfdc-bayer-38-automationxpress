public without sharing class UMAHomePageController {
    
    //method to get all User Entry records
	@AuraEnabled(cacheable=true)
    public static List<User_Entry__c> getUserEntryDetails(){
        String sortDirection='';
        String sortBy='';
        String query = 'SELECT Id,Name,CWID__c,Email__c,Uma_Company__c,Primary_Job_Role__r.Name,Locations__c,MAPV_Department__r.Name,MAPV_Group__r.Name,Resource_Manager__r.Name FROM User_Entry__c';
        if(sortBy != '' && sortDirection != '' ) {
           query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        else{
            query += ' ORDER BY LastModifiedDate DESC';
        }
       query = query + ' LIMIT 49000';
       system.debug('query '+ query);
       return Database.query( query ); 
    }
    
    //method to get filtered User Entry records based on search key
    @AuraEnabled(cacheable=true)
    public static List<User_Entry__c> getFilteredUserEntryDetails(String searchKey,String sortDirection,String sortBy){
        system.debug('searchKey '+ searchKey);
        String query = 'SELECT Id,Name,CWID__c,Email__c,Uma_Company__c,Primary_Job_Role__r.Name,Locations__c,MAPV_Department__r.Name,MAPV_Group__r.Name,Resource_Manager__r.Name FROM User_Entry__c';
        if (searchKey != null && searchKey != '') {
           String key = '%' + searchKey + '%';
           query += ' WHERE Name LIKE :key OR CWID__c LIKE :key OR Email__c LIKE :key OR Primary_Job_Role__r.Name LIKE :key OR MAPV_Department__r.Name LIKE :key OR MAPV_Group__r.Name LIKE :key OR Uma_Company__c LIKE :key OR Resource_Manager__r.Name LIKE :key';
        }
        if(sortBy != '' && sortDirection != '' ) {
           query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        else{
            query += ' ORDER BY LastModifiedDate DESC';
        }
        query = query + ' LIMIT 49000';
        system.debug('query '+ query);
        return Database.query(query); 
    }

}