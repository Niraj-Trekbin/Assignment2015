/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class Test_TBN_CaseToEntitlement_Webservice
{
    static testMethod void Test_CaseToEntitlement_Webservice() 
    {   
        //Create Account with account number.
        Account objAccount1 = new Account(Name = 'TestAccount1',
                                          AccountNumber='101'
                                          );

        insert objAccount1;
        system.assert(objAccount1.Name == 'TestAccount1');
        
        //Create Account without account number.
        Account objAccount2 = new Account(Name = 'TestAccount2');

        insert objAccount2;
        system.assert(objAccount2.Name == 'TestAccount2');
        
        //Create Entitlement.
        Entitlement objEntitlement = new Entitlement(Name = 'TestEntitlement',
                                                  AccountId=objAccount1.id
                                                  );

        insert objEntitlement;
        system.assert(objEntitlement.Name == 'TestEntitlement');
        
        //Create Asset.
        Asset objAsset = new Asset(Name = 'TestAsset',
                                  AccountId=objAccount1.id
                                  );
        insert objAsset;
        system.assert(objAsset.Name == 'TestAsset');
        
        //Create Contact with account which having account number.
        Contact objContact = new Contact(LastName = 'TestContact',
                                          AccountId=objAccount1.id,
                                          phone='123456789'
                                          );

        insert objContact;
        system.assert(objContact.LastName == 'TestContact');
        
        //Create Case with account which having account number.
        Case objCase = new Case(Status = 'New', 
                                AssetId = objAsset.id, 
                                ContactId = objContact.id,
                                EntitlementId = objEntitlement.id,
                                AccountId=objAccount1.id
                                );
        insert objCase;
        system.assert(objCase.Status == 'New');
        
        //Create Case with account which not having account number.
        Case objCase2 = new Case(Status = 'New',
                                AssetId = objAsset.id,
                                ContactId = objContact.id,
                                EntitlementId = objEntitlement.id,
                                AccountId=objAccount2.id
                                );
        insert objCase2;
        system.assert(objCase2.Status == 'New');

        Test.startTest();

        //Usecase1:Passing all three parameters 
        TBN_CaseToEntitlement_Webservice.getAccountContactAssetRelatedToCase(objCase.id, '123456789', '101');
        
        //Usecase2:Passing only two parameters, not passing Account number as last param. 
        TBN_CaseToEntitlement_Webservice.getAccountContactAssetRelatedToCase(objCase2.id,'123456789', '');

        Test.stopTest(); 
        
    }
}