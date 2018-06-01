global with sharing  class MDM_Product_Brand_PopulateIDBt implements Database.Batchable<MDM_Brand__c>, Database.Stateful {
    global list<MDM_Brand__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_Brand_PopulateIDBt(){
        // To populate the EnrterpriseID from the Auto generated Brand ID
        // rList = [select Id ,name,BrandID__c,EnterpriseID__c  from MDM_Brand__c  where id=:l.id];
    }
    global Iterable<MDM_Brand__c> start(Database.BatchableContext BC){
        blList = new list<MDM_Brand__c>();
        blList = [select Id ,name,BrandID__c,EnterpriseID__c  from MDM_Brand__c  where  EnterpriseID__c = null or EnterpriseID__c =  ' '   limit 5];
        
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_Brand__c> scope){
        try
        {
            for(MDM_Brand__c  l: scope) 
            {
                list<MDM_Brand__c> rList = new list<MDM_Brand__c>();
                rList = [select Id ,name,BrandID__c,EnterpriseID__c  from MDM_Brand__c  where id=:l.id];
                if(rList.size() !=0)
                {
                    MDM_Brand__c a = rList[0];
                    a.EnterpriseID__c = a.BrandID__c;
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