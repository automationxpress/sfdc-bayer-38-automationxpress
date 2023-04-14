public without sharing class HandleCustomException extends Exception {
    public static void logException(Exception e)
    {
        logException(e, null);
    }

    public static void logException(Exception e, String relatedToId)
    {
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');

        // Get current governor limits
        String queries = '1. Number of SOQL queries issued / Total number allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String dmlRows = '2. Number of records processed with DML statements / Total number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String dmlStatements = '3. Number of DML statements called / Total number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
        String cpuTime = '4. CPU time (in milliseconds) used / Maximum CPU time allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();

        // Log information as a custom object record after making sure permissions are fine
        if (Schema.sObjectType.Custom_Exception__c.isCreateable()) {
            insert new Custom_Exception__c(
                Related_To_Id__c = relatedToId,
                Exception_Message__c = e.getMessage(),
                Exception_Type__c = e.getTypeName(),
                Line_Number__c = e.getLineNumber(),
                Stack_Trace__c = stackTrace,
                Class_Name__c = className,
                Method_Name__c = methodName,
                Governor_Limits__c = String.format('{0}\n{1}\n{2}\n{3}', new List<String>{ queries, dmlRows, dmlStatements, cpuTime })
            );
        }
    }
    
    //Return error details string
    public static String debugException(Exception e)
    {
        String errorMessage;
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.');
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        
        errorMessage += 'Method name: ' + methodName + '\n';
        errorMessage += 'Class name: ' + className + '\r\n';
        errorMessage += 'Exception type caught: ' + e.getTypeName() + '\r\n';
        errorMessage += 'Message: ' + e.getMessage() + '\r\n';
        errorMessage += 'Cause: ' + e.getCause() + '\r\n';
        errorMessage += 'Line number: ' + e.getLineNumber() + '\r\n';
        errorMessage += 'Stack trace: ' + e.getStackTraceString()+ '\r\n';
        return errorMessage;
    }
    
    
}