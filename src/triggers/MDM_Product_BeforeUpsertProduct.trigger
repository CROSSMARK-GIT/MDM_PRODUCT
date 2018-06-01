trigger MDM_Product_BeforeUpsertProduct on MDM_Product__c (before insert,before update) {
    String errMsg= ''; //'Duplicate product already exist.';
    String warMsg= ''; //'Duplicate product already exist.';
    List<MDM_Product__c> lstProducts = (List <MDM_Product__c> ) Trigger.new;
    MDM_Product_Helper Vald = new MDM_Product_Helper();
    for (MDM_Product__c lstProduct: lstProducts ) {
        try
        {
            //List<String>  retv = Vald.IsValidProduct(lstProduct);
            List<String>  retv = Vald.IsValidProduct(lstProduct);
            
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

             
            
        }
        catch(Exception e)
        {
            System.debug('==Exception Message === MDM_Product_BeforeUpsertProduct '+e.getMessage());
            lstProduct.addError( e.getMessage());
        }
    } 
}