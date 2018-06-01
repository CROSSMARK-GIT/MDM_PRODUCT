global with sharing  class MDM_Product_AutoUpdateStatusByDateBt implements Database.Batchable<MDM_Product__c>, Database.Stateful {
    global list<MDM_Product__c> blList;
    string  strcountSOQL = '';
    string rid = '';
    
    global MDM_Product_AutoUpdateStatusByDateBt(){
        //If an End availability date is entered, automatically change the status to inactive after that date
        //If a product is entered with a Future status and a start availability date is entered, change the product to Active after the availability date
    }
    global Iterable<MDM_Product__c> start(Database.BatchableContext BC){
        blList = new list<MDM_Product__c>();
        blList = [select Id ,name,End_Availability_Date__c,Start_Availability_Date__c,Product_Status__c from MDM_Product__c  
                  where  (Start_Availability_Date__c = null and Start_Availability_Date__c >= TODAY and Product_Status__c !=: 'Active' ) or
                  (End_Availability_Date__c = null and End_Availability_Date__c <= YESTERDAY and Product_Status__c =: 'Active' ) limit 5000];
        
        return blList;
    }
    
    global void execute(Database.BatchableContext BC, List<MDM_Product__c> scope){
        try
        {
            for(MDM_Product__c  l: scope) 
            {
                list<MDM_Product__c> rList = new list<MDM_Product__c>();
                rList = [  select Id ,name,End_Availability_Date__c,Start_Availability_Date__c,Product_Status__c from MDM_Product__c  where id=:l.id];
                if(rList.size() !=0)
                {
                    MDM_Product__c a = rList[0];
                    if(a.Start_Availability_Date__c >= Date.today())
                    {
                        a.Product_Status__c = 'Active';
                    }
                    if(a.End_Availability_Date__c < Date.today())
                    {
                        a.Product_Status__c = 'InActive';
                    }

                    
                    update a;
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_AutoUpdateStatusByDateBt '+e.getMessage());
             
        }
    }
    public void finish(Database.BatchableContext BC){

    }
}