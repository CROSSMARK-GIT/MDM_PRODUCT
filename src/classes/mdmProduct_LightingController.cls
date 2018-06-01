global with sharing class mdmProduct_LightingController {
    private final String[] arrayItems;
    private final List<mdm_Product__c> mdmprdlst;  
    @AuraEnabled
    public static List<String> getStringArray() {
        String[] arrayItems = new String[]{ 'red', 'green', 'blue' ,'rama11'};
            return arrayItems;
    }
    @AuraEnabled
    Public static List<mdm_Product__c> getmdmProducts(){
        List<mdm_Product__c> mdmprdlst = new List<mdm_Product__c>();
        mdmprdlst = [select ID,Name,UPC12__C,Description__C  from mdm_product__C limit 10 ];
        return mdmprdlst;
        //turn [select ID,Name,UPC__C,Description__C  from mdm_product__C limit 10 ];
        
    }
    //@AuraEnabled
    /*Public Static List<mdm_Product__c> getmdmProductsByFilter()
{
List<mdm_Product__c> mdmprdlst = new List<mdm_Product__c>();
mdmprdlst = [select ID,Name,UPC__C,Description__C  from mdm_product__C limit 25 ];
return mdmprdlst;

*/
    @AuraEnabled
    Public Static List<mdm_Product__c> getmdmProductsByFilter(String searchStr )
    {
        List<mdm_Product__c> lproductlst = new List<mdm_Product__c>();
        string sstr = '%'+searchStr+'%';
        //lproductlst = [select ID,Name,UPC12__C,Description__C  from mdm_product__C where Description__C like :=sstr  limit 10 ];
        lproductlst = [select ID,Name,UPC12__C,Description__C  from mdm_product__C where Description__C  like :  sstr limit 100 ];
        return lproductlst;  
    }
    @AuraEnabled
    Public Static List<mdm_Product__c> getmdmProductsByFilter1(String searchStr ,String searchType)
    {
        
        List<mdm_Product__c> lproductlst = new List<mdm_Product__c>();
        string sstr = '%'+searchStr+'%';
        try{
            if(searchType.contains('UPC'))
            {
                lproductlst = [select ID,Name,UPC12__C,Description__C  from mdm_product__C where UPC12__C  like :  sstr limit 10  ];
            }
            else if(searchType.contains('Description'))
            {
                lproductlst = [select ID,Name,UPC12__C,Description__C  from mdm_product__C where Description__C  like :  sstr limit 20   ];
            }
        }
        catch (Exception exx)
        {
            throw new AuraHandledException('Something went wrong: '  + exx.getMessage());
        }
        finally
        {
            
        }
        
        return lproductlst;  
    }
}