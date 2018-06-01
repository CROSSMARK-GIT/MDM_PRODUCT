trigger MDM_Product_Stage_BeforeUpsertProduct on MDM_Product_Stage__c (before insert) {
    String errMsg= ''; //'Duplicate product already exist.';
    String warMsg= ''; //'Duplicate product already exist.';
    List<MDM_Product_Stage__c> lstProducts = (List <MDM_Product_Stage__c> ) Trigger.new;
    MDM_Product_Helper Vald = new MDM_Product_Helper();
    for (MDM_Product_Stage__c lstProduct: lstProducts ) {
        try
        {
            MDM_Product__c lProduct = Vald.convertProductStage_TO_Product(lstProduct);
            // Get a matching product avilable in Master
            List<MDM_Product__c> plst=[SELECT Name,  Id, Manufacturer__c,Brand__C  FROM MDM_Product__c where Manufacturer__c =: lstProduct.Manufacturer__c
                                           and Brand__c=:lstProduct.Brand__c  and UPC12__c =: lstProduct.UPC12__c  and name = : lstProduct.Name];
                if(plst.size() > 0)
                {
                lProduct.id = plst[0].id;
                    system.debug( 'MDM_Product_Stage_BeforeUpsertProduct  ' + plst[0].id+'Match found Name  : already exist'+plst[0].name);
                }
            
            List<String>  retv = Vald.IsValidProduct(lProduct);
           
            IF(retv.size() == 3)
            {
                IF(!Boolean.valueOf(retv[0]))
                {
                    errMsg = retv[2];
                }
                else
                {
                    errMsg = 'IsValidProduct Function error:'+retv.size();  
                }
                lstProduct.addError('Error: ' + errMsg );
            }
            string strSourceSystem = lstProduct.SourceSystem__c;
            string strIdFromSource = lstProduct.IdFromSource__c;
            system.debug('Stage before insert'+ strSourceSystem + ' : ' + strIdFromSource );
            List<MDM_Product_Stage__c>  rlist = new List<MDM_Product_Stage__c>();
            rlist =   [SELECT Id FROM MDM_Product_Stage__c where SourceSystem__c =:strSourceSystem.trim()  AND IdFromSource__c =:strIdFromSource.trim() ];
            delete rlist;   
            
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_StageBeforeUpsertProduct '+e.getMessage());
            lstProduct.addError( e.getMessage());
        }
    } 
}