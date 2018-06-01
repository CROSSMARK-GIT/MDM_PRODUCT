global with sharing class MDM_Product_Reference_UpdatedBt implements Database.Batchable<MDM_Product__c>,Database.Stateful{    
    global list<MDM_Product__c> blList;
    global String refobjName;
    global id refObjId;
    global String lstmodusr;
    
    global MDM_Product_Reference_UpdatedBt(string prefobjName, id prefObjId, string plstmodusr){
        refobjName = prefobjName;
        refObjId=prefObjId;
        lstmodusr = plstmodusr;
    }
    
    global Iterable<MDM_Product__c> start(Database.BatchableContext BC){
        blList = new  list<MDM_Product__c>();
        if(refobjName == 'Manufacturer')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  Manufacturer__c =: refObjId limit 10000];
        }
        if(refobjName == 'Brand')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  Brand__c =: refObjId limit 10000];
        }
        if(refobjName == 'ProductGroup')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  Product_Group__c =: refObjId limit 10000];
        }
        if(refobjName == 'ProductCategory')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  Category__c =: refObjId limit 10000];
        }
        if(refobjName == 'ManufacturerProductCategory')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  ManufacturerCategory__c   =: refObjId limit 10000];
        }
        if(refobjName == 'ProductCountry')
        {
             blList = [select Id ,name,CustomizedLastModifiedUserName__c,CustomizedLastModifiedDatetime__c  from MDM_Product__c  where  Product_Country__c   =: refObjId limit 10000];
        }
        return blList;
    }
    global void execute(Database.BatchableContext BC, List<MDM_Product__c> scope){
        try
        {
            for(MDM_Product__c  q: scope) 
            {
 
            q.CustomizedLastModifiedUserName__c = lstmodusr;
            Datetime cDT = System.now();    
            q.CustomizedLastModifiedDatetime__c = cDT;
            update(q); 
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_Reference_UpdatedBt '+e.getMessage());
             
        }
        
    }
    global void finish(Database.BatchableContext BC){
        try
        {
             
        }
        catch(System.EmailException ex){
            system.debug('============== email exception caught!!!=============');
        }
 
    }
 
}