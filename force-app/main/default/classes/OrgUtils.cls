public class OrgUtils {
    private static final String INTEGRATION_CONFIG_STAGING = 'STAGING';
    private static final String INTEGRATION_CONFIG_PROD = 'PROD';
    private static final String UMA_SETTINGS_NAME = 'UMA';
    private static Organization organization;

    public static Boolean isSandbox() {
        Organization org = getOrganization();
        return org.IsSandbox;
    }

    public static Organization getOrganization(){
        if(organization == null){
            organization = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        }
        return organization;
    }

    public static UMA_Settings__mdt getUmaSettings(){
        List<UMA_Settings__mdt> umaSettings = [SELECT Max_nr_of_Prima_POST_request_attempts__c 
                                               FROM UMA_Settings__mdt 
                                               WHERE DeveloperName = :UMA_SETTINGS_NAME LIMIT 1];
        if(!umaSettings.isEmpty()){
            return umaSettings[0];
        }
        return null;
    }

    public static Integration_Config__mdt getIntegrationConfig(){
        String name = isSandbox() ? INTEGRATION_CONFIG_STAGING : INTEGRATION_CONFIG_PROD;
        List<Integration_Config__mdt> integrationConfig = [SELECT Prima_Authtoken__c, One_Trust_Api_Key__c 
                                               FROM Integration_Config__mdt 
                                               WHERE DeveloperName = :name LIMIT 1];
        if(!integrationConfig.isEmpty()){
            return integrationConfig[0];
        }
        return null;
    }
}