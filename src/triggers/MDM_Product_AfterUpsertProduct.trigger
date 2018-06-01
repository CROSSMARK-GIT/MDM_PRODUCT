trigger MDM_Product_AfterUpsertProduct on MDM_Product__c (after Insert, after update) {
    MDM_Source__c srcID = [SELECT Id FROM MDM_Source__c where Name = 'SalesForce-Product' and Domain__C = 'MDM_Product'];
    // trigger.new[0].SourceSystem__c=srcID.ID ;
    List<MDM_Product_Stage__c> listProducts = new List<MDM_Product_Stage__c>();

    for (MDM_Product__c oProduct : trigger.new) {
        MDM_Product_Stage__c oProduct_Stage = new MDM_Product_Stage__c();
        
        oProduct_Stage = MDM_Product_Helper.convertProduct_TO_ProductStage(oProduct);
        oProduct_Stage.SourceSystem__c= srcID.ID;// oLocation.SourceSystem__c;
        listProducts.add(oProduct_Stage);
    }
    if (listProducts.isEmpty() == false) {
         //Database.insert(listProducts);
        try{
         MDM_Product_Helper.sleep(1000);
         Database.insert(listProducts);
        }
        catch(Exception e)
        {
            system.debug('MDM_Product_AfterUpsertProduct'+e.getMessage());
        }
    }
}