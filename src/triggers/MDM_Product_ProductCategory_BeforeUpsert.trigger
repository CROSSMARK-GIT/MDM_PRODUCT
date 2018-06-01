trigger MDM_Product_ProductCategory_BeforeUpsert on MDM_ProductCategory__c (before insert, before update, before delete) {
    
    if(Trigger.isDelete)
    {
        for( MDM_ProductCategory__c cat : Trigger.old )
        {
            List<MDM_Product__c>  rlist = new List<MDM_Product__c>();
            rlist =   [SELECT Id ,name  FROM MDM_Product__c where  Category__c =: cat.id    limit 1];
            if(rlist.size()>0)
            {
                cat.addError('Category  is already in use. Can not be deleted.');
            }
        }
        
    }
    Else
    {
        for( MDM_ProductCategory__c cat : Trigger.new )
        {
            try
            {
                system.debug('MDM_Product_ProductCategory_BeforeUpsert'+ cat.name + '::' + cat.id);
                List<MDM_ProductCategory__c>  rlist = new List<MDM_ProductCategory__c>();
                rlist =   [SELECT Id ,name  FROM MDM_ProductCategory__c where name =: cat.name    limit 1];
                if(rlist.size()>0)
                {
                    MDM_ProductCategory__c lb0 = rlist[0];
                    if (Trigger.isInsert)
                    {
                        cat.addError('Category Name already exisit  SFID::'+lb0.id);
                    }
                    if (Trigger.isUpdate)
                    {
                        if(lb0.id != cat.id)
                        {
                            cat.addError('Category Name already exisit    SFID::'+lb0.id);
                        }
                                                
                    }
                }
                 
                
                
            }
            catch(Exception e)
            {
                
                System.debug('==Exception Message === MDM_Product_Brand_BeforeUpsert '+e.getMessage());
                cat.addError( e.getMessage());
            }
        }
    }
}