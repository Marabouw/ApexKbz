public class ContactApiManager {

    private static final String API_URL = 'https://fxyozmgb2xs5iogcheotxi6hoa0jdhiz.lambda-url.eu-central-1.on.aws';
    private static final String AUTH_HEADER = 'salesforceAuthToken';

    // Sync contacts with API
    public static void syncContacts(List<Contact> contacts) {
        if (contacts != null && !contacts.isEmpty()) {
            List<Map<String, Object>> payload = buildApiPayload(contacts);
            
            // Call the API with the playload
            ApiResponse response = callApi(payload);

            // Processes the API response
            handleApiResponse(response);
        }
    }

    // Build the payload for the API from Salesforce contacts
    private static List<Map<String, Object>> buildApiPayload(List<Contact> contacts) {
        List<Map<String, Object>> payload = new List<Map<String, Object>>();

        for (Contact contact : contacts) {
            Map<String, Object> contactData = new Map<String, Object>{
                'id' : contact.Id,
                'is_active' : contact.IsActive__c
            };

            payload.add(contactData);
        }

        return payload;
    }

    // Call the API with the payload
    private static ApiResponse callApi(List<Map<String, Object>> payload) {
        String logMethod = 'ContactApiManager.callApi()';
        

        // make the call using HTTP, HTTPRequest and HTTP Response
        // stores the HTTPResponse in a ApiResponse instance
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', AUTH_HEADER);
            request.setMethod('PATCH');
            request.setEndpoint(API_URL);
            request.setBody(JSON.serializePretty(payload));

            HttpResponse response = http.send(request);

            Integer statusCode = response.getStatusCode();
            String status = response.getStatus();
            String responseBody = response.getBody();

            ApiResponse callApiResponse = new ApiResponse(statusCode, status, body);

            return callApiResponse;

        } catch (System.CalloutException e){
            System.debug('An error occured on callout : [ ' + logMethod + ' ] - ' + e.getMessage());
            throw e;
        }
    }

    // Processes API response
    private static void handleApiResponse(ApiResponse response) {

        // Prepare message for logging : message contains body only if response status is an error

        String messageTemplate = 'ApiResponse details: \n [ StatusCode = {0} , Status = {1} ]';
        List<String> msgParams = new List<String>{response.statusCode, response.status};

        if(response.statusCode != 200){
            messageTemplate += '\n[ body = {2}]';
            msgParams.add(response.body);

            // Check if response is JSON format
            try {
                Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.body);
                msgParams.add(response.body);
            } catch (Exception e) {
                // if not in JSON format, add raw version of response
                messageTemplate += '\n An error occured : ' + e.getMessage() +' \n{3}';
                msgParams.add('Non-JSON Response : ' + response.body);
            }
        }

        String logMessage = String.format(messageTemplate);

        System.debug(logMessage);
    }

    // Class that represent an API Response
    private class ApiResponse {
        public Integer statusCode;
        public String status;
        public String body;

        public ApiResponse(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }
    }
}