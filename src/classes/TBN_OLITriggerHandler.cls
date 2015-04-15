/**
@ClassName        	:   TBN_OLITriggerHandler
@Date               :   14/Apr/2015
@Description        :   
*/
public with sharing class TBN_OLITriggerHandler 
{
	//Variables
	
	/*******Constructor********/
	public TBN_OLITriggerHandler()
	{
		//Do-Initialization.
		
	}
	
	/*
	@MethodName        	:   onAfterInsertOLI
	@Description        :   On insert of OLI, insert record for 'Answer'.
	*/
	public void onAfterInsertOLI(List<OpportunityLineItem> lstOLI)
	{
		Set<String> setProductGroupIds = new Set<String>();
		Map<String, String> mapOppIdsProdIds = new Map<String, String>();
		Map<String, List<OpportunityLineItem>> mapOppIdsOLIs = new Map<String, List<OpportunityLineItem>>();
		Map<String, List<OpportunityLineItem>> mapProdIdsOLIs = new Map<String, List<OpportunityLineItem>>();
		Map<String, List<Product2>> mapPGIdsProducts = new Map<String, List<Product2>>();
		
		if(lstOLI.size() > 0)
		{
			for(OpportunityLineItem objOLI : lstOLI)
			{
				setProductGroupIds.add(objOLI.Product2.ProductGroupId__c);
				
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
			
			//Quering all Questions related to the ProductGroups
			for(Question__c objQuestion : [Select Id, Name, ProductGroupId__c From Question__c Where ProductGroupId__c IN: setProductGroupIds])
			{
				
			}
		}
		
		//createAnswers(setProductGroupIds);
	}
	
	/*
	@MethodName        	:   createAnswers
	@Description        :   On insert of OLI, insert record for 'Answer'.
	*/
	private void createAnswers(Set<String> setProductGroupIds)
	{
		//Keep all products corresponding to their product group.
		Map<String, List<Product2>> mapPGIdsProducts = new 	Map<String, List<Product2>>();
		
		
		List<Question__c> lstQuestions = [Select Id, Name, ProductGroupId__c 
										  From Question__c
										  Where ProductGroupId__c IN: setProductGroupIds];
		
		
	}
	
	/*
	public class wrapperTBN_OLITriggerHandler
	{
		
	}
	*/
}