global with sharing  class MDM_Product_Manufacturer_PopulateIDBt implements Database.Batchable<MDM_Manufacturer__c>, Database.Stateful {
    global list<MDM_Manufacturer__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_Manufacturer_PopulateIDBt(){
        // To populate the EnrterpriseID from the Auto generated Manufacturer ID
        // rList = [select Id ,name,ManufacturerID__c,EnterpriseID__c  from MDM_Manufacturer__c  where id=:l.id];
    }
    global Iterable<MDM_Manufacturer__c> start(Database.BatchableContext BC){
        blList = new list<MDM_Manufacturer__c>();
        blList = [select Id ,name,ManufacturerID__c,EnterpriseID__c  from MDM_Manufacturer__c  where  EnterpriseID__c = null or EnterpriseID__c =  ' '   limit 5];
        
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_Manufacturer__c> scope){
        try
        {
            for(MDM_Manufacturer__c  l: scope) 
            {
                list<MDM_Manufacturer__c> rList = new list<MDM_Manufacturer__c>();
                rList = [select Id ,name,ManufacturerID__c,EnterpriseID__c  from MDM_Manufacturer__c  where id=:l.id];
                if(rList.size() !=0)
                {
                    MDM_Manufacturer__c a = rList[0];
                    a.EnterpriseID__c = a.ManufacturerID__c;
                    update a;
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_PopulateManufacturerIDBt '+e.getMessage());
             
        }
    }
    public void finish(Database.BatchableContext BC){

    }
}