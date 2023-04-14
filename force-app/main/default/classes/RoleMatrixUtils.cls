//Utility class for Role Matrix
//Last modified : 14/03/2023 - Added new logic to return assignments from Role Matrix based on new field- Role Matrix Type
//Added error handling

public class RoleMatrixUtils {
    //Return Role Matrix record based on prvided id
    public static Role_Matrix__c getRoleMatrix(String roleMatrixId){
        Set<String> roleMatrixIds = new Set<String>{roleMatrixId};
            List<Role_Matrix__c> roleMatricesList; 
        try{
            roleMatricesList = getRoleMatrices(roleMatrixIds);    
        }
        catch(Exception e){
            System.debug(HandleCustomException.debugException(e));
        }
        
        if(roleMatricesList.isEmpty()){
            return null;
        }
        return roleMatricesList[0];
    }
    
    
    //Return List of Role Matrices based on set of Role Matrix Ids
    public static List<Role_Matrix__c> getRoleMatrices(Set<String> roleMatrixIds){
        return [SELECT Id, Name, Job_Role__c, MAPV_Department__c,Role_Matrix_Type__c,
                (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name FROM Role_Matrix_MyLearning_Programs__r),
                (SELECT Id, Prima_Role__c, Prima_Role__r.Name FROM Role_Matrix_Prima_Roles__r),
                (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name FROM Role_Matrix_Prima_Security_Groups__r)
                FROM Role_Matrix__c WHERE Id IN :roleMatrixIds];
    }
    
    
    //Return List of Role Matrices based on selection of Job Role, MAPV Dept, Group and Company in User Entry
    public static List<Role_Matrix__c> getRoleMatrices(Set<Id> jobRoleIds, Id mapvDepartmentId, Id mapvGroupId, Id companyId) {
        List<Role_Matrix__c> roleMatrixList = new List<Role_Matrix__c>();
        try{
            for(Id jobRoleId:jobRoleIds ){
                List<Role_Matrix__c> roleMatrixsingleList = new List<Role_Matrix__c>();
                Id mapvDepartmentIds= mapvDepartmentId;
                Id mapvGroupIds= mapvGroupId;
                Id companyIds=companyId;
                roleMatrixsingleList=RoleMatrixUtils.getRoleMatrix(jobRoleId, mapvDepartmentIds, mapvGroupIds, companyIds);
                roleMatrixList.addall(roleMatrixsingleList);
            }
        }
        catch(Exception e){
            System.debug(HandleCustomException.debugException(e));
        }
        
        return roleMatrixList;
    }
    
    //Return a Role Matrix record based on provided input parameters. 
    //Matching logic is based on the prioriry order of Role Matrix Type
    //staring from 4-Criteria Role Matrix(/Global Job role/ Add-On role), 3-Criteria Role Matrix, 2-Criteria Role Matrix
    
    public static List<Role_Matrix__c> getRoleMatrix(Id jobRoleId, Id mapvDepartmentId, Id mapvGroupId, Id companyId){
        List<Role_Matrix__c> roleMatrixList = new List<Role_Matrix__c>();
        roleMatrixList= [SELECT Id, Name, Job_Role__c,Role_Matrix_Type__c,
                         (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name FROM Role_Matrix_MyLearning_Programs__r),
                         (SELECT Id, Prima_Role__c, Prima_Role__r.Name FROM Role_Matrix_Prima_Roles__r),
                         (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name FROM Role_Matrix_Prima_Security_Groups__r)
                         FROM Role_Matrix__c 
                         WHERE Job_Role__c = : jobRoleId
                         AND ( 
                             Role_Matrix_Type__c = 'Global Job role/ Add-On role'
                             OR (
                                 Role_Matrix_Type__c = '4-Criteria Role Matrix'
                                 AND MAPV_Department__c = :mapvDepartmentId
                                 AND MAPV_Group__c = :mapvGroupId
                                 AND Company__c = :companyId
                             )     
                         )
                        ];
        
        
        if(roleMatrixList.size()==0){
            roleMatrixList= [SELECT Id, Name, Job_Role__c,
                             (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name FROM Role_Matrix_MyLearning_Programs__r),
                             (SELECT Id, Prima_Role__c, Prima_Role__r.Name FROM Role_Matrix_Prima_Roles__r),
                             (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name FROM Role_Matrix_Prima_Security_Groups__r)
                             FROM Role_Matrix__c 
                             WHERE Job_Role__c = : jobRoleId
                             AND (
                                 Role_Matrix_Type__c = '3-Criteria Role Matrix'
                                 AND Company__c = :companyId
                                 AND MAPV_Department__c = :mapvDepartmentId
                             )
                            ];
            
            if(roleMatrixList.size()==0){
                roleMatrixList= [SELECT Id, Name, Job_Role__c,
                                 (SELECT Id, MyLearning_Program__c, MyLearning_Program__r.Name FROM Role_Matrix_MyLearning_Programs__r),
                                 (SELECT Id, Prima_Role__c, Prima_Role__r.Name FROM Role_Matrix_Prima_Roles__r),
                                 (SELECT Id, Prima_Security_Group__c, Prima_Security_Group__r.Name FROM Role_Matrix_Prima_Security_Groups__r)
                                 FROM Role_Matrix__c 
                                 WHERE Job_Role__c = : jobRoleId
                                 AND (
                                     Role_Matrix_Type__c = '2-Criteria Role Matrix'
                                     AND Company__c = :companyId	
                                 )
                                ];
                
            }	
        }
        
        return roleMatrixList;
    }
    
}