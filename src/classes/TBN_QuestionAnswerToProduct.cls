/**
@ClassName          :   TBN_QuestionAnswerToProduct
@Date               :   15/Apr/2015
@Description        :   To get answer for questions related to product.
*/
public with sharing class TBN_QuestionAnswerToProduct 
{
    //Variables
    private String strOpportunityId; 
    public List<wrapperQuestionAnswerToProduct> lstWrapperClass;
    public Boolean showPageMessage                              { get; set; }
    
    
    /************Constructor***********/
    public TBN_QuestionAnswerToProduct()
    {
        // Checks whether url has Opportunity Id with its value or not.
        if(Apexpages.currentPage().getParameters().containsKey('oppId') &&
        Apexpages.currentPage().getParameters().get('oppId').length() >= 15 &&
        String.valueOf(((Id)(Apexpages.currentPage().getParameters().get('oppId')) ).getSObjectType()) == 'Opportunity')
        {
            strOpportunityId = Apexpages.currentPage().getParameters().get('oppId');
            
            List<OpportunityLineItem> lstOLI  = [Select Id, Name, OpportunityId, Product2Id, Product2.Product_Group__c
                                                From OpportunityLineItem
                                                Where OpportunityId =: strOpportunityId];
            
            if(lstOLI.isEmpty())
            {
                showPageMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No product added to this opportunity'));
            }
        }
    }
    /******End Constructor ********/
    
    /******Wrapper Class ********/
    public class wrapperQuestionAnswerToProduct
    {
        Public Product2 objProdAsGParent                            { get;set; }
        public  Answer__c objAns                                    { get;set; }
        public list<Question__c> lstQuesAsParent                    { get;set; }
        public list<selectOption> lstSelOptions                     { get;set; }
        public map<string, string > mapOptions                      { get;set; }
        public map<string, Boolean > mapBolAnswers                      { get;set; }
        public map<string, Answer__c> mapAnswers                    { get;set; }
        public map<string, list<selectOption> > mapSelectOptions    { get;set; }
         
        public list<Answer__c> lstAnswers = new list<Answer__c>();
         
        /******Wrapper Class Constructor********/
        public wrapperQuestionAnswerToProduct(string strProdIdsAsGParent, string strOpportunityId, List<Question__c> lstQuestions)
        {    
            mapSelectOptions  = new map<string, list<selectOption>>();
            mapOptions = new map<string,string >();
            mapAnswers = new map<string,Answer__c>();
            mapBolAnswers = new map<string,Boolean>();
            lstQuesAsParent = lstQuestions;
            objProdAsGParent = [Select Id, Name From Product2 Where Id =: strProdIdsAsGParent limit 1];
             
            for(Question__c objQues : lstQuestions)
            {    
                Boolean isCheck  = false;
                lstSelOptions = new list<selectOption>();
                list<string> lstValues = new list<string>();
                if(objQues.values__c != null)
                {
                    lstValues = objQues.values__c.split(',');
                    for(string strValue : lstValues )
                    {
                        lstSelOptions.add(new SelectOption(strValue, strValue));
                    } 
                }
                mapSelectOptions.put(objQues.id, lstSelOptions);
                mapOptions.put(objQues.id, '');
                mapBolAnswers.put(objQues.id, false);
                if(objQues.Answers__r.size() <= 0)
                {
                    objAns = new Answer__c();
                    objAns.Question__c = objQues.id; 
                    objAns.opportunity__c = strOpportunityId;
                    objAns.Product__c = objProdAsGParent.Id;
                    mapAnswers.put(objQues.id, objAns);
                    lstAnswers.add(objAns); 
                    
                }
                else
                {    
                    mapAnswers.put(objQues.id,objQues.Answers__r[0]);
                    if( objQues.Answers__r[0].Answer__c != null){
                    if((objQues.Answers__r[0].Answer__c.contains('true')  || objQues.Answers__r[0].Answer__c.contains('true')) )
                    {
                    mapBolAnswers.put(objQues.id,Boolean.ValueOF(objQues.Answers__r[0].Answer__c));
                    }
                    }
                }
            }
        }
    }
    /*********End Wrapper class *********/ 
    
    /******Insert answers on page load******/
    public void insertAnswers()
    {   
        list<Answer__c> lstToUpdate =  new List<Answer__c>();
        list<Question__c> tempLstQuesAsParent;
        
        system.debug('--Test-lstWrapperClass--- ' + lstWrapperClass);
        
        if(lstWrapperClass.size() > 0)
        {   
            for(wrapperQuestionAnswerToProduct obj: lstWrapperClass)
            {   
                for(Question__c objQues: obj.lstQuesAsParent)
                {   
                    if(objQues.Answers__r.size() <= 0)
                        lstToUpdate.add(obj.mapAnswers.get(objQues.id)); 
                }
            }
        }
        if(lstToUpdate.size()>0)
        insert lstToUpdate;
    }
    /**********End insertAnswers method**********/
    
    /**********To save answers provided on page**********/
    public void saveAnswers()
    {    
        list<Answer__c> lstToUpdate =  new List<Answer__c>();
        for(wrapperQuestionAnswerToProduct objWrapperClass :lstWrapperClass)
        {   
            for(Question__c objQues: objWrapperClass.lstQuesAsParent)
            {
                if(objQues.Type__c == 'picklist')
                    objWrapperClass.mapAnswers.get(objQues.id).Answer__c = objWrapperClass.mapOptions.get(objQues.id);
                if(objQues.Type__c == 'Boolean')
                    objWrapperClass.mapAnswers.get(objQues.id).Answer__c = string.ValueOF(objWrapperClass.mapBolAnswers.get(objQues.id));
                lstToUpdate.add(objWrapperClass.mapAnswers.get(objQues.id)); 
            }
        }
        set<Answer__c> setToRemoveDupes = new set<Answer__c>();
        setToRemoveDupes.addAll(lstToUpdate);
        lstToUpdate.clear();
        lstToUpdate.addAll(setToRemoveDupes);
        
        upsert lstToUpdate;
    }
    /******End saveAnswers method*******/
    
    /**********To get all the questions and answers related to product**********/
    public List<wrapperQuestionAnswerToProduct> getQuestionAnswerForProduct()
    {
        set<string> setProductGp = new set<string>();
        map<string, List<Question__c>> mapToStore = new map<string, List<Question__c>>();
        list<Question__c> lstQuestions = new list<Question__c>();
        lstWrapperClass = new List<wrapperQuestionAnswerToProduct>();
        list<Product2 > lstProduct2 = [Select Id, Name, Product_Group__c From Product2];
        
        for(product2 obj:lstProduct2 )
        {
             if(obj.Product_Group__c != null)
                setProductGp .add(obj.Product_Group__c );
        }
         
        List<Question__c> tempLstQuestions = [Select Id, Product_Group__c, Type__c, Question__c  , Values__c, Name,(Select Id, Answer__c , Name From Answers__r where Opportunity__c =: strOpportunityId ) 
                                            From Question__c 
                                            Where Product_Group__c IN: setProductGp];
         
        for( Question__c onjQues :tempLstQuestions )
        {
            lstQuestions = new list<Question__c>();                           
            
            if(mapToStore.containsKey(onjQues.Product_Group__c  ))
                lstQuestions = mapToStore.get(onjQues.Product_Group__c  ); 
            
            lstQuestions.add(onjQues);
            mapToStore.put(onjQues.Product_Group__c  , lstQuestions);
            
        }
         
         for(Product2 objprod : lstProduct2 )
         {
             if(objprod.Product_Group__c != null)
                lstWrapperClass.add(new wrapperQuestionAnswerToProduct(objprod.id, strOpportunityId,  mapToStore.get(objprod.Product_Group__c)));
         }
         
        return lstWrapperClass;
    }
    /******End getQuestionAnswerForProduct method*******/
}