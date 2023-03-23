/**
 * Utility functions to help in unit testing:
 * <ul>
 * <li>
 * - turning verbose logging on/off (when developing new, complex tests)
 * </li>
 * <li>
 * - provisioning Users for RUNNING tests
 * </li>
 * <li>
 * - provisioning separate Users for some test results, such as record Ownership
 * </li>
 * <li>
 * - assigning permissions for simulating "Golden Copy" package
 * </li>
 * <li>
 * - low level help utils that are definitely for tests (get random element)
 * </li>
 * </ul>
 * @author matei.lunca@fluidogroup.com 2022-07-15 creation
 */
public without sharing class GCTestUtil {
    
	public static final boolean LOG_TESTS = true;

	public static final String RUNNING_GC_USER_NAME = 'goldenAdmin098765@testorg.com';

	public static User createAdminUser(){
		Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User adminUser = new User(alias = 'standt', email=RUNNING_GC_USER_NAME,
            			 emailencodingkey='UTF-8', firstname='Test', lastname='goldenAdmin098765', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id, CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username=RUNNING_GC_USER_NAME);
        insert adminUser;

		return adminUser;
	}

	public static User getAdminUser(){
		User u = [Select Id from User where username = :RUNNING_GC_USER_NAME];

		if(u == null){ //nice try, but if GC elements where not created before this get, not going to work
			createAdminUser();
			u = [Select Id from User where username = :RUNNING_GC_USER_NAME];
		}

		return u;
	}

	public static void addGCPermsToUser(User u){
		System.runAs(new User(Id = Userinfo.getUserId())) { //avoid MIXED_DML_EXCEPTION
			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'GoldenCopyLeadManagement'];
			insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
		}
	}

	public static User getTerrManagerUser(){
		Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
        User terrManagerUser = new User(alias = 'standt', email='terrManagerUser@testorg.com',
            			 emailencodingkey='UTF-8', firstname='Test', lastname='terrManagerUser', languagelocalekey='en_US',
            			 localesidkey='en_US', profileid = profileObj.Id, CountryCode = 'NL',
            			 timezonesidkey='America/Los_Angeles', username='terrManagerUser@testorg.com');
        insert terrManagerUser;

		return terrManagerUser;
	}

	public static Id getRandomElem(List<Id> elems, Integer pctChanceForNull){
		try {
			pctChanceForNull = pctChanceForNull < 0 || pctChanceForNull > 100 ? pctChanceForNull = 50 : pctChanceForNull;
			
			if(Math.random() * 100 < pctChanceForNull){
				return null;
			}

			Integer ix = ( Math.random() * (elems.size()-1) ).intValue();
			return elems[ix];
		}
		catch(Exception ex){
			return null;
		}
	}

}