trigger MDM_Product_Country_AfterUpsert on MDM_Product_Country__c (after Insert, after update) {
    for (MDM_Product_Country__c Mfg : trigger.new) {
        try
        { 
            //populate the EnterpriseID by batch
            if (Trigger.isInsert)
            {
            MDM_Product_Brand_PopulateIDBt  objbatch = new MDM_Product_Brand_PopulateIDBt();
                 if(!test.isrunningtest())
                 {
                     Database.executebatch(objbatch,5);
                 }
            }

            // For Update only
            if (Trigger.isUpdate)
            {
                MDM_Product_Country__c oMfg= trigger.oldMap.get(Mfg.id);
                if(oMfg.name <> Mfg.Name)
                {
                    String refobjName = 'ProductCountry';
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
            System.debug('==Exception Message === MDM_Product_Country_AfterUpsert '+e.getMessage());
            Mfg.addError( e.getMessage());
        }
        
        
    }
    
}