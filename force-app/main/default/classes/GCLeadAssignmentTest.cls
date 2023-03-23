/**
 * Main (bulk) tests for the process of Factory Order upsert,
 * to Lead creation, and Lead assignment to a User or Queue.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-10 creation
 */
@isTest
public class GCLeadAssignmentTest {

	//initialise GoldenCopy user, permission and settings to RUN automation
	@testSetup
	static void initGoldenCopyTesting() {
		GCTestFactory.initGoldenCopyLeadsQueue();
		GCTestFactory.initGoldenCopyCustomSettings();
		User runningUser = GCTestUtil.createAdminUser();
		GCTestUtil.addGCPermsToUser(runningUser);
	}

	@isTest
	private static void generateAndAssignLeadsBulk(){
		//set up data generation amounts
		//and percentage [0-100] chances for match at points of interest
		//depending on test case, watch out with 0 and 100
		final Integer amountOfOrders = 15;
		final Integer amountOfTerritoryManagers = 2;
		final Integer amountOfAccounts = 2;
		final Integer pctChanceForDealerMatch = 70;

		//start generating data; most stuff happens in the factory
        List<FactoryOrder__c> orders = GCTestFactory.generateFactoryOrders(amountOfOrders, 'fo');

		//initialise User to be assigned Leads based on DealerId and model
		User terrManagerUSer = GCTestUtil.getTerrManagerUser();
        List<TerritoryManager__c> terrManagers = GCTestFactory.generateTerritoryManagers(amountOfTerritoryManagers, 'tm', terrManagerUSer);
        insert terrManagers;

		Map<Id, TerritoryManager__c> terrManagersMap = new Map<Id, TerritoryManager__c>();
		terrManagersMap.putAll(terrManagers);
		List<Id> terrManagerIds = new List<Id>(terrManagersMap.keySet());

        List<Account> accounts = GCTestFactory.generateAccount(amountOfAccounts, 'zd', terrManagerIds, pctChanceForDealerMatch);
		insert accounts;
        
		AccountWrapper.prettyPrintTestData(accounts);

		User runningUser = GCTestUtil.getAdminUser();
        System.runAs(runningUser){
        	Test.startTest();
        
        	insert orders;
			Set<Id> orderIds = (new Map<Id, SObject>(orders)).keySet();

        	Test.stopTest();
			Test.getEventBus().deliver();
             
            //get generated test data by critical value:
			//ownership by group, manager, null (bad), or current user (bad)
			Integer leadsTotal = (Integer) [SELECT COUNT(Id) FROM Lead WHERE FactoryOrder__c IN :orderIds][0].get('expr0');

			LeadWrapper.SegmentationByOwner segmentationByOwner
				= new LeadWrapper.SegmentationByOwner(LeadWrapper.getLeadsByFactoryOrderIds(orderIds));
			segmentationByOwner.segmentLeadsByOwner(runningUser);
			segmentationByOwner.prettyPrintTestData(leadsTotal);
			
            System.assert(!segmentationByOwner.allLeads.isEmpty(), 'Leads should be generated.');
            System.assert(!segmentationByOwner.leadsOwnedByGroup.isEmpty(), 'Some leads should be assigned to a Queue.');
			System.assert(!segmentationByOwner.allLeads.isEmpty(), 'Some leads should be assigned to a Territory Manager.');
			System.assert(segmentationByOwner.leadsOwnedByWrongUser.isEmpty(), 'Leads should not be owned by the default (running) User (VFS specific).');
			System.assert(segmentationByOwner.leadsWithoutOwner.isEmpty(), 'Leads should not have a null Owner (system default).');
        }
    }
    
	@isTest
    private static void insertBadOrders(){
		//set up data generation amounts
		//and percentage [0-100] chances for match at points of interest
		//depending on test case, watch out with 0 and 100
		final Integer amountOfOrders = 2;
		final Integer amountOfTerritoryManagers = 1;
		final Integer amountOfAccounts = 1;
		final Integer pctChanceForDealerMatch = 70;

		//start generating data; most stuff happens in the factory
        List<FactoryOrder__c> orders = GCTestFactory.generateBadFactoryOrders(amountOfOrders, 'fo');

		//initialise User to be assigned Leads based on DealerId and model
		User terrManagerUSer = GCTestUtil.getTerrManagerUser();
        List<TerritoryManager__c> terrManagers = GCTestFactory.generateTerritoryManagers(amountOfTerritoryManagers, 'tm', terrManagerUSer);
        insert terrManagers;

		Map<Id, TerritoryManager__c> terrManagersMap = new Map<Id, TerritoryManager__c>();
		terrManagersMap.putAll(terrManagers);
		List<Id> terrManagerIds = new List<Id>(terrManagersMap.keySet());

        List<Account> accounts = GCTestFactory.generateAccount(amountOfAccounts, 'zd', terrManagerIds, pctChanceForDealerMatch);
		insert accounts;
        
		AccountWrapper.prettyPrintTestData(accounts);

		User runningUser = GCTestUtil.getAdminUser();
        System.runAs(runningUser){
        	Test.startTest();
        
        	insert orders;
			Set<Id> orderIds = (new Map<Id, SObject>(orders)).keySet();

        	Test.stopTest();
			Test.getEventBus().deliver();
             
            //get generated test data by critical value:
			//ownership by group, manager, null (bad), or current user (bad)
			Integer leadsTotal = (Integer) [SELECT COUNT(Id) FROM Lead WHERE FactoryOrder__c IN :orderIds][0].get('expr0');

			LeadWrapper.SegmentationByOwner segmentationByOwner
				= new LeadWrapper.SegmentationByOwner(LeadWrapper.getLeadsByFactoryOrderIds(orderIds));
			segmentationByOwner.segmentLeadsByOwner(runningUser);
			segmentationByOwner.prettyPrintTestData(leadsTotal);
			
			List<ErrorLog__c> errorLogs = [SELECT AssociatedRecord__c,ClassName__c,CreatedById,CreatedDate,CurrencyIsoCode,ErrorMessage__c,HTTPStatusCode__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LineNumber__c,MethodName__c,Name,OwnerId,RequestHeaders__c,Request__c,StackTrace__c,SystemModstamp FROM ErrorLog__c];
			String errorLogsInfo = '' + errorLogs;
			System.debug('errorLogs: ' + errorLogsInfo);

            System.assert(segmentationByOwner.allLeads.isEmpty(), 'Leads should NOT be generated.');
			System.assert(errorLogsInfo.contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST: Brand: bad value for restricted picklist field: Trabant.'),
				'Expected bad picklist value error.');
        }
    }
}