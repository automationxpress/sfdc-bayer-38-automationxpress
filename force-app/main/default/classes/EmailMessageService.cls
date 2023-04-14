public class EmailMessageService {
    private static final String TEMPLATE_MY_LEARNING_UPDATES = 'User_Entry_MyLearning_Updates_Notification';

    public static Id getMyLearningUpdatesTemplateId(){
        return getEmailTemplateId(TEMPLATE_MY_LEARNING_UPDATES);
    }

    public static Id getEmailTemplateId(String templateName) {
        List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName];
        if(!emailTemplates.isEmpty()){
            return emailTemplates[0].Id;
        }
        return null;
    }

    public static Messaging.SingleEmailMessage getSingleEmailMessageFromTemplate(Id templateId, Id recordId, List<String> toAddresses){
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, recordId);
        email.setHTMLBody(email.getHTMLBody());
        email.setSubject(email.getSubject());
        email.setSaveAsActivity(false);
        email.setToAddresses(toAddresses);
        return email;
    }

    public static void sendEmailMessages(List<Messaging.SingleEmailMessage> emails){
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
    }
}