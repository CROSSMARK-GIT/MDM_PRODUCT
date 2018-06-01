trigger MDM_Product_Mfg_PrdCategory_BeforeUpsert on MDM_ManufacturerProductCategory__c (before insert, before update, before delete) {
    
    if(Trigger.isDelete)
    {
        for( MDM_ManufacturerProductCategory__c mfc : Trigger.old )
        {
            List<MDM_Product__c>  rlist = new List<MDM_Product__c>();
            rlist =   [SELECT Id ,name  FROM MDM_Product__c where ManufacturerCategory__c =: mfc.id    limit 1];
            if(rlist.size()>0)
            {
                mfc.addError('Manufacturer ProductCategory is already in use. Can not be deleted.');
            }
        }
        
    }
    Else
    {
        for( MDM_ManufacturerProductCategory__c mfc : Trigger.new )
        {
            try
            {
                system.debug('MDM_Product_Mfg_PrdCategory_BeforeUpsert'+ mfc.name + '::' + mfc.id);
                List<MDM_ManufacturerProductCategory__c>  rlist = new List<MDM_ManufacturerProductCategory__c>();
                rlist =   [SELECT Id ,name,manufacturer__C FROM MDM_ManufacturerProductCategory__c where name =: mfc.name and manufacturer__C =: mfc.manufacturer__C  limit 1];
                if(rlist.size()>0)
                {
                    MDM_ManufacturerProductCategory__c lb0 = rlist[0];
                    if (Trigger.isInsert)
                    {
                        mfc.addError('Manufacturer ProductCategory Name already exisit for the same maufacturer  SFID::'+lb0.id);
                    }
                    if (Trigger.isUpdate)
                    {
                        if(lb0.id != mfc.id)
                        {
                            mfc.addError('Manufacturer ProductCategory Name already exisit for the same maufacturer  SFID::'+lb0.id);
                        }
                        else
                        {
                        //Allow to update enterpriseid.    
                        }
                        // Manufacturer assignment can't be chnaged when the Manufacturer::Manufacturer ProductCategory Combination assigned to any products.
                        /*List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where  ManufacturerCategory__c =: mfc.id    limit 1];
                        if(rlist1.size()>0)
                        {
                            mfc.addError('Manufacturer -  Manufacturer ProductCategory  is already in product use. Manuifacturer Can not be Modified.');
                        } */                       
                    }
                }
                // Manufacturer assignment can't be chnaged when the Manufacturer::  Manufacturer ProductCategory  Combination assigned to any products.
                if (Trigger.isUpdate)
                    {
                        MDM_ManufacturerProductCategory__c oldmfc= Trigger.oldMap.get(mfc.Id);
                        List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where  ManufacturerCategory__c =: mfc.id and Manufacturer__C =: oldmfc.manufacturer__C    limit 1];
                        if(rlist1.size()>0)
                        {
                            if(oldmfc.manufacturer__C != mfc.manufacturer__C)
                            {
                             mfc.addError('Manufacturer -  Manufacturer ProductCategory  is already in product use. Manufacturer Can not be Modified.');
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
                
                System.debug('==Exception Message === MDM_Product_Mfg_PrdCategory_BeforeUpsert '+e.getMessage());
                mfc.addError( e.getMessage());
            }
        }
    }
}