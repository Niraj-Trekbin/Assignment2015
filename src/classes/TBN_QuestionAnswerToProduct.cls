/**
@ClassName        	:   TBN_QuestionAnswerToProduct
@Date               :   15/Apr/2015
@Description        :   To get answer for questions related to product.
*/
public with sharing class TBN_QuestionAnswerToProduct 
{
	//Variables
	private String strOpportunityId;
	public Boolean showPageMessage											{ get; set; }
	public List<wrapperQuestionAnswerToProduct> getQuestionAnswerToProduct	{ get; set; }
	
	/************Constructor***********/
	public TBN_QuestionAnswerToProduct()
	{
		// Checks whether url has Opportunity Id with its value or not.
		if(Apexpages.currentPage().getParameters().containsKey('oppId') &&
		Apexpages.currentPage().getParameters().get('oppId').length() >= 15 &&  
		String.valueOf(((Id)(Apexpages.currentPage().getParameters().get('oppId')) ).getSObjectType()) == 'Opportunity')  
		{
	        strOpportunityId = Apexpages.currentPage().getParameters().get('oppId');
			
			List<OpportunityLineItem> lstOLI  = [Select Id, Name, OpportunityId, Product2Id 
												From OpportunityLineItem
												Where OpportunityId =: strOpportunityId];
			
			if(lstOLI.isEmpty())
			{
				showPageMessage = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No product added to this opportunity'));
			}
			else
				getQuestionAnswerForProduct(lstOLI);
		}
	}
	/******End Constructor ********/
	
	/*********Wrapper class*********/
	public class wrapperQuestionAnswerToProduct
	{
	
	 //public List<Question__c> parent{ get; set; }
	 public Product2 objProdAsGParent							{ get;set; }
	 public Map<Question__c, List<Answer__c>> mapQuesAnswers	{ get;set; }
	
	 public wrapperQuestionAnswerToProduct(Product2 objProdAsGParent, List<Question__c> lstQuestions)
	 {
	     //parent = p;
	     //gparent = [Select Id,Name from Product2 where id = :gp limit 1];
	 }
	}
	/******* End Wrapper class ******/
	
	/*********To get question and answer related to product*********/
	public void getQuestionAnswerForProduct(List<OpportunityLineItem> lstOLI)
	{
		Set<String> setProductGroupIds = new Set<String>();
		Set<String> setProduct2Ids = new Set<String>();
		Map<String, List<OpportunityLineItem>> mapProdIdsOLIs = new Map<String, List<OpportunityLineItem>>();
		Map<String, List<OpportunityLineItem>> mapOppIdsOLIs = new Map<String, List<OpportunityLineItem>>();
		Map<String, List<Product2>> mapPGIdsProducts = new Map<String, List<Product2>>();
		Map<String, List<Question__c>> mapPGIdsQuestions = new Map<String, List<Question__c>>();
		
		for(OpportunityLineItem objOLI : lstOLI)
		{
			setProductGroupIds.add(objOLI.Product2.ProductGroupId__c);
			setProduct2Ids.add(objOLI.Product2Id);
			
			//Map of Opportunitiy Ids and their related list of OLIs.
			if(mapOppIdsOLIs.containsKey(objOLI.OpportunityId))
				mapOppIdsOLIs.get(objOLI.OpportunityId).add(objOLI);
			else
				mapOppIdsOLIs.put(objOLI.OpportunityId, new List<OpportunityLineItem>{objOLI});
				
			//Map of Product Ids and their related list of OLIs.
			if(mapProdIdsOLIs.containsKey(objOLI.OpportunityId))
				mapProdIdsOLIs.get(objOLI.Product2Id).add(objOLI);
			else
				mapProdIdsOLIs.put(objOLI.Product2Id, new List<OpportunityLineItem>{objOLI});
		}
		
		//Quering Products related to ProductGroup 
		for(Product2 objProduct : [Select Id, Name, ProductGroupId__c From Product2 Where ProductGroupId__c IN: setProductGroupIds])
		{
			if(mapPGIdsProducts.containsKey(objProduct.ProductGroupId__c))
				mapPGIdsProducts.get(objProduct.ProductGroupId__c).add(objProduct);
			else
				mapPGIdsProducts.put(objProduct.ProductGroupId__c, new List<Product2>{objProduct});
		}
		
		//Quering Questions related to ProductGroup 
		for(Question__c objQuestion : [Select Id, Name, ProductGroupId__c From Question__c Where ProductGroupId__c IN: setProductGroupIds])
		{
			if(mapPGIdsQuestions.containsKey(objQuestion.ProductGroupId__c))
				mapPGIdsQuestions.get(objQuestion.ProductGroupId__c).add(objQuestion);
			else
				mapPGIdsQuestions.put(objQuestion.ProductGroupId__c, new List<Question__c>{objQuestion});
		}
		
	}
}