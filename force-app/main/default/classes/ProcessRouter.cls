/**
 * Central controller for directing processing via either
 * 1) in-org (legacy) code
 * 2) installed (internal VFS) packages
 * 
 * @author matei.lunca@fluidogroup.com
 * 
 * TODO migrate to package, call via [namespace].[pckg].[check]
 * TODO if good for architecture: make invocable and use in flows
 */
public with sharing class ProcessRouter {
    
	public static boolean useVFSPackageProcess(){
		boolean usePackageProcess = FeatureManagement.checkPermission('GoldenCopy');

		if(usePackageProcess){
			System.debug('ProcessRouter.useVFSPackageProcess(): usePackageProcess = true, using only package processes');
		}
		else{
			System.debug('ProcessRouter.useVFSPackageProcess(): usePackageProcess = false, using only legacy processes');
		}

		return usePackageProcess;
	}
	
}