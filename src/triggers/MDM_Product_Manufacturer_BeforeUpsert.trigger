trigger MDM_Product_Manufacturer_BeforeUpsert on MDM_Manufacturer__c (before insert, before update, before delete) {
    
    if(Trigger.isDelete)
    {
        for( MDM_Manufacturer__c brd : Trigger.old )
        {
            List<MDM_Product__c>  rlist0 = new List<MDM_Product__c>();
            rlist0 =   [SELECT Id ,name  FROM MDM_Product__c where  Manufacturer__c =: brd.id    limit 1];
            
            List<MDM_Brand__c>  rlist1 = new List<MDM_Brand__c>();
            rlist1 =   [SELECT Id ,name  FROM MDM_Brand__c where  Manufacturer__c =: brd.id    limit 1];
            
            List<MDM_Product_Group__c>  rlist2 = new List<MDM_Product_Group__c>();
            rlist2 =   [SELECT Id ,name  FROM MDM_Product_Group__c where  Manufacturer__c =: brd.id    limit 1];
            
            List<MDM_ManufacturerProductCategory__c>  rlist3 = new List<MDM_ManufacturerProductCategory__c>();
            rlist3 =   [SELECT Id ,name  FROM MDM_ManufacturerProductCategory__c where  Manufacturer__c =: brd.id    limit 1];
            
            if(rlist0.size()>0 || rlist1.size()>0 || rlist2.size()>0|| rlist3.size()>0)
                {
                    brd.addError('Maufacturer is already in use. Can not be deleted.');
                }
        }
        
    }
    Else
    {
        for( MDM_Manufacturer__c mfg : Trigger.new )
        {
            try
            {
                system.debug('MDM_Product_Brand_BeforeUpsert'+ mfg.name + '::' + mfg.id);
                List<MDM_Manufacturer__c>  rlist = new List<MDM_Manufacturer__c>();
                rlist =   [SELECT Id ,name, EnterpriseID__C  FROM MDM_Manufacturer__c where name =: mfg.name  limit 1];
                if(rlist.size()>0)
                {
                    MDM_Manufacturer__c lb0 = rlist[0];
                    if (Trigger.isInsert)
                    {
                        mfg.addError('Maufacturer Name already exisit  for the maufacturer  SFID::'+lb0.id + '   EnterpriseID ::'+lb0.EnterpriseID__C) ;
                    }
                    if (Trigger.isUpdate)
                    {
                        if(lb0.id != mfg.id)
                        {
                            mfg.addError('Maufacturer Name already exisit for the  maufacturer  SFID::'+lb0.id + '   EnterpriseID ::'+lb0.EnterpriseID__C) ;
                        }
                    }
                }
                if (Trigger.isUpdate)
                {
                    MDM_Manufacturer__c oldMfg = Trigger.oldMap.get(mfg.Id);
                        
                        List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where   Manufacturer__C =: mfg.Id  limit 1];
                        if(rlist1.size()>0)
                        {
                            
                            if(oldMfg.TPM_DefaultBusinessUnit__c != mfg.TPM_DefaultBusinessUnit__c && oldMfg.TPM_DefaultBusinessUnit__c != null)
                            {
                            mfg.addError('Manufacturer - is already in product use. Default CPG Toolbox Business Unit Can not be Modified');    
                            }
                            else
                            {
                            //free to update enterpriseid and brand name    
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
                
                System.debug('==Exception Message === MDM_Product_Manufacturer_BeforeUpsert '+e.getMessage());
                mfg.addError( e.getMessage());
            }
        }
    }
}