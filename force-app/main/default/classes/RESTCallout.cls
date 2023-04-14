public class RESTCallout {
    public static final String UTF_8 = 'UTF-8';
    public static final String METHOD_GET = 'GET';
    public static final String METHOD_POST = 'POST';
    
    public static HttpResponse makeGetRequest(String endpoint, Map<String, String> params, Map<String, String> header) {
        HttpRequest request = buildGetRequest(endpoint, params, header);
        return sendRequest(request);
    }

    public static HttpResponse makePostRequest(String endpoint, Map<String, String> header, String body) {
        HttpRequest request = buildPostRequest(endpoint, header, body);
        return sendRequest(request);
    }

    private static HttpRequest buildGetRequest(String endpoint, Map<String, String> params, Map<String, String> header){
        HttpRequest request = new HttpRequest();
        request.setMethod(METHOD_GET);
        setEndpoint(request, endpoint, params);
        setHeader(request, header);
        return request;
    }

    private static HttpRequest buildPostRequest(String endpoint, Map<String, String> header, String body){
        HttpRequest request = new HttpRequest();
        request.setMethod(METHOD_POST);
        setEndpoint(request, endpoint);
        setHeader(request, header);
        request.setBody(body);
        return request;
    }

    private static HttpResponse sendRequest(HttpRequest request){
        Http httpProtocol = new Http();
        System.debug(request);
        HttpResponse response;
        try {
            response = httpProtocol.send(request);
        } catch (Exception ex) {
            HandleCustomException.logException(ex);
        }

        return response;
    }

    private static void setEndpoint(HttpRequest request, String endpoint){
        setEndpoint(request, endpoint, null);
    }

    private static void setEndpoint(HttpRequest request, String endpoint, Map<String, String> params){
        if (request != null && endpoint != null) {
            String urlParameters = params != null ? getUrlParameters(params) : '';
            request.setEndpoint(endpoint + urlParameters);
        }
    }

    private static void setHeader(HttpRequest request, Map<String, String> header){
        if (request != null && header != null) {
            for (String key : header.keySet()) {
                request.setHeader(key, header.get(key));
            }
        }
    }

    private static String getUrlParameters(Map<String, String> params) {
        String urlParameters = '';
        String value;
        for(String key : params.keySet()) {
            value = String.isNotBlank(params.get(key)) ? EncodingUtil.urlEncode(params.get(key), UTF_8) : '';
            urlParameters += String.isBlank(urlParameters) ? '?' : '&';
            urlParameters += key + '=' + value.replace('+', '%20');
        }
        
        return urlParameters;
    }
}