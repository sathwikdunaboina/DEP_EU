/**
 * Factory for generating test data with specific relations
 * between objects. Also can generate matching or non-matching
 * records in related objects to simulate real-life data.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-15 creation
 */
public class GCTestFactory {
    
	public static final String LEAD_QUEUE = 'Unallocated_Leads';
	public static final String DEALER_ID_BASE = 'DLR-';

	//TODO any adjustment to factory to produce records outside of testing +
	//idem for deleting test data (when using the methods for real data)
	//TODO build scenarios for happy flows and edge cases
	//TODO produce real/test data that simulates country-specific data
	
	public static void initGoldenCopyCustomSettings(){
		VFSAdminCustomSettings__c gc = new VFSAdminCustomSettings__c();
		//GoldenCopy__c gc = new GoldenCopy__c();
		gc.UnallocatedLeadsQueue__c = LEAD_QUEUE;
		gc.SkipValidation__c = false;
		gc.SkipAutomation__c = false;
		insert gc;
	}

	public static void initGoldenCopyLeadsQueue(){
		Group testGroup = new Group(Name=LEAD_QUEUE, Type='Queue');
		insert testGroup;

		System.runAs(new User(Id = UserInfo.getUserId())){
    		QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
    		insert testQueue;
		}
	}

	public static List<FactoryOrder__c> generateFactoryOrders(integer amount, String salt){
		List<FactoryOrder__c> result = new List<FactoryOrder__c>();

		if(amount < 1){
			amount = 1;
		}

		salt = salt.trim();

		for(integer i = 0; i < amount; i++){
			String ix = ('' + i).leftPad(3, '0');
			FactoryOrder__c testRecord = new FactoryOrder__c (
				Brand__c = 'VT',
				ContactLastName__c = 'ContactLastName' + salt + ix,
				Country__c = 'NL',
				DealerId__c = DEALER_ID_BASE + ix,
				EndCustomerAddress1__c = 'EndCustomerAddress1' + salt + ix,
				EndCustomerName__c = 'EndCustomerName' + salt + ix,
				EndCustomerPhone__c = '000 000 ' + ix,
				EndCustomerCity__c = 'EndCustomerCity' + salt + ix,
				Name = 'TestName' + salt + ix,
				MainDealerName__c = 'DealerName' + salt + ix
			);

			result.add(testRecord);
		}

		return result;
	}

	//generate orders that will make the rest of the process fail,
	//but the orders themselves do not fail to insert with errors such as:
	//System.DmlException: Insert failed [...] STRING_TOO_LONG
	public static List<FactoryOrder__c> generateBadFactoryOrders(integer amount, String salt){
		List<FactoryOrder__c> result = new List<FactoryOrder__c>();

		if(amount < 1){
			amount = 1;
		}

		salt = salt.trim();

		for(integer i = 0; i < amount; i++){
			String ix = ('' + i).leftPad(3, '0');
			FactoryOrder__c testRecord = new FactoryOrder__c (
				Brand__c = 'Trabant',
				ContactLastName__c = '',
				Country__c = '',
				DealerId__c = '',
				EndCustomerAddress1__c = '',
				EndCustomerName__c = '',
				EndCustomerCity__c = '',
				Name = 'VT342796hfh893h6jo9jsod34jlq54jo98lj9ol2s3j9dl1e2yje23doya3yjoyjor84' + salt + ix,
				MainDealerName__c = ''
			);

			result.add(testRecord);
		}

		return result;
	}

	public static List<TerritoryManager__c> generateTerritoryManagers(integer amount, String salt, User u){
		List<TerritoryManager__c> result = new List<TerritoryManager__c>();

		if(amount < 1){
			amount = 1;
		}

		salt = salt.trim();

		for(integer i = 0; i < amount; i++){
			String ix = ('' + i).leftPad(3, '0');
			TerritoryManager__c tm = new TerritoryManager__c(
				Email__c = 'territory.manager' + ix + '@test.com',
				Name = 'Territorial manager ' + ix + salt,
				OwnerId = u.Id,
				User__c = u.Id
			);

			result.add(tm);
		}

		return result;
	}

	//pctChanceForDealerMatch is just indication for this method,
	//actual % depends on Leads generated with matching DEALER_ID_BASE
	public static List<Account> generateAccount(integer amount, String salt, List<Id> terrManagers, Integer pctChanceForDealerMatch){
		List<Account> result = new List<Account>();

		if(amount < 1){
			amount = 1;
		}

		salt = salt.trim();

		for(integer i = 0; i < amount; i++){
			String ix = ('' + i).leftPad(3, '0');
			Account acc = new Account();

			//set the critical Dealer Id that directs Lead ownership
			if(Math.random() * 100 < pctChanceForDealerMatch){
				acc.CustomerId__c = DEALER_ID_BASE + ix;
			}
			else{
				acc.CustomerId__c = 'TST-' + salt + ix; //we could leave it empty
			}

			acc.Name = 'Test Account ' + ix + salt;
			acc.BillingCountryCode = 'NL';
			acc.TerritoryManager__c = GCTestUtil.getRandomElem(terrManagers, 20);

			result.add(acc);
		}

		return result;
	}
}