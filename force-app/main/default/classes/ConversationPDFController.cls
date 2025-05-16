/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     ConversationPDFController
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-7-2025 
* @Used By            ConversationPDFController_Test
* @Test Covered By    ConversationPDFController_Test         
* @SystemLayer        Controller
* ------------------------------------------------------------------------------------------
* @description        This class is used as controller for ConversationExportVF page and responsible for proving chat entries for pdf generation.
* ------------------------------------------------------------------------------------------
*/
public with sharing class ConversationPDFController {
    public String sSessionId { get; set; }
    public List<ConversationEntry> listEntries { get; set; }
    public String sEndUserName { get; set; }
    public String sAgentName { get; set; }
    public DateTime dCreatedDate { get; set; }
    
    public ConversationPDFController() {
        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=MyPDF.pdf');
        sSessionId = ApexPages.currentPage().getParameters().get('id');
        listEntries = new List<ConversationEntry>();
        if (sSessionId != null) {
            fetchConversationEntries(sSessionId);
        }
    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     fetchConversationEntries
* @description     Fetch conversation entries for messaging session
* ------------------------------------------------------------------------------------------------------
* @param           sMessagingSessionId    Messaging Session Record Id , String
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    private void fetchConversationEntries(String sMessagingSessionId) {
        // Query the MessagingSession object to get the conversationId (MessagingChannelId)
        MessagingSession oSession = [
            SELECT Id,Name, ConversationId ,  First_Name__c, Last_Name__c , owner.Name ,CreatedDate , ChannelType , MessagingEndUser.Name
            FROM MessagingSession
            WHERE Id = :sMessagingSessionId 
            WITH USER_MODE
            LIMIT 1 
        ];
        if(oSession.ChannelType == 'WhatsApp'){
            sEndUserName = oSession.MessagingEndUser.Name;
        }
        else{
           sEndUserName = oSession.First_Name__c + ' ' +  oSession.Last_Name__c;  
        }
        
        String sFileName = sEndUserName + ' - ' +oSession.Name + ' - '+Date.today().format(); 
        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+sFileName+'.pdf');
            
        sAgentName = oSession.owner.Name; 
        dCreatedDate = oSession.CreatedDate; 
        
        String sEndpoint = '';
        
        if(!Test.isRunningTest()){
            Conversation oConv= [
            SELECT Id, ConversationIdentifier
            FROM Conversation
            WHERE Id = :oSession.ConversationId
            WITH USER_MODE
            LIMIT 1 
        ];
       
        String sConversationId = oSession.ConversationId;
        sEndpoint = '/services/data/v62.0/connect/conversation/' + oConv.ConversationIdentifier + '/entries';
        }
        else{
            sEndpoint = '/services/data/v62.0/connect/conversation/1234/entries';
        }
       
       HttpResponse res = getConversationEntriesResponse(sEndpoint);
      
       if (res.getStatusCode() == 200) {
           Map<String, Object> mapJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
           List<ConversationEntry> listTempEntries  = prepareConversationEntryWrapperList(mapJsonResponse);
           sortConversationEnties(listTempEntries);
        } 
        else {
            throw new AuraHandledException('Failed to fetch conversation: ' + res.getStatus() + ' - ' + res.getBody());
        }
    }
 
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     getConversationEntriesResponse
* @description     Gets conversation entry response using REST connect API
* ------------------------------------------------------------------------------------------------------
* @param           listTempEntries    Conversation Entry List
* @return          Returns https response
* ------------------------------------------------------------------------------------------------------ 
*/
 private HttpResponse getConversationEntriesResponse(String sEndPoint) {
     
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + sEndpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
     
       Http http = new Http();
       HttpResponse res = http.send(req);
     
       return res;
 }  
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     prepareConversationEntryWrapperList
* @description     Prepare ConversationEntry Wrapper from raw response
* ------------------------------------------------------------------------------------------------------
* @param           mapJsonResponse    Deserialized Map
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
 private List<ConversationEntry> prepareConversationEntryWrapperList(Map<String, Object> mapJsonResponse) {
     
            List<Object> listRawEntries = (List<Object>) mapJsonResponse.get('conversationEntries');
            List<ConversationEntry> listTempEntries = new List<ConversationEntry>(); 
            for (Object raw : listRawEntries) {
                Map<String, Object> convesationValueByParam = (Map<String, Object>) raw;
                ConversationEntry ce = new ConversationEntry();

                ce.sMessageText = (String) convesationValueByParam.get('messageText');
                Long dtConvTimeStamp    =  (Long) convesationValueByParam.get('serverReceivedTimestamp');
                
                ce.dtConvTimeStamp = DateTime.newInstance(dtConvTimeStamp);

                Map<String, Object> conversationSenderDetailByParam = (Map<String, Object>) convesationValueByParam.get('sender');
                ce.sRole = (conversationSenderDetailByParam != null && conversationSenderDetailByParam.containsKey('role')) ? (String) conversationSenderDetailByParam.get('role') : 'Unknown';
                listTempEntries.add(ce);
            }
     return listTempEntries;
 } 
    
/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     sortConversationEnties
* @description     Sort conversation entries list
* ------------------------------------------------------------------------------------------------------
* @param           listTempEntries    Conversation Entry List
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
 private void sortConversationEnties(List<ConversationEntry> listTempEntries) {
     for(integer count = listTempEntries.size() -1 ; count >= 0 ; count--){
               listEntries.add(listTempEntries[count]);
           }
 }
    
 

 public class ConversationEntry {
        public String sMessageText { get; set; }
        public String sRole { get; set; }
        public dateTime dtConvTimeStamp { get; set; }
    }
    
}