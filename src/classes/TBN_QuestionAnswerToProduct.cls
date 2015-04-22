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
    public Boolean showPageMessage                                { get; set; }
    public Opportunity objOpportunity                             { get; set; }
    public Integer intTotal                                       { get; set; }
    
    
    /************Constructor***********/
    public TBN_QuestionAnswerToProduct()
    {
        intTotal = 0;
        // Checks whether url has Opportunity Id with its value or not.
        if(Apexpages.currentPage().getParameters().containsKey('oppId') &&
        Apexpages.currentPage().getParameters().get('oppId').length() >= 15 &&
        String.valueOf(((Id)(Apexpages.currentPage().getParameters().get('oppId')) ).getSObjectType()) == 'Opportunity')
        {
            strOpportunityId = Apexpages.currentPage().getParameters().get('oppId');
            lstWrapperClass = new List<wrapperQuestionAnswerToProduct>();
            
            objOpportunity = [Select Id, Name, Answer_Done__c, Answer_Pending__c 
        					From Opportunity 
        					Where Id =: strOpportunityId];
            
            intTotal = integer.valueOf(objOpportunity.Answer_Pending__c) + integer.valueOf(objOpportunity.Answer_Done__c);
            
            list<OpportunityLineItem> lstOLI  = [Select Id, Name, OpportunityId, Product2Id, Product2.Product_Group__c
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
        //Wrapper class variables
        public Product2 objProdAsGParent                            { get;set; }
        public  Answer__c objAns                                    { get;set; }
        public list<Question__c> lstQuesAsParent                    { get;set; }
        public list<selectOption> lstSelOptions                     { get;set; }
        public map<string, string > mapOptions                      { get;set; }
        public map<string, Boolean > mapBolAnswers                  { get;set; }
        public map<string, Answer__c> mapAnswers                    { get;set; }
        public map<string, list<selectOption> > mapSelectOptions    { get;set; }
         
        public list<Answer__c> lstAnswers = new list<Answer__c>();
         
        /******Wrapper Class Constructor********/
        public wrapperQuestionAnswerToProduct(string strProdIdsAsGParent, string strOpportunityId, List<Question__c> lstQuestions)
        {    
            set<string> setQuesIds = new set<string>();
            mapSelectOptions  = new map<string, list<selectOption>>();
            mapOptions = new map<string,string >();
            mapAnswers = new map<string,Answer__c>();
            mapBolAnswers = new map<string,Boolean>();
            lstQuesAsParent = lstQuestions;
            
            objProdAsGParent = [Select Id, Name From Product2 Where Id =: strProdIdsAsGParent limit 1];
            
            //Binding all related answers of corresponding questions.
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
                        strValue = strValue.trim();
                        lstSelOptions.add(new SelectOption(strValue, strValue));
                    } 
                }
                
                mapSelectOptions.put(objProdAsGParent.Name+objQues.id, lstSelOptions);
                mapOptions.put(objProdAsGParent.Name+objQues.id, '');
                mapBolAnswers.put(objProdAsGParent.Name+objQues.id, false);
                
                //Adding new answer record.
                if(objQues.Answers__r.size() <= 0)
                {
                    objAns = new Answer__c();
                    objAns.Question__c = objQues.id; 
                    objAns.opportunity__c = strOpportunityId;
                    objAns.Product__c = objProdAsGParent.Id;
                    mapAnswers.put(objProdAsGParent.Name+objQues.id, objAns);
                    lstAnswers.add(objAns); 
                }
                else
                {    setQuesIds.add(objQues.id);
                    //mapAnswers.put(objProdAsGParent.Name+objQues.id,objQues.Answers__r[0]);
                }
            }
            //Creating map of answers
            if(setQuesIds.size() > 0)
            {
                for(Answer__c objAns : [Select  Id, Answer__c, Name, Question__c From Answer__c Where Opportunity__c =: strOpportunityId AND Product__c =: objProdAsGParent.id  AND Question__c In: setQuesIds ])
                {
                    mapAnswers.put(objProdAsGParent.Name+objAns.Question__c, objAns);
                    if( objAns.Answer__c != null)
                    {
                        if((objAns.Answer__c.contains('true')  || objAns.Answer__c.contains('True')) )
                        {
                            mapBolAnswers.put(objProdAsGParent.Name+objAns.Question__c, Boolean.ValueOF(objAns.Answer__c));
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
        list<Answer__c> lstToInsertAnswers =  new List<Answer__c>();
        list<Question__c> tempLstQuesAsParent;
        
        //List of newly created answers. 
        if(lstWrapperClass.size() > 0)
        {   
            for(wrapperQuestionAnswerToProduct objWrapperClass : lstWrapperClass)
            {   
                for(Question__c objQues : objWrapperClass.lstQuesAsParent)
                {   
                    string strKey = objWrapperClass.objProdAsGParent.Name+objQues.id;
                    if(objQues.Answers__r.size() <= 0)
                        lstToInsertAnswers.add(objWrapperClass.mapAnswers.get(strKey)); 
                }
            }
        }
        
        //Insert new answer records for questions to DB.
        if(lstToInsertAnswers.size()>0)
            insert lstToInsertAnswers;
    }
    /**********End insertAnswers method**********/
    
    /**********To save answers provided on page**********/
    public void saveAnswers()
    {    
        list<Answer__c> lstToUpdateAnswers =  new List<Answer__c>();
        set<Answer__c> setToRemoveDupes = new set<Answer__c>();
        
        try{
            
            for(wrapperQuestionAnswerToProduct objWrapperClass :lstWrapperClass)
            {   
                for(Question__c objQues: objWrapperClass.lstQuesAsParent)
                {
                    if(objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id).Answer__c != null && objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id).Answer__c != '') {
                        
                        objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id).Answer_Given__c = true;
                    }
                    if(objQues.Type__c == 'picklist')
                        objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id).Answer__c = objWrapperClass.mapOptions.get(objWrapperClass.objProdAsGParent.Name+objQues.id);
                    
                    if(objQues.Type__c == 'Boolean')
                        objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id).Answer__c = string.ValueOF(objWrapperClass.mapBolAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id));
                    
                    lstToUpdateAnswers.add(objWrapperClass.mapAnswers.get(objWrapperClass.objProdAsGParent.Name+objQues.id)); 
                }
            }
            
            setToRemoveDupes.addAll(lstToUpdateAnswers);
            lstToUpdateAnswers.clear();
            lstToUpdateAnswers.addAll(setToRemoveDupes);
            
            //Upsert records into DB.
            if(lstToUpdateAnswers.size() > 0)
                upsert lstToUpdateAnswers;
        }
        
        catch(Exception e) {
            
            system.debug('***** Excption****'+e);
        }
        //List of all answers which have been updated on page to save in DB.
        
    }
    /******End saveAnswers method*******/
    
    /**********To get all the questions and answers related to product on page**********/
    public List<wrapperQuestionAnswerToProduct> getQuestionAnswerForProduct()
    {
        set<string> setProductGp = new set<string>();
        map<string, List<Question__c>> mapToStore = new map<string, List<Question__c>>();
        list<Question__c> lstQuestions = new list<Question__c>();
        lstWrapperClass = new List<wrapperQuestionAnswerToProduct>();
        list<Product2 > lstProduct2 = [Select Id, Name, Product_Group__c From Product2];
        
        //Set product group which having products.
        for(Product2 objProd : lstProduct2 )
        {
            if(objProd.Product_Group__c != null)
                setProductGp .add(objProd.Product_Group__c );
        }
        
        //List of questions and their related answers. 
        list<Question__c> tempLstQuestions = [Select Id, Product_Group__c, Type__c, Question__c , Values__c, Name,(Select Id, Answer__c , Name From Answers__r where Opportunity__c =: strOpportunityId AND Product__c IN :lstProduct2 LIMIT 1) 
                                            From Question__c 
                                            Where Product_Group__c IN: setProductGp];
         
        //List of questions corresponding to product group
        for(Question__c onjQues : tempLstQuestions )
        {
            lstQuestions = new list<Question__c>();                           
            
            if(mapToStore.containsKey(onjQues.Product_Group__c  ))
                lstQuestions = mapToStore.get(onjQues.Product_Group__c ); 
            
            lstQuestions.add(onjQues);
            mapToStore.put(onjQues.Product_Group__c, lstQuestions);
        }
        
        //List of products associated with product group.
        for(Product2 objProd : lstProduct2 )
        {
         if(objProd.Product_Group__c != null)
            lstWrapperClass.add(new wrapperQuestionAnswerToProduct(objProd.Id, strOpportunityId,  mapToStore.get(objProd.Product_Group__c)));
        }
        //Return the wrapper class object on page to display product and their questions and answers. 
        return lstWrapperClass;
    }
    /******End getQuestionAnswerForProduct method*******/
}
/********End of class*********/