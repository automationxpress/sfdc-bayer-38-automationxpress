public without sharing class ApprovalProcessService {

    public static void submitForApproval(String recordId, String comments) {
        submitForApproval(recordId, UserInfo.getUserId(), comments);
    }

    public static void submitForApproval(String recordId, String submitterId, String comments) {
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(recordId);
        submitRequest.setSubmitterId(submitterId);
        submitRequest.setComments(comments);
        Approval.ProcessResult result = Approval.process(submitRequest);
    }
}