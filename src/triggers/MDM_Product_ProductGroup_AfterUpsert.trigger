trigger MDM_Product_ProductGroup_AfterUpsert on MDM_Product_Group__c (after Insert, after update) {
    List<MDM_Product_Group__c> lstResponses = new List<MDM_Product_Group__c>();

    for (MDM_Product_Group__c Mfg : trigger.new) {
        try
        { 
            //populate the EnterpriseID by batch
            if (Trigger.isInsert)
            {
            MDM_Product_ProductGroup_PopulateIDBt  objbatch = new MDM_Product_ProductGroup_PopulateIDBt();
                 //if(!test.isrunningtest())
                 {
                     Database.executebatch(objbatch,5);
                 }
            }

            // For Update only
            if (Trigger.isUpdate)
            {
                MDM_Product_Group__c oMfg= trigger.oldMap.get(Mfg.id);
                if(oMfg.name <> Mfg.Name)
                {
                    String refobjName = 'ProductGroup';
                    id refObjId = Mfg.id;
                    String lstmodusr = UserInfo.getName(); 
                    MDM_Product_Reference_UpdatedBt  objbatch = new MDM_Product_Reference_UpdatedBt(refobjName,refObjId,lstmodusr);
                    //if(!test.isrunningtest())
                    {
                        Database.executebatch(objbatch,2);
                    }
                }
            }
           
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_ProductGroup_AfterUpsert '+e.getMessage());
            Mfg.addError( e.getMessage());
        }
        
        
    }
    
}