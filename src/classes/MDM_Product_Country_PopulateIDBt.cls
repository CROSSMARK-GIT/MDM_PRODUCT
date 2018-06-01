global with sharing  class MDM_Product_Country_PopulateIDBt implements Database.Batchable<MDM_Product_Country__c>, Database.Stateful {
    global list<MDM_Product_Country__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_Country_PopulateIDBt(){
        // To populate the EnrterpriseID from the Auto generated Brand ID
        // rList = [select Id ,name,CountryID__c,EnterpriseID__c  from MDM_Product_Country__c  where id=:l.id];
    }
    global Iterable<MDM_Product_Country__c> start(Database.BatchableContext BC){
        blList = new list<MDM_Product_Country__c>();
        blList = [select Id ,name,CountryID__c,EnterpriseID__c  from MDM_Product_Country__c  where  EnterpriseID__c = null or EnterpriseID__c =  ' '   limit 5];
        
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_Product_Country__c> scope){
        try
        {
            for(MDM_Product_Country__c  l: scope) 
            {
                list<MDM_Product_Country__c> rList = new list<MDM_Product_Country__c>();
                rList = [select Id ,name,CountryID__c,EnterpriseID__c  from MDM_Product_Country__c  where id=:l.id];
                if(rList.size() !=0)
                {
                    MDM_Product_Country__c a = rList[0];
                    a.EnterpriseID__c = a.CountryID__c;
                    update a;
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_PopulateBrandIDBt '+e.getMessage());
             
        }
    }
    public void finish(Database.BatchableContext BC){

    }
}