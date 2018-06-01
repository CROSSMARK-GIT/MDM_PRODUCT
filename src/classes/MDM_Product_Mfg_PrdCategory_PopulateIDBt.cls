global with sharing  class MDM_Product_Mfg_PrdCategory_PopulateIDBt implements Database.Batchable<MDM_ManufacturerProductCategory__c>, Database.Stateful {
    global list<MDM_ManufacturerProductCategory__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_Mfg_PrdCategory_PopulateIDBt(){
        // To populate the EnrterpriseID from the Auto generated ProductCategory ID
        // rList = [select Id ,name,ManufacturerProductCategoryID__c,EnterpriseID__c  from MDM_ProductCategory__c  where id=:l.id];
    }
    global Iterable<MDM_ManufacturerProductCategory__c> start(Database.BatchableContext BC){
        blList = new list<MDM_ManufacturerProductCategory__c>();
        blList = [select Id ,name,ManufacturerProductCategoryID__c,EnterpriseID__c  from MDM_ManufacturerProductCategory__c  where  EnterpriseID__c = null or EnterpriseID__c =  ' '   limit 5];
        
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_ManufacturerProductCategory__c> scope){
        try
        {
            for(MDM_ManufacturerProductCategory__c  l: scope) 
            {
                list<MDM_ManufacturerProductCategory__c> rList = new list<MDM_ManufacturerProductCategory__c>();
                rList = [select Id ,name,ManufacturerProductCategoryID__c,EnterpriseID__c  from MDM_ManufacturerProductCategory__c  where id=:l.id];
                if(rList.size() !=0)
                {
                    MDM_ManufacturerProductCategory__c a = rList[0];
                    a.EnterpriseID__c = a.ManufacturerProductCategoryID__c;
                    update a;
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_Mfg_PrdCategory_PopulateIDBt '+e.getMessage());
             
        }
    }
    public void finish(Database.BatchableContext BC){

    }
}