trigger MDM_Product_Brand_BeforeUpsert on MDM_Brand__c (before insert, before update, before delete) {
    
    if(Trigger.isDelete)
    {
        for( MDM_Brand__c brd : Trigger.old )
        {
            List<MDM_Product__c>  rlist = new List<MDM_Product__c>();
            rlist =   [SELECT Id ,name  FROM MDM_Product__c where  Brand__c =: brd.id    limit 1];
            if(rlist.size()>0)
            {
                brd.addError('Brand is already in use. Can not be deleted.');
            }
        }
        
    }
    Else
    {
        for( MDM_Brand__c brd : Trigger.new )
        {
            try
            {
                system.debug('MDM_Product_Brand_BeforeUpsert'+ brd.name + '::' + brd.id);
                List<MDM_Brand__c>  rlist = new List<MDM_Brand__c>();
                rlist =   [SELECT Id ,name,manufacturer__C FROM MDM_Brand__c where name =: brd.name and manufacturer__C =: brd.manufacturer__C  limit 1];
                if(rlist.size()>0)
                {
                    MDM_Brand__c lb0 = rlist[0];
                    if (Trigger.isInsert)
                    {
                        brd.addError('Brand Name already exisit for the same maufacturer  SFID::'+lb0.id);
                    }
                    if (Trigger.isUpdate)
                    {
                        if(lb0.id != brd.id)
                        {
                            brd.addError('Brand Name already exisit for the same maufacturer  SFID::'+lb0.id);
                        }
                        else
                        {
                        //Allow to update enterpriseid.    
                        }
                        
                        
                        // Manufacturer assignment can't be chnaged when the Manufacturer::brand Combination assigned to any products.
                       /* List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where  Brand__c =: brd.id    limit 1];
                        if(rlist1.size()>0)
                        {
                            brd.addError('Manufacturer - Brand is already in product use. Manuifacturer Can not be Modified.1');
                        }*/                        
                    }
                }
                // Manufacturer assignment can't be chnaged when the Manufacturer::brand Combination assigned to any products.
                if (Trigger.isUpdate)
                    {
                        MDM_Brand__c oldBrand = Trigger.oldMap.get(brd.Id);
                        
                        List<MDM_Product__c>  rlist1 = new List<MDM_Product__c>();
                        rlist1 =   [SELECT Id ,name  FROM MDM_Product__c where  Brand__c =: brd.id  and Manufacturer__C =: oldBrand.manufacturer__C  limit 1];
                        if(rlist1.size()>0)
                        {
                            
                            if(oldBrand.manufacturer__C != brd.manufacturer__C)
                            {
                            brd.addError('Manufacturer - Brand is already in product use. Manufacturer Can not be Modified');    
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
                
                System.debug('==Exception Message === MDM_Product_Brand_BeforeUpsert '+e.getMessage());
                brd.addError( e.getMessage());
            }
        }
    }
}