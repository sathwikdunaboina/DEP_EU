/*
 * Created: Prabha
 * Manages the platform cache 'CXPCache'
 * 
 * */
public class CXPCacheManager {
    public static final String PARTITION = 'CXPCache';
    public static Boolean enabled {get; set;}

    static {
        enabled = true;
    }
    
    private static Cache.OrgPartition getPartition() {
        return Cache.Org.getPartition('local.' + PARTITION);
    }
    
    public static Object getFromSession(String key) {
        if (Cache.Session.contains('local.' + PARTITION + '.'+ key)) {
        	return Cache.Session.get('local.' + PARTITION + '.'+ key);
        }
        return null;
    }
    
    public static void putToSession(String key, Object obj) {
		Cache.Session.put('local.' + PARTITION + '.'+ key, obj);
    }
    
    public static Object get(String key) {
        return enabled ? getPartition().get(key) : null;
    }

    public static void put(String key, Object value) {
        if (enabled) {
        	getPartition().put(key, value, 172800, Cache.Visibility.ALL, false);
        }
    }

    /*public static void remove(String key) {
        if (enabled) {
        	getPartition().remove(key);
        }
    }*/

}