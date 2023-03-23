/**
 * Wrapper for easy processing.
 * 
 * @author matei.lunca@fluidogroup.com 2022-07-15 creation
 */
public with sharing class LeadWrapper {
	
	private Lead lead;

    public LeadWrapper(Lead ld) {
		this.lead = ld;
    }

	//Address,AnnualRevenue,Brand__c,City,Company,ConvertedAccountId,ConvertedContactId,ConvertedDate,
	//ConvertedOpportunityId,Country,CountryCode,CreatedById,CreatedDate,CurrencyIsoCode,
	//Dealer_Delivery_Date__c,Dealer_Name__c,Description,Email,EndCustomerPostalCode__c,FactoryOrderNr__c,,
	//IndividualId,Industry,Initials__c,IsConverted,LastActivityDate,LastModifiedById,LastModifiedDate,LastName,
	//LastReferencedDate,LastTransferDate,LastViewedDate,Latitude,LeadSource,Longitude,MasterRecordId,MiddleName,
	//MobilePhone,NumberOfEmployees,OwnerName__c,Participated__c,PartnerAccountId,Phone,PostalCode,Rating,
	//State,StateCode,Street,Suffix,SystemModstamp
	public String toPrettyPrintString(){
		if(lead == null){
			return '[Lead is null]';
		}

		//Queue owner has no Name field, so give useful info
		String ownerInfo = '' + lead.OwnerId;
		if(String.isBlank(lead.Owner.Name)){
			ownerInfo += ' (Owner type: ' + lead.OwnerId.getSObjectType().getDescribe().getName();
		}
		else{
			ownerInfo += ' (Owner name: ' + lead.Owner.Name;
		}

		String result = '[Lead: ' +
		'\n\t Id = ' + lead.Id +
		'\n\t Name = ' + lead.Name +
		'\n\t FactoryOrder = ' + lead.FactoryOrder__c +
		'\n\t FactoryOrder.DealerId = ' + lead.FactoryOrder__r.DealerId__c +
		'\n\t Status = ' + lead.Status +
		'\n\t Owner = ' + ownerInfo + ')' +
		+ ']';

		return result;
	}

	//use only during test development to save on resources
	public static void printLeads(List<Lead> leads){
		for(Lead l : leads){
			LeadWrapper lw = new LeadWrapper(l);
			System.debug(lw.toPrettyPrintString());
		}
	}

	public static List<Lead> getLeadsByFactoryOrderIds(Set<Id> orderIds){
		return	[SELECT Id, Name, Status, OwnerId, Owner.Name, FactoryOrder__c, FactoryOrder__r.DealerId__c 
				FROM Lead WHERE FactoryOrder__c IN :orderIds];
	}

	/**
	 * Accessible inner class for grouping data segments according
	 * to how business processes flow.
	 * 
	 * @author matei.lunca@fluidogroup.com 2022-07-20 creation
	 */
	public class SegmentationByOwner {
		public List<Lead> allLeads				= new List<Lead>();
		public List<Lead> leadsOwnedByGroup		= new List<Lead>();
		public List<Lead> leadsOwnedByAllUsers	= new List<Lead>();
        public List<Lead> leadsOwnedByWrongUser	= new List<Lead>();
		public List<Lead> leadsWithoutOwner		= new List<Lead>();

		public SegmentationByOwner(List<Lead> allLeads){
			this.allLeads = allLeads;
		}

		public void segmentLeadsByOwner(User runningUser){
			for(Lead l : allLeads){
				if(l.OwnerId.getSObjectType().getDescribe().getName() == 'Group'){
					leadsOwnedByGroup.add(l);
				}
				else if( String.isNotBlank( l.Owner.Name ) ){
					leadsOwnedByAllUsers.add(l);
				}
				else if(l.OwnerId == runningUser.Id){
					leadsOwnedByWrongUser.add(l);
				}
				else if(l.OwnerId == null){
					leadsWithoutOwner.add(l);
				}
				else{
					System.debug('WARN: Lead with unexpected owner: ' + (new LeadWrapper(l)).toPrettyPrintString() );
				}
			}
		}

		public void prettyPrintTestData(Integer leadsTotal){
			if(GCTestUtil.LOG_TESTS){
				System.debug('Leads created: ');
				System.debug('\t total = ' + leadsTotal);
				System.debug('\t with group (queue) as owner = ' + leadsOwnedByGroup.size());
				System.debug('\t with user as owner = ' + leadsOwnedByAllUsers.size());
				System.debug('\t out of which the user is default = ' + leadsOwnedByWrongUser.size());
				System.debug('\t without owner = ' + leadsWithoutOwner.size());

				//use only during test development to save on resources
				printLeads(leadsOwnedByGroup);
				printLeads(leadsOwnedByAllUsers);
				printLeads(leadsOwnedByWrongUser);
				printLeads(leadsWithoutOwner);
			}
		}
	}
}