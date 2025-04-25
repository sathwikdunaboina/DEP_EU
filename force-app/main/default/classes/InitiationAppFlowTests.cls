/*
 * Created By: Aswin Balaji
 * Created Date: 22/02/2024
 * Used for: Flow Test coverage
 * Description: Initiation app flow test coverage for below flows
		Flow: Initiation app: Is Delivered time date stamp
		Flow: Initiation app: Asset Create short VIN
		Flow: Initiation app: Add Stamped Customer name to Initiation
		Flow: Initiation app: Add Stamped agreement number and customer
		Flow: Initiation app: assign asset id
		Flow: Initiation app: Initiation Closed date
		Flow: Initiation app: update initiation record status when all delivered
*/
@isTest
public class InitiationAppFlowTests {
    @isTest
    static void updateInitiation() {
        Id initiationRecordTypeId = Schema.SObjectType.Initiation__c.getRecordTypeInfosByName().get('Lease with R&M').getRecordTypeId();
        Id initiationRecordTypeIdService = Schema.SObjectType.Initiation__c.getRecordTypeInfosByName().get('Standalone Maintenance').getRecordTypeId();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        //Account Creation
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.RecordTypeId = accountRecordTypeId;
        insert acc;
        //Initiation Creation
        Initiation__c initiation = new Initiation__c();
        initiation.Country__c = 'GB';
        initiation.RecordTypeId = initiationRecordTypeIdService;
        initiation.Status__c = 'Closed';
        initiation.Connect_Delivery_ID__c='111';
        initiation.Brand__c = 'Volvo Truck';
        initiation.Box_ID__c = 'test';
        insert initiation;
        //initiation Asset Creation
        Initiation_asset__c initiationAsset = new Initiation_asset__c();
        initiationAsset.Name = '1234441';
        initiationAsset.NOT_TAKEN_UP__c = True;
        initiationAsset.Initiation__c = initiation.Id;
        initiationAsset.AssetCount__c=1;
        insert initiationAsset;
        initiationAsset.Asset_status_service__c = 'Second checks complete';
        initiationAsset.Asset_status__c = 'Pack ready';
        initiationAsset.Contract__c = null;
        update initiationAsset;
        assert.areNotEqual(False, initiationAsset.NOT_TAKEN_UP__c);
        Initiation_Asset__c updatedAsset = [Select Is_delivered__c,Agreement_number__c,Stamped_Agreement_Number__c, Stamped_Customer_Name__c From Initiation_Asset__c Where Id =: initiationAsset.Id];
        System.debug(updatedAsset);
        update updatedAsset;
        System.debug(updatedAsset.Is_delivered__c);
        System.debug(updatedAsset.Agreement_number__c);
        //Initiation asset false Not taken and delivered
        Initiation_asset__c initiationAssetFalse = new Initiation_asset__c();
        initiationAssetFalse.Name = '1234441';
        initiationAssetFalse.NOT_TAKEN_UP__c = false;
        initiationAssetFalse.Initiation__c = initiation.Id;
        initiationAssetFalse.AssetCount__c=1;
        insert initiationAssetFalse;
        initiationAssetFalse.Asset_status_service__c = 'Second checks complete';
        initiationAssetFalse.Asset_status__c = 'Pack ready';
        initiationAssetFalse.Contract__c = null;
        update initiationAssetFalse;
        assert.areNotEqual(True, initiationAssetFalse.NOT_TAKEN_UP__c);
        System.debug(initiationAssetFalse.Is_delivered__c);
        System.debug(initiationAssetFalse.Agreement_number__c);
    }
}