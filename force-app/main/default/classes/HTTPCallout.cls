/*
 * Created: Prabha 
 * Single point exit for HTTP Callouts
 * 
 * */
public class HTTPCallout {
    
    public static HttpResponse send(String endpoint, String method){
        return send(endpoint, method, null, null);
    }
    
    public static HttpResponse send(String endpoint, String method, Map<String, String> headers){
        return send(endpoint, method, headers, null);
    }
    
    public static HttpResponse send(String endpoint, String method, Map<String, String> headers, String body){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setTimeout(100000);//100 seconds
        if (headers != null){
            for (String key: headers.keySet()){
        		request.setHeader(key, headers.get(key));
            }
        }
        if (!String.isBlank(body)){
            request.setBody(body);
        }
        HttpResponse response = new Http().send(request);
        return response;
    }
}