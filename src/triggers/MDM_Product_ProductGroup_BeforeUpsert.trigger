trigger MDM_Product_ProductGroup_BeforeUpsert on MDM_Product_Group__c (before insert, before update,before delete) {
    if(Trigger.isDelete)
    {
        for( MDM_Product_Group__c pg : Trigger.old )
        {
            List<MDM_Product__c>  rlist = new List<MDM_Product__c>();
            rlist =   [SELECT Id ,name  FROM MDM_Product__c where  Product_Group__c =: pg.id    limit 1];
            if(rlist.size()>0)
            {
                pg.addError('Product group is already in use. Can not be deleted.');
            }
        }
        
    }
    Else
        
    {
        for( MDM_Product_Group__c pct : Trigger.new )
        {
            try
            {
                system.debug('MDM_Product_ProductGroup_BeforeUpsert'+ pct.name + '::' + pct.id);
                List<MDM_Product_Group__c>  rlist = new List<MDM_Product_Group__c>();
                rlist =   [SELECT Id ,name,manufacturer__C FROM MDM_Product_Group__c where name =: pct.name and manufacturer__C =: pct.manufacturer__C  limit 1];
                if(rlist.size()>0)
                {
                    MDM_Product_Group__c lb0 = rlist[0];
                    if (Trigger.isInsert)
                    {
                        pct.addError('Product Group Name already exisit for the same maufacturer  SFID::'+lb0.id);
                    }
                    if (Trigger.isUpdate)
                    {
                        if(lb0.id != pct.id)
                        {
                            pct.addError('Product Group Name already exisit for the same maufacturer  SFID::'+lb0.id);
                        }
                        else
                        {
                        //Allow to update enterpriseid.    
                        }
                        
                    }
                }
                // Manufacturer assignment can't be chnaged when the Manufacturer::Product Group Combination assigned to any products.
                if (Trigger.isUpdate)
                    {
                        MDM_Product_Group__c oldpc= Trigger.oldMap.get(pct.Id);
                        List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where  Product_Group__c =: pct.id  and Manufacturer__C =: oldpc.manufacturer__C     limit 1];
                        if(rlist1.size()>0)
                        {
                            if(oldpc.manufacturer__C != pct.manufacturer__C)
                            {
                             pct.addError('Manufacturer - Product Group is already in product use. Manufacturer Can not be Modified.');
                            }
                            else
                            {
                            //free to update enterpriseid and Manufacturer Category name    
                            }
                            
                        }
                        else
                        {
                            //free to update all fields
                            
                        } 
                        
                    }
                
            }
            catch(Exception e)
            {
                
                System.debug('==Exception Message === MDM_Product_ProductGroup_BeforeUpsert '+e.getMessage());
                pct.addError( e.getMessage());
            }
        }
    }
}