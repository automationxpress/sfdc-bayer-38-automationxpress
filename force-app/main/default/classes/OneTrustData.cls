public class OneTrustData {

    public static final String COUNTRY_CODE_TR = 'TR';
    public static final String TIMESTAMP_TYPE_COLLECT = 'collect';
    public static final String SOURCE_SYSTEM_VEEVA_REMOTE = 'VEEVA-REMOTE';
    public static final String CONSENT_TYPE_ECOMMUNICATION = 'ECOMMUNICATION';
    public static final String CONSENT_TYPE_PRIVACYSTATEMENT = 'PRIVACYSTATEMENT';
    public static final String PURPOSE_TYPE_IMCM_BROAD_CONSENT = 'IMCM Broad Consent';
    public static final String PURPOSE_TYPE_DP_PROCESSING = 'DP Processing';
    public static final String PURPOSE_TYPE_THIRD_COUNTRY_TRANSFERS = 'Third Country Transfers';
    public static final List<String> ECOMMUNICATION_CHANNEL_TYPES = new List<String>{
        'Call', 'Fax', 'Messaging', 'Newsletter', 'Approved E-mail'
    };
    public enum Action {ACTIVE, NOT_GIVEN}

    public class ConsentCollectRequest {
        public Account account;
        public TransactionTimestamp transactionTimestamp;
        public Meta meta;
        public List<Consent> consent;

        public ConsentCollectRequest(){
            consent = new List<Consent>();
        }
    }

    public class Account {
        public String countryCode;
        public String identifier;

        public Account(String countryCode, String identifier){
            this.countryCode = countryCode;
            this.identifier = identifier;
        }
    }

    public class TransactionTimestamp {
        public String timestampType;
        public String timestamp;

        public TransactionTimestamp(String timestampType){
            this.timestampType = timestampType;
            this.timestamp = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        }
    }

    public class Meta {
        public String sourceSystem;

        public Meta(String sourceSystem){
            this.sourceSystem = sourceSystem;
        }
    }

    public class Consent {
        public String type;
        public List<Purpose> purpose;

        public Consent(String type){
            this.type = type;
            purpose = new List<Purpose>();
        }
    }

    public class Purpose {
        public String type;
        public String action;
        public List<Channel> channels;

        public Purpose(String type, String action){
            this.type = type;
            this.action = action;
            channels = new List<Channel>();
        }
    }

    public class Channel {
        public String type;
        public String action;

        public Channel(String type, String action){
            this.type = type;
            this.action = action;
        }
    }

    public static ConsentCollectRequest getDPProcessingRequest(String email, Action action){
        return getConsentCollectRequestForPrivacyStatement(email, PURPOSE_TYPE_DP_PROCESSING, action);
    }

    
    public static ConsentCollectRequest getThirdCountryTransfersRequest(String email, Action action){
        return getConsentCollectRequestForPrivacyStatement(email, PURPOSE_TYPE_THIRD_COUNTRY_TRANSFERS, action);
    }

    public static ConsentCollectRequest getIMCMBroadConsentRequest(String email, Action action){
        return getConsentCollectRequestForECommunication(email, PURPOSE_TYPE_IMCM_BROAD_CONSENT, action);
    }

    public static ConsentCollectRequest getConsentCollectRequestForPrivacyStatement(String email, String purposeType, Action action){
        ConsentCollectRequest privacyStatement = new ConsentCollectRequest();
        privacyStatement.account = new Account(COUNTRY_CODE_TR, email);
        privacyStatement.transactionTimestamp = new TransactionTimestamp(TIMESTAMP_TYPE_COLLECT);
        privacyStatement.meta = new Meta(SOURCE_SYSTEM_VEEVA_REMOTE);
        Consent consent = new Consent(CONSENT_TYPE_PRIVACYSTATEMENT);
        Purpose purpose = new Purpose(purposeType, action.name());
        consent.purpose.add(purpose);
        privacyStatement.consent.add(consent);
        return privacyStatement;
    }

     public static ConsentCollectRequest getConsentCollectRequestForECommunication(String email, String purposeType, Action action){
        ConsentCollectRequest ecommunication = new ConsentCollectRequest();
        ecommunication.account = new Account(COUNTRY_CODE_TR, email);
        ecommunication.transactionTimestamp = new TransactionTimestamp(TIMESTAMP_TYPE_COLLECT);
        ecommunication.meta = new Meta(SOURCE_SYSTEM_VEEVA_REMOTE);
        Consent consent = new Consent(CONSENT_TYPE_ECOMMUNICATION);
        Purpose purpose = new Purpose(PURPOSE_TYPE_IMCM_BROAD_CONSENT, action.name());
        for(String channelType : ECOMMUNICATION_CHANNEL_TYPES){
            purpose.channels.add(new Channel(channelType, action.name()));
        }
        consent.purpose.add(purpose);
        ecommunication.consent.add(consent);
        return ecommunication;
    }
}