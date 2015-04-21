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
@isTest(seeAllData=true)
private class TBN_TestQuestionAnswerToProduct 
{
    static testMethod void testQuestionAnswerToProduct() 
    {
        Product_Group__c objProductGroup = new Product_Group__c(Name = 'PG 1');
        insert objProductGroup;
        system.assert(objProductGroup.Name == 'PG 1');
        
        Product2 objProduct = new Product2(Name = 'Product 1', family = 'test family');
        insert objProduct;
        system.assert(objProduct.Name == 'Product 1');
        
        PricebookEntry objPriceBookEntry = new PricebookEntry(
                                                            UnitPrice = 300,
                                                            PriceBook2Id = [Select id from PriceBook2 where isStandard = true].Id,
                                                            Product2Id = objProduct.Id,
                                                            IsActive = true
                                                            );

        insert objPriceBookEntry ;
        system.assert(objPriceBookEntry.UnitPrice == 300);
        
        Opportunity objOpp = new Opportunity(Name = 'Test Demo Opportunity', 
                                            StageName = 'Lead', 
                                            CloseDate = Date.today() 
                                            );   
        insert objOpp;
        system.assert(objOpp.Name == 'Test Demo Opportunity');
        
        
        OpportunityLineItem objOLI = new OpportunityLineItem(
                                                        pricebookentryid = objPriceBookEntry.Id, 
                                                        Quantity = 1, 
                                                        OpportunityId = objOpp.Id, 
                                                        TotalPrice = 1000
                                                        );
        insert objOLI;
        system.assert(objOLI.Quantity == 1);
        
        
        Question__c objQuestion1 = new Question__c(
                                                Question__c = 'What is your name ?', 
                                                Type__c = 'Textarea', 
                                                Values__c = 'Test1,Test2', 
                                                Product_Group__c = objProductGroup.Id
                                                );
        insert objQuestion1;
        system.assert(objQuestion1.Question__c == 'What is your name ?');
        
        Question__c objQuestion2 = new Question__c(
                                                Question__c = 'How many ansers you have ?', 
                                                Type__c = 'picklist', 
                                                Values__c = 'Test1,Test2', 
                                                Product_Group__c = objProductGroup.Id
                                                );
        insert objQuestion2;
        system.assert(objQuestion2.Question__c == 'How many ansers you have ?');
        
        Question__c objQuestion3 = new Question__c(
                                                Question__c = 'How many ansers you have ?', 
                                                Type__c = 'picklist', 
                                                Values__c = 'Test1,Test2', 
                                                Product_Group__c = objProductGroup.Id
                                                );
        insert objQuestion3;
        
        list<Question__c> lstQuestions1 = new list<Question__c>{objQuestion1, objQuestion2};
        
        Answer__c objAnswer1 = new Answer__c(
                                            Answer__c = 'Niraj',
                                            Opportunity__c = objOpp.Id,
                                            Product__c = objProduct.Id,
                                            Question__c = objQuestion1.Id
                                            );
                                            
        insert objAnswer1;
        system.assert(objAnswer1.Answer__c == 'Niraj');
        
        Answer__c objAnswer2 = new Answer__c(
                                            Answer__c = 'Singh',
                                            Opportunity__c = objOpp.Id,
                                            Product__c = objProduct.Id,
                                            Question__c = objQuestion2.Id
                                            );
                                            
        insert objAnswer2;
        
        ApexPages.currentPage().getParameters().put('oppId', objOpp.Id);
        
        Test.startTest();
        
        TBN_QuestionAnswerToProduct objQuestionAnswerToProduct = new TBN_QuestionAnswerToProduct();
        TBN_QuestionAnswerToProduct.wrapperQuestionAnswerToProduct objWrapperClass1 = new TBN_QuestionAnswerToProduct.wrapperQuestionAnswerToProduct(objProduct.Id, objOpp.Id, lstQuestions1);
        
        objQuestionAnswerToProduct.getQuestionAnswerForProduct();
        objQuestionAnswerToProduct.insertAnswers();
        objQuestionAnswerToProduct.saveAnswers();
        
        
        Test.stopTest();
    }
}