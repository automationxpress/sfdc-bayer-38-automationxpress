/**********************************************************
*  RoleMatrixController
* 
*  Author: Sachin Chothe
*  Created Date: 15/11/2021
*  Last Modified By: -
*  Last Modified Date: -14/03/2023
* 
*  Description: controller class for Lightning Web Component - 'RoleMatrixDisplay'.
*  //Added error handling
*
* *********************************************************/

public class RoleMatrixController{
    //method to get filtered Role Matrix records based on search key
    @AuraEnabled(cacheable=true)
    public static List<RoleMatrixListWrapper> getFilteredRoleMatrixDetails(String searchKey){
        List<RoleMatrixListWrapper> rolematrixlist ;
        try{
            String query = 'SELECT Id, Role_Matrix_Type__c,Job_Role__r.Name,MAPV_Department__r.Name,MAPV_Group__r.Name,Main_Role_Add_on_Formula__c,Uma_Company__c,Comments__c,(SELECT MyLearning_Program__r.Name From Role_Matrix_MyLearning_Programs__r),(SELECT Prima_Role__r.Name From Role_Matrix_Prima_Roles__r),(SELECT Prima_Security_Group__r.Name From Role_Matrix_Prima_Security_Groups__r) FROM Role_Matrix__c';
            if (searchKey != null && searchKey != '' ) {
                String key = '%' + searchKey + '%';
                query += ' WHERE Job_Role__r.Name LIKE :key OR MAPV_Department__r.Name LIKE :key OR MAPV_Group__r.Name LIKE :key OR Main_Role_Add_on_Formula__c LIKE :key OR Uma_Company__c LIKE :key ORDER BY LastModifiedDate DESC';
                
            }
            else{
                query+=' ORDER BY LastModifiedDate DESC';
            }
            
            rolematrixlist=getRoleMatrixWrapperList(Database.query(query)); 
        }catch (Exception e){
            System.debug(HandleCustomException.debugException(e));
        }
        return rolematrixlist;
    }
    
    // Returns wrapper list RoleMatrixListWrapper with Role Matrix Record and related assignements
    public static List<RoleMatrixListWrapper> getRoleMatrixWrapperList(List<Role_Matrix__c> roleMatrixList){
        List<RoleMatrixListWrapper> roleMatrixWrapperList = new List<RoleMatrixListWrapper>();
        if(!roleMatrixList.isEmpty()){
            for(Role_Matrix__c row : roleMatrixList){
                RoleMatrixListWrapper roleMatrixWrapper = new RoleMatrixListWrapper();
                roleMatrixWrapper.roleMatrixRecord = row;
                Set<String> tempMyLearningSet = new Set<String>();
                Set<String> tempPrimaRoleSet = new Set<String>();
                Set<String> tempPrimaSecurityGroupSet = new Set<String>();
                
                for(Role_Matrix_ML__c index : row.Role_Matrix_MyLearning_Programs__r){
                    tempMyLearningSet.add(index.MyLearning_Program__r.Name);
                }
                roleMatrixWrapper.myLearningString = tempMyLearningSet.toString().substring(1,tempMyLearningSet.toString().length()-1);
                
                for(Role_Matrix_Prima_Role__c index : row.Role_Matrix_Prima_Roles__r){
                    tempPrimaRoleSet.add(index.Prima_Role__r.Name);
                }
                roleMatrixWrapper.primaRoleString = tempPrimaRoleSet.toString().substring(1,tempPrimaRoleSet.toString().length()-1);
                
                for(Role_Matrix_Prima_SG__c index : row.Role_Matrix_Prima_Security_Groups__r){
                    tempPrimaSecurityGroupSet.add(index.Prima_Security_Group__r.Name);
                }
                roleMatrixWrapper.primaSecurityGroupString = tempPrimaSecurityGroupSet.toString().substring(1,tempPrimaSecurityGroupSet.toString().length()-1);
                
                roleMatrixWrapperList.add(roleMatrixWrapper);
            }
        }
        return roleMatrixWrapperList;
    }
    
    //wrapper class to get structured data in LWC
    public class RoleMatrixListWrapper{
        @AuraEnabled
        public Role_Matrix__c roleMatrixRecord{get;set;}
        @AuraEnabled
        public String myLearningString{get;set;}
        @AuraEnabled
        public String primaRoleString{get;set;}
        @AuraEnabled
        public String primaSecurityGroupString{get;set;}
        
    }
}