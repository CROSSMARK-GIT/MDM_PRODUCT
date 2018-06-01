global with sharing  class MDM_Product_ProductGroup_PopulateIDBt implements Database.Batchable<MDM_Product_Group__c>, Database.Stateful {
    global list<MDM_Product_Group__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_ProductGroup_PopulateIDBt(){
        // To populate the EnrterpriseID from the Auto generated Brand ID
        // rList = [select Id ,name,Product_GroupID__c,EnterpriseID__c  from MDM_Product_Group__c  where id=:l.id];
    }
    global Iterable<MDM_Product_Group__c> start(Database.BatchableContext BC){
        blList = new list<MDM_Product_Group__c>();
        blList = [select Id ,name,Product_GroupID__c,EnterpriseID__c  from MDM_Product_Group__c  where  EnterpriseID__c = null or EnterpriseID__c =  ' '   limit 5];
        System.debug('==debug Message  rama1=== MDM_Product_ProductGroup_PopulateIDBt '+blList.size());
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_Product_Group__c> scope){
        try
        {
            for(MDM_Product_Group__c  l: scope) 
            {
                list<MDM_Product_Group__c> rList = new list<MDM_Product_Group__c>();
                rList = [select Id ,name,Product_GroupID__c,EnterpriseID__c  from MDM_Product_Group__c  where id=:l.id];
                System.debug('==debug Message  rama2=== MDM_Product_ProductGroup_PopulateIDBt '+rList.size());
                if(rList.size() !=0)
                {
                    MDM_Product_Group__c a = rList[0];
                    a.EnterpriseID__c = a.Product_GroupID__c;
                    update a;
                     System.debug('==debug Message  rama3== MDM_Product_ProductGroup_PopulateIDBt '+rList.size());
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_ProductGroup_PopulateIDBt '+e.getMessage());
             
        }
    }
    public void finish(Database.BatchableContext BC){

    }
}