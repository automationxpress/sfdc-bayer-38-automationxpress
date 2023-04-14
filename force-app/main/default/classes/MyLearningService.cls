public with sharing class MyLearningService {

    private static final Boolean IS_SANDBOX = OrgUtils.isSandbox();
    private static final String MY_LEARNING_GENERAL_URL = '/MyLearningGeneral/V1';
    private static final String MY_LEARNING_TRAINING_ASSIGMENT_URL = '/MyLearningTrainingAssigment/V1';
    public static final String CURRICULUM_STATUS_COMPLETE = 'Complete';
    public static final String CURRICULUM_STATUS_INCOMPLETE = 'Incomplete';

    public class MyLearningException extends Exception {}

    public static String getCurriculumStatus(String userId, String curriculumId){
        HttpResponse response = getCurriculumStatusFromMyLearning(userId, curriculumID);
        Map<String, Object> result = (Map<String, Object>) System.JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 200 && result.containsKey('value')){
            List<Object> valueList = (List<Object>) result.get('value');
            Map<String, Object> value = !valueList.isEmpty() ? (Map<String, Object>) valueList[0] : new Map<String, Object>();
            if(value.containsKey('curriculumStatus')){
                return (String) value.get('curriculumStatus');
            }
        }
        return null;
    }

    public static Boolean isCurriculumAssigned(String curriculumStatus){
        return String.isNotBlank(curriculumStatus) 
               && (curriculumStatus == CURRICULUM_STATUS_COMPLETE || curriculumStatus == CURRICULUM_STATUS_INCOMPLETE);
    }

    public static Map<String, Map<String, CurriculumResponse>> assignCurriculums(List<User_MyLearning_Program__c> userMyLearningPrograms){
        CurriculumAssigmentRequest request = new CurriculumAssigmentRequest();
        for(User_MyLearning_Program__c userMLProgram : userMyLearningPrograms){        
            request.curricula.add(
                new CurriculumRequest(
                    userMLProgram.User_Entry__r.CWID__c, 
                    userMLProgram.MyLearning_Program__r.ID__c
                )
            );
        }

        return assignCurriculumsInMyLearning(request);
    }

    private static HttpResponse getCurriculumStatusFromMyLearning(String userId, String curriculumId){
        String endpoint = 'callout:MyLearning';
        endpoint += MY_LEARNING_GENERAL_URL;
        endpoint += IS_SANDBOX ? '/dev' : '';
        endpoint += '/public/user/curriculum/v1/CurriculumStatuses';

        Map<String, String> params = new Map<String, String>{
            '$filter' => 'csCriteria/targetUserID eq \'' + userId + '\' and csCriteria/curriculumID eq \'' + curriculumId +'\''
        };
        Map<String, String> header = new Map<String, String>{
            'Accept' => 'application/json'
        };

        HttpResponse response = RESTCallout.makeGetRequest(endpoint, params, header);
        return response;
    }

    private static Map<String, Map<String, CurriculumResponse>> assignCurriculumsInMyLearning(CurriculumAssigmentRequest curriculumAssigmentRequest){
        String endpoint = 'callout:MyLearning';
        endpoint += MY_LEARNING_TRAINING_ASSIGMENT_URL;
        endpoint += IS_SANDBOX ? '/dev' : '';
        endpoint += '/public/admin/curriculum-service/v1/Curricula';
        
        Map<String, String> header = new Map<String, String>{
            'Content-Type' => 'application/json'
        };

        String body = JSON.serialize(curriculumAssigmentRequest);

        HttpResponse response = RESTCallout.makePostRequest(endpoint, header, body);
        if(response.getStatusCode() == 201){
            return getCurriculumResponseMap(response.getBody());
        }
        
        return new Map<String, Map<String, CurriculumResponse>>();
    }

    private static Map<String, Map<String, CurriculumResponse>> getCurriculumResponseMap(String body){
        Map<String, Map<String, CurriculumResponse>> curriculumResponseMap = new Map<String, Map<String, CurriculumResponse>>();
        CurriculumAssigmentResponse curriculumAssigmentResponse = (CurriculumAssigmentResponse) System.JSON.deserialize(body, CurriculumAssigmentResponse.class);
        if(curriculumAssigmentResponse != null && curriculumAssigmentResponse.curricula != null){
            for(CurriculumResponse curriculumResponse : curriculumAssigmentResponse.curricula){
                if(!curriculumResponseMap.containsKey(curriculumResponse.studentID)){
                    curriculumResponseMap.put(
                        curriculumResponse.studentID, 
                        new Map<String, CurriculumResponse>{curriculumResponse.qualificationID => curriculumResponse}
                    );
                } else {
                    curriculumResponseMap.get(curriculumResponse.studentID).put(curriculumResponse.qualificationID, curriculumResponse);
                } 
            }
        }
        return curriculumResponseMap;
    }

    public static CurriculumResponse getCurriculumResponse(Map<String, Map<String, CurriculumResponse>> curriculumResponseMap, String studentID, String qualificationID){
        if(curriculumResponseMap.containsKey(studentID) && curriculumResponseMap.get(studentID).containsKey(qualificationID)){
            return curriculumResponseMap.get(studentID).get(qualificationID);
        }
        return null;
    }

    public class CurriculumAssigmentRequest {
        public String primaryKey;
        public List<CurriculumRequest> curricula;

        public CurriculumAssigmentRequest(){
            primaryKey = '';
            curricula = new List<CurriculumRequest>();
        }
    }

    public class CurriculumRequest {
        public String studentID;
        public String qualificationID;
        public Long assignmentDate;

        public CurriculumRequest(String userId, String curriculumId){
            studentID = userId;
            qualificationID = curriculumId;
            Datetime midnightGMT = System.now().dateGMT();
            assignmentDate = midnightGMT.getTime();
        }
    }

    public class CurriculumAssigmentResponse {
        public String primaryKey;
        public List<CurriculumResponse> curricula;
    }

    public class CurriculumResponse {
        public String studentID;
        public String qualificationID;
        public Long assignmentDate;
        public String errorMessage;
    }
}