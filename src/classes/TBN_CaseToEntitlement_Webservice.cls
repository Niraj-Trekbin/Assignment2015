/**
@ClassName          :   TBN_CaseToEntitlement_Webservice
@CreatedDate        :   21/Apr/2015
@Description        :   To get the account and its related contacts, assets, entitlements of a case.
*/
global class TBN_CaseToEntitlement_Webservice 
{
    //Variables
    
    /*
    @MethodName :   getAccountContactAssetRelatedToCase
    @Description:   To get account, contacts, assets, entitlement related to the case as requested by user to the server end.
    */
    webService static string getAccountContactAssetRelatedToCase(string strCaseId, string strContactPhone, string strAccountNumber) 
    {
        if(strCaseId.length() >= 15)
        {
            string strJsonData = getAllDataRelatedToCase(strCaseId, strContactPhone, strAccountNumber);
            return strJsonData;
        }
        else
            return '{"Error":"Case id is not valied"}';
    }
    
    /*
    @MethodName :   getAllDataRelatedToCase
    @Description:   To get account, contacts, assets, entitlement related to the case as requested by user.
    */
    private static string getAllDataRelatedToCase(string strCaseId, string strContactPhone, string strAccountNumber)
    {
        string strJson = '';
        
        list<Case> lstCases = [Select Id, IsClosed, AccountId, AssetId, ContactId, EntitlementId, Account.AccountNumber 
                                From Case 
                                Where Id =: strCaseId limit 1];
        
        if(lstCases.isEmpty())
        {
            return '{"Error":"Case id related record is not exist"}';
        }
        
        //If account number field on account is not having value, then take account associated with case.
        if(strAccountNumber == null || strAccountNumber == '')
        {
            list<Account> lstAccounts = [Select Id, Name, Phone, AccountNumber, Type 
                                        From Account 
                                        Where Id =: lstCases[0].AccountId];
            
            //Error message when there is no account associated with this case.
            if(lstAccounts.isEmpty())
            {   
                return '{"Error":"There is no account added to this case"}';
            }
            
            strJson = bindAccountToJson(strJson, lstAccounts[0]);
            
            list<Asset> lstAssets = [Select Id, Name, AccountId, ContactId, Status  
                                    From Asset 
                                    Where AccountId =: lstAccounts[0].Id];
            
            //If User has provided phone number for contact.
            if(strContactPhone.length() > 0)
            {
                list<Contact> lstContacts = [Select Id, LastName, Phone, AccountId, Email 
                                            From Contact 
                                            Where AccountId =: lstAccounts[0].Id AND Phone = :strContactPhone];
                
                strJson = bindContactToJson(strJson, lstContacts);                          
            }
            //If User has not provided phone number for contact.
            else
            {
                list<Contact> lstContacts = [Select Id, LastName, Phone, AccountId, Email 
                                            From Contact 
                                            Where AccountId =: lstAccounts[0].Id];
                
                strJson = bindContactToJson(strJson, lstContacts);
            }
        
            list<Entitlement> lstEntitlement = [Select Id, Name, AccountId, AssetId, Status  
                                                From Entitlement 
                                                Where AccountId =: lstAccounts[0].Id];
        
            strJson = bindAssetToJson(strJson, lstAssets);
            strJson = bindEntitlementToJson(strJson, lstEntitlement);
            
            strJson += ' }';
        }
        //If strAccountNumber which user has sent having value, then get that account which having this Account number.
        else
        {
            list<Account> lstAccounts = [Select Id, Name, Phone, AccountNumber, Type 
                                        From Account 
                                        Where AccountNumber =: strAccountNumber limit 1];
            
            if(lstAccounts.isEmpty())
            {
                return '{"Error":"There is no account which having your account number."}';
            }
            
            //Getting account record in json form.
            strJson = bindAccountToJson(strJson, lstAccounts[0]);
            
            list<Asset> lstAssets = [Select Id, Name, AccountId, ContactId, Status  
                                    From Asset 
                                    Where AccountId =: lstAccounts[0].Id];
            
            //If User has provided phone number for contact.
            if(strContactPhone.length() > 0)
            {
                list<Contact> lstContacts = [Select Id, LastName, Phone, AccountId, Email 
                                            From Contact 
                                            Where AccountId =: lstAccounts[0].Id AND Phone = :strContactPhone];
                
                strJson = bindContactToJson(strJson, lstContacts);                          
            }
            //If User has provided phone number for contact.
            else
            {
                list<Contact> lstContacts = [Select Id, LastName, Phone, AccountId, Email 
                                            From Contact 
                                            Where AccountId =: lstAccounts[0].Id];
                
                strJson = bindContactToJson(strJson, lstContacts);
            }
            
            list<Entitlement> lstEntitlement = [Select Id, Name, AccountId, AssetId, Status  
                                                From Entitlement 
                                                Where AccountId =: lstAccounts[0].Id];
        
            strJson = bindAssetToJson(strJson, lstAssets);
            strJson = bindEntitlementToJson(strJson, lstEntitlement);
            
            strJson += ' }';
        }
        //Finally return all Json with records.
        return strJson;
    }
    
    /*
    @MethodName :   bindAccountToJson
    @Description:   Formats the account fields into a JSON string for sending to a server.
    */
    private static String bindAccountToJson(string strJson, Account objAccount)
    {
        strJson = '{ "Account": [ {';
        map<string, string> mapSFDCFields = new map<string, string>();
        
        //Mapping fields and their values to pass into json.
        mapSFDCFields.put('Id', objAccount.Id);
        mapSFDCFields.put('Name', objAccount.Name);
        mapSFDCFields.put('Phone', objAccount.Phone);
        mapSFDCFields.put('AccountNumber', objAccount.AccountNumber);
        mapSFDCFields.put('Type', objAccount.Type);
        
        //Indexing each record into json.
        strJson += '"A' + 0 + '":';
        strJson = strJson + compileJson(mapSFDCFields);
        strJson = strJson + '} ]';
        
        //Returning formatted string as json form.
        return strJson;
    }
    
    /*
    @MethodName :   bindContactToJson
    @Description:   Formats the contact fields into a JSON string for sending to a server.
    */
    private static String bindContactToJson(string strJson, list<Contact> lstContacts)
    {
        map<string, string> mapSFDCFields = new map<string, string>();
        
        if(lstContacts.size() > 0)
        {   
            strJson = strJson + ',';
            strJson += ' "Contact": [ {';
            integer index = 0;
            
            //Iterating over each records to bind their fields and values to json.
            for(Contact objContact : lstContacts)
            {   
                //Indexing each record into json.
                strJson += '"C' + index + '":';
                index++;
                
                //Mapping fields and their values to pass into json.
                mapSFDCFields.put('Id',objContact.Id );
                mapSFDCFields.put('LastName',objContact.LastName );
                mapSFDCFields.put('Phone',objContact.Phone );
                mapSFDCFields.put('AccountId',objContact.AccountId );
                mapSFDCFields.put('Email',objContact.Email );
                
                strJson = strJson + compileJson(mapSFDCFields);
                
                if(index != lstContacts.size())
                    strJson = strJson + ',';
            }
            strJson += '} ]';
        }
        //Returning formatted string as json form.
        return strJson;
    }
    
    /*
    @MethodName :   bindAssetToJson
    @Description:   Formats the asset fields into a JSON string for sending to a server.
    */
    private static String bindAssetToJson(string strJson, list<Asset> lstAssets)
    {
        map<string, string> mapSFDCFields = new map<string, string>();
        
        if(lstAssets.size() > 0)
        {
            strJson = strJson + ',';
            strJson += ' "Asset": [ {';
            integer index = 0;
            
            //Iterating over each records to bind their fields and values to json.
            for(Asset objAsset : lstAssets)
            {
                //Indexing each record into json.
                strJson += '"A' + index + '":';
                index++;
                
                //Mapping fields and their values to pass into json.
                mapSFDCFields.put('Id',objAsset.Id );
                mapSFDCFields.put('Name',objAsset.Name );
                mapSFDCFields.put('AccountId',objAsset.AccountId );
                mapSFDCFields.put('ContactId',objAsset.ContactId );
                mapSFDCFields.put('Status',objAsset.Status );
                
                strJson = strJson + compileJson(mapSFDCFields);
                
                if(index != lstAssets.size())
                    strJson = strJson + ',';
            }
            strJson += '} ]';
        }
        //Returning formatted string as json form.
        return strJson;
    }
    
    /*
    @MethodName :   bindEntitlementToJson
    @Description:   Formats the EntitlementToJson fields into a JSON string for sending to a server.
    */
    private static String bindEntitlementToJson(string strJson, list<Entitlement> lstEntitlement)
    {
        map<string, string> mapSFDCFields = new map<string, string>();
        
        if(lstEntitlement.size() > 0)
        {   
            strJson = strJson + ',';
            strJson += ' "Entitlement": [ {';
            integer index = 0;
            
            //Iterating over each records to bind their fields and values to json.
            for(Entitlement objEntitlement : lstEntitlement)
            {   
                //Indexing each record into json.
                strJson += '"E' + index + '":';
                index++;
                
                //Mapping fields and their values to pass into json.
                mapSFDCFields.put('Id',objEntitlement.Id );
                mapSFDCFields.put('Name',objEntitlement.Name );
                mapSFDCFields.put('AccountId',objEntitlement.AccountId );
                mapSFDCFields.put('AssetId',objEntitlement.AssetId );
                mapSFDCFields.put('Status',objEntitlement.Status );
                
                strJson = strJson + compileJson(mapSFDCFields);
                
                if(index != lstEntitlement.size())
                    strJson = strJson + ',';
            }
            strJson += '} ]';
        }
        //Returning formatted string as json form.
        return strJson;
    }
    
    /*
    @MethodName :   compileJson
    @Description:   Formats the fields into a JSON string for sending to a server.
    */
    private static String compileJson(Map<String, String> mapSfdcFields)
    {
        String jsonData = '{ ' ;
        Boolean addComma = false;
        
        //Binding fields and their values into json formate.
        for(String strFieldLabel : mapSfdcFields.keySet())
        {
            jsonData += (addComma?', ':'') + '"' + strFieldLabel + '":' + JSON.serialize(mapSfdcFields.get(strFieldLabel));
            addComma = true;
        }
        jsonData = jsonData + ' }';
        return jsonData;
    }
}