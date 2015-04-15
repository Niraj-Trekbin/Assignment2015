/**
@TriggerName        :   TBN_OLITrigger
@Date               :   14/Apr/2015
@Description        :   This trigger is fired on insert, update, or delete of the OLI.
*/ 
trigger TBN_OLITrigger on OpportunityLineItem (after insert, after update, before delete) 
{
	//Varibales
	
	TBN_OLITriggerHandler objOLIHandler = new TBN_OLITriggerHandler();
    
    /************After insert*************/
    if(Trigger.isAfter && Trigger.isInsert)
    {   
        objOLIHandler.onAfterInsertOLI(Trigger.new);
    }
}