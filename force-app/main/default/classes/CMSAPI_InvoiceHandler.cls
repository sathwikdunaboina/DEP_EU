/*
* Contains methods to call Invoice API and fetch Invoice records in SF.
* 
* */

public inherited sharing class CMSAPI_InvoiceHandler {


 
        @InvocableMethod (label='fetchInvoicesFromAPI' description='This fetches Invoices from backend CMS')
    public static List<InvoiceAPIResultSummary> fetchInvoicesFromAPI(list<Id> accountIds) {
       
           Id accId = accountIds[0];
            List<InvoiceAPIResultSummary> invoiceResults = new List<InvoiceAPIResultSummary>();

        Account acc = [SELECT BillingCountryCode, CustomerId__c , (SELECT Id FROM Invoices__r)
                                , Invoices_Fetched_On__c
                                FROM Account
                                WHERE Id =:accId];
        
      String crnwtcc = acc.CustomerId__c.substringAfter('-');  // 1234
      String fullCustomerId = acc.CustomerId__c;

// Extract country code (first two letters before hyphen)
String countryCode = fullCustomerId.substringBefore('-');   // "IE"

// Lookup metadata row where the Name__c = country code
Invoice_Country_To_Source_Mapper__mdt mapper = [
    SELECT DeveloperName,
           Source_System_Code1__c,
           Source_System_Code2__c
    FROM Invoice_Country_To_Source_Mapper__mdt
    WHERE DeveloperName = :countryCode
    LIMIT 1
];

// Metadata value
String sourceSystemCode1=mapper.Source_System_Code1__c;
String sourceSystemCode2 = mapper.Source_System_Code2__c;

        // 1) Call GraphQL and get raw nodes
        List<InvoiceNode> nodes = getInvoices(crnwtcc, sourceSystemCode1,sourceSystemCode2);

        List<Invoice__c> invoicesToUpsert = new List<Invoice__c>();
       System.debug('Came her for the nodee' +nodes.size());
        
        // 2) Map each InvoiceNode -> CMSAPI_InvoiceData -> Invoice__c
        for (InvoiceNode node : nodes) {
            if (node == null) continue;

            CMSAPI_InvoiceData dto = new CMSAPI_InvoiceData();

            // Fill DTO (same structure as your existing CMSAPI_InvoiceData)
            dto.customerNumber = acc.CustomerId__c;
            dto.invoiceNumber  = node.salesInvoiceNumber;
            dto.status         = node.invoiceStatus;
            dto.invoiceType    = node.salesInvoiceType;
            dto.invoiceSubType = node.salesInvoiceSubType;
            dto.invoiceReferenceInformation = null; // set if you have any reference info

            // Dates: DTO expects String, parseToInvoiceObj uses Date.valueOf()
            // Date.valueOf() needs yyyy-MM-dd, Date.toString() returns yyyy-MM-dd
            if (node.issueDate != null) {
                dto.invoiceDate = String.valueOf(node.issueDate.date());
            }
            if (node.dueDate != null) {
                dto.dueDate = String.valueOf(node.dueDate.date());
            }

            // Amounts
            dto.invoiceAmount = new CMSAPI_InvoiceData.Amount();
            dto.invoiceAmount.amount       = node.totalInvoicesAmount;
            dto.invoiceAmount.currencyCode = node.currencyCode;
        
            dto.clearedAmount = new CMSAPI_InvoiceData.Amount();
            if(node.invoiceStatus=='CLEARED'){
            dto.clearedAmount.amount       = node.totalInvoicesAmount; // or actual cleared amount if API provides
            dto.clearedAmount.currencyCode = node.currencyCode;
            }
            
            else{
            dto.clearedAmount.amount       = null; // or actual cleared amount if API provides
            dto.clearedAmount.currencyCode = node.currencyCode;
            }

            // 3) Convert DTO -> Invoice__c using your existing logic
            Invoice__c inv = dto.parseToInvoiceObj();
            invoicesToUpsert.add(inv);
            System.debug('Number of Invoices aare' + invoicesToUpsert.size());
        }
        
          InvoiceAPIResultSummary resultSummary = new InvoiceAPIResultSummary();

          resultSummary.totalInvoicesFromAPI = nodes != null ? nodes.size() : 0;
        // 4) Upsert using External ID Invoice_Id__c
        if (!invoicesToUpsert.isEmpty()) {
            //Update the Account Invoices Fetched on Values as well
             acc.Invoices_Fetched_On__c = DateTime.now();
             update acc;
            Database.UpsertResult[] results =
                Database.upsert(invoicesToUpsert, Invoice__c.Invoice_Id__c, false);
            

               for (Database.UpsertResult result : results){
                	if (result.isSuccess()){
                    	resultSummary.totalInvoicesSaved ++;
                        
                    } else {
                        resultSummary.isSuccess = false;
                        System.debug(result.getErrors());
                    }
                }
            
             invoiceResults.add(resultSummary);

            // Optional logging of failures
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug(
                            'Invoice upsert failed. Invoice_Id__c='
                            + invoicesToUpsert[i].Invoice_Id__c
                            + ' Error=' + err.getStatusCode()
                            + ' - ' + err.getMessage()
                        );
                    }
                }
            }
        }
        
        else {
            InvoiceAPIResultSummary resultSummaryElse = new InvoiceAPIResultSummary();
            resultSummaryElse.isSuccess=false;
            resultSummaryElse.totalInvoicesFromAPI=0;
            resultSummaryElse.totalInvoicesSaved=0;
            invoiceResults.add(resultSummaryElse);
            
        }

        return invoiceResults;
    }

    /**
     * Low-level method:
     *  - Calls GraphQL
     *  - Returns list of InvoiceNode (raw data from API)
     */
    public static List<InvoiceNode> getInvoices(String customerCode, String recordSource1, String recordSource2) {
        //New code for dynamic query geberator 
List<String> customerIdEntries = new List<String>();

// Always add recordSource1
customerIdEntries.add(
    '                    { customerCode: "' + String.escapeSingleQuotes(customerCode) + '", ' +
    'recordSource: "' + String.escapeSingleQuotes(recordSource1) + '" }'
);

// Optionally add recordSource2 if present
if (!String.isBlank(recordSource2)) {
    customerIdEntries.add(
        '                    { customerCode: "' + String.escapeSingleQuotes(customerCode) + '", ' +
        'recordSource: "' + String.escapeSingleQuotes(recordSource2) + '" }'
    );
}
             String twoYearsBack = Datetime.now().addYears(-2).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        String customerIdBlock = String.join(customerIdEntries, ',\n');

// Final GraphQL query string
String gqlQueryD =
'query Invoices {\n' +
'    invoices(\n' +
'        filter: {\n' +
'            customerId: {\n' +
'                in: [\n' +
customerIdBlock + '\n' +
'                ]\n' +
'            }\n' +
          'issueDate: { ge: "' + twoYearsBack + '" }\n'+
'        }\n' +
'        first: 4000\n' +
'        pageNo: 0\n' +
'        orderBy: { issueDate: DESC }'+    
'    ) {\n' +
'        edges {\n' +
'            node {\n' +
'                issueDate\n' +
'                dueDate\n' +
'                salesInvoiceNumber\n' +
'                salesInvoiceType\n' +
'                salesInvoiceSubType\n' +
'                currencyCode\n' +
'                invoiceStatus\n' +
'                totalInvoicesAmount\n' +
'                recordSource\n' +
'            }\n' +
'        }\n' +
'        pageInfo {\n' +
'            totalCount\n' +
'        }\n' +
'    }\n' +
'}';
        
        CMSAPI__c settings = CMSAPI_SettingsManager.get();

       
        // Request body: ONLY "query" field – no variables, no operationName
        Map<String, Object> body = new Map<String, Object>{
            'query' => gqlQueryD
        };
// New code addition
               HttpResponse res = HttpCallout.send('callout:VFS_Global_APIs'+'/'+ settings.Invoice_Resource__c
                                                            , 'POST'
                                                            , new Map<String, String> { //headers
                                                            'X-Ibm-Client-Id' => settings.X_Ibm_Client_Id__c
                                                            ,'X-Ibm-Client-Secret' => settings.X_Ibm_Client_Secret__c
                                                            ,'Accept'=> '*/*'
                                                            ,'Content-Type' => 'application/json'
                                                            }
                                                            , JSON.serialize(body) //body
                                                        );


        System.debug('Status: ' + res.getStatus() + ' (' + res.getStatusCode() + ')');
        System.debug('Body: ' + res.getBody());

        if (res.getStatusCode() != 200) {
            throw new CalloutException('GraphQL callout failed with status code ' + res.getStatusCode());
        }

        GraphQLResponse wrapper =
            (GraphQLResponse) JSON.deserialize(res.getBody(), GraphQLResponse.class);

        // GraphQL-level errors (HTTP 200 but "errors" array present)
        if (wrapper != null && wrapper.errors != null && !wrapper.errors.isEmpty()) {
            System.debug('GraphQL errors: ' + JSON.serialize(wrapper.errors));
            throw new CalloutException('GraphQL returned errors: ' + wrapper.errors[0].message);
        }

        // Flatten to List<InvoiceNode>
        List<InvoiceNode> result = new List<InvoiceNode>();

        if (wrapper != null &&
            wrapper.data != null &&
            wrapper.data.invoices != null &&
            wrapper.data.invoices.edges != null) {

            for (InvoiceEdge edge : wrapper.data.invoices.edges) {
                if (edge != null && edge.node != null) {
                    result.add(edge.node);
                }
            }
        }

        return result;
    }

    // ======================
    //   GRAPHQL WRAPPERS
    // ======================

    public class GraphQLResponse {
        public InvoiceData data;
        public List<GraphQLError> errors;
    }

    public class GraphQLError {
        public String message;
        // Add locations, path, extensions if your API returns them
    }

    // Matches { "data": { "invoices": { ... } } }
    public class InvoiceData {
        public Invoices invoices;
    }

    public class Invoices {
        public List<InvoiceEdge> edges;
    }

    public class InvoiceEdge {
        public InvoiceNode node;
    }

    public class InvoiceNode {
        public Datetime issueDate;
        public Datetime dueDate;
        public String salesInvoiceNumber;
        public String salesInvoiceType;
        public String salesInvoiceSubType;
        public String currencyCode;
        public String invoiceStatus;
        public Decimal totalInvoicesAmount;
    }
    
    
        public class InvoiceAPIException extends Exception {}


    public class InvoiceAPIResultSummary {
    	
        @InvocableVariable public boolean isSuccess = true;
        @InvocableVariable public Integer totalInvoicesFromAPI = 0;
        @InvocableVariable public Integer totalInvoicesSaved = 0;
    }
    
}