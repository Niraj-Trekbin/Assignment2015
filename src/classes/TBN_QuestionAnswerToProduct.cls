/**
@ClassName          :   TBN_QuestionAnswerToProduct
@Date               :   15/Apr/2015
@Description        :   To get answer for questions related to product.
*/
public with sharing class TBN_QuestionAnswerToProduct
{
	//Variables
	private String strOpportunityId;
	public Boolean showPageMessage                                          { get; set; }
	public List<wrapperQuestionAnswerToProduct> lstWrapperClass				{ get; set; }
	public boolean isAnswerInput											{ get; set; }
	public Answer__c objAnswer												{ get; set; }
	public boolean isbtn													{ get; set; }
	public Integer intAnsweredQues											{ get; set; }
	public Integer intNotAnsweredQues										{ get; set; }
	
	private Map<String, List<Question__c>> mapPGIdsQuestions;
	
	/************Constructor***********/
	public TBN_QuestionAnswerToProduct()
	{
		// Checks whether url has Opportunity Id with its value or not.
		if(Apexpages.currentPage().getParameters().containsKey('oppId') &&
		Apexpages.currentPage().getParameters().get('oppId').length() >= 15 &&
		String.valueOf(((Id)(Apexpages.currentPage().getParameters().get('oppId')) ).getSObjectType()) == 'Opportunity')
		{
			strOpportunityId = Apexpages.currentPage().getParameters().get('oppId');
			
			List<OpportunityLineItem> lstOLI  = [Select Id, Name, OpportunityId, Product2Id,Product2.ProductGroupId__c
			From OpportunityLineItem
			Where OpportunityId =: strOpportunityId];
			
			isbtn = true;
			objAnswer = new Answer__c();
			
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
	
	
	/*********To get question and answer related to product*********/
	public void getQuestionAnswerForProduct(List<OpportunityLineItem> lstOLI)
	{
		Set<String> setProductGroupIds = new Set<String>();
		Set<String> setProduct2Ids = new Set<String>();
		mapPGIdsQuestions = new Map<String, List<Question__c>>();
		lstWrapperClass = new List<wrapperQuestionAnswerToProduct>();
		
		for(OpportunityLineItem objOLI : lstOLI)
		{
			setProductGroupIds.add(objOLI.Product2.ProductGroupId__c);
			setProduct2Ids.add(objOLI.Product2Id);
		}
		
		//List of products related to product group.
		List<Product2> lstProducts = [Select Id, Name, ProductGroupId__c From Product2 Where ProductGroupId__c IN: setProductGroupIds];
		Map<product2, product2> mapProducts = new Map<product2, Product2>();
		
		for(product2 objProduct : lstProducts)
		{
			mapProducts.put(objProduct, objProduct );
		}
		
		List<Question__c> lstQuestionsAsChild = [Select Id, Name, Question_Description__c, ProductGroupId__c , Prospected_Answer__c, Question_Type__c,(Select Id, Name, Answer_Type__c, Answer_Value__c From Answers__r)
												From Question__c Where ProductGroupId__c IN: setProductGroupIds];
		List<Question__c> tempLstQuestionsAsChild = new list<Question__c>();
		
		for( Question__c onjQues :lstQuestionsAsChild )
		{
			tempLstQuestionsAsChild = new list<Question__c>();
			
			if(mapPGIdsQuestions.containsKey(onjQues.ProductGroupId__c))
				tempLstQuestionsAsChild = mapPGIdsQuestions.get(onjQues.ProductGroupId__c);
			
			tempLstQuestionsAsChild.add(onjQues);
				mapPGIdsQuestions.put(onjQues.ProductGroupId__c, tempLstQuestionsAsChild);
		}
		
		for(product2 objProduct : mapProducts.values())
		{
			lstWrapperClass.add(new wrapperQuestionAnswerToProduct(objProduct.id, mapPGIdsQuestions.get(objProduct.ProductGroupId__c ) ));
		}
		
		system.debug('---lstProducts---->' + lstProducts);
		system.debug('---tempLstQuestionsAsChild---->' + tempLstQuestionsAsChild);
		system.debug('---lstWrapperClass---->' + lstWrapperClass);
	}
	/********End Method*********/
	
	/******To show answers*******/
	public void saveAnswers()
	{
		List<Question__c> lstQuestions = new List<Question__c>();
		List<Answer__c> lstAnswerToSave = new List<Answer__c>();
		for(wrapperQuestionAnswerToProduct objWrapper : lstWrapperClass)
		{
			lstQuestions.addAll(objWrapper.lstQuesAsParent);
		}
		
		for(Question__c objQuestion : lstQuestions)
		{
			lstAnswerToSave.add(objQuestion.Answers__r);
		}
		
		if(!lstAnswerToSave.isEmpty())
			update lstAnswerToSave;
	}
	
	/******To show input field*******/
	public void showAnswerInput()
	{
		isAnswerInput = true;
		isbtn = false;
	}
	
	/*******Wrapper Class*******/
	public class wrapperQuestionAnswerToProduct
	{
		
		public List<Question__c> lstQuesAsParent	{ get; set; }
		Public Product2 objProdAsGParent			{ get; set; }
		
		/******Wrapper Class Constructor*******/
		public wrapperQuestionAnswerToProduct(String strProdIdsAsGParent, List<Question__c> lstQuestions)
		{
			lstQuesAsParent = lstQuestions;
			objProdAsGParent = [Select Id, Name From Product2 where Id =: strProdIdsAsGParent limit 1];
		}
	}
	/*******End Wrapper Class*******/
	
}