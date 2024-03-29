/**********************************************************
*  AccountUtils
* 
*  Created Date: - 10/30/2023
* 
*  Description: Util class for Account
*  
* *********************************************************/
public class AccountUtils {
    //Return Account record based on AccountId
     public static Account getAccountById(Id accountId) {
        Account accountRecord;
        if (accountId != null) {
            accountRecord = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
        }
        return accountRecord;
    }
}