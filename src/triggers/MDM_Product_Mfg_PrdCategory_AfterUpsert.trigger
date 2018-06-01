trigger MDM_Product_Mfg_PrdCategory_AfterUpsert on MDM_ManufacturerProductCategory__c (after Insert, after update) {
    List<MDM_ManufacturerProductCategory__c> lstResponses = new List<MDM_ManufacturerProductCategory__c>();
    MDM_Questions__c q = new MDM_Questions__c();
    for (MDM_ManufacturerProductCategory__c Mfg : trigger.new) {
        try
        {
            //populate the EnterpriseID by batch
            if (Trigger.isInsert)
            {
            MDM_Product_Mfg_PrdCategory_PopulateIDBt  objbatch = new MDM_Product_Mfg_PrdCategory_PopulateIDBt();
                 //if(!test.isrunningtest())
                 {
                     Database.executebatch(objbatch,5);
                 }
            }

            // For Update only
            if (Trigger.isUpdate)
            {
                MDM_ManufacturerProductCategory__c oMfg= trigger.oldMap.get(Mfg.id);
                if(oMfg.name <> Mfg.Name)
                {
                    String refobjName = 'ManufacturerProductCategory';
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
            System.debug('==Exception Message === MDM_Product_ProductCategory_AfterUpsert '+e.getMessage());
            Mfg.addError( e.getMessage());
        }
        
        
    }
    
}