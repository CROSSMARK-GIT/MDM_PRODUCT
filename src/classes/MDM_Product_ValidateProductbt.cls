global with sharing class MDM_Product_ValidateProductbt implements Database.Batchable<MDM_BulkUpload__C>,Database.Stateful{
    
    boolean isValidRecord;
    boolean isValidRow;
    String validationErrMsg;
    String[] csvRecordData ;
    List < MDM_Product__c > productMasterList;
    global string batchStartdt;
    global string batchEnddt;
    global integer validrows;
    global integer invalidrows;
    global integer validrecords;
    global integer invalidrecords;
    global Set<string> AllIdfromSource;
    global String Query;
    global String UploadName;
    global list<MDM_BulkUpload__c> blList;
    global String locationSource;
    global String locationSourceName;
    global String idfromSource;
    
    global MDM_Product_ValidateProductbt(string pfilename){
        UploadName= pfilename;
    }
    
    global Iterable<MDM_BulkUpload__C> start(Database.BatchableContext BC){
        string errMsg = 'Error : ';
        system.debug('Iterable<MDM_BulkUpload__C>');
        AllIdfromSource = new Set<String>();
        batchStartdt =  Datetime.now().format('MM/dd/yyyy hh:mm a');
        system.debug('MDM_BulkUpload__C get upload id and uploads list : start');
        try
        {
            MDM_BulkUpload__C locblkLoc=  [SELECT Name,MDM_Source__c FROM MDM_BulkUpload__C where Name  =: UploadName limit 1]; 
            locationSource = locblkLoc.MDM_Source__c ;
            blList= [SELECT ID,Name, Uploaded_Row_Original__c  FROM MDM_BulkUpload__C where name = : locblkLoc.name  and IsProcessed__c  = false limit 5000]; 
        }
        catch (System.DmlException e) {
            System.debug('Iterable<MDM_BulkUpload__C> start' + e);
        } catch (Exception e) {
            System.debug('Iterable<MDM_BulkUpload__C> start' + e);
        }
        system.debug('Iterable<MDM_BulkUpload__C > start' + blList);
        return blList;
    }
    global void execute(Database.BatchableContext BC, List<MDM_BulkUpload__C> scope){
        validrows = 0;
        invalidrows = 0;
        validrecords = 0;
        invalidrecords = 0;
        
        MDM_Location_Stage__c locLocationStageObj;  
        MDM_Location__c locmasterLocationObj;
        MDM_Product_Stage__c locProductStageObj;  
        MDM_Product__c locmasterProductObj;
        
        productMasterList = New List < MDM_Product__c > ();
        try
        {
            system.debug('Step 000 Get product reference');
            // get all reference data 
            Set<String> locOtherIdentifierTypes =  getOtherIdentifierTypes(); 
            Set<String> locStatus =  getStatus(); 
            Set<String> locWeightUnitofMeasures =  getWeightUnitofMeasures(); 
            Set<String> locSizeUnitofMeasures =  getSizeUnitofMeasures(); 
            Set<String> locDimensionUnitofMeasures =  getDimensionUnitofMeasures(); 
            Set<String> locPackageUnits =  getPackageUnits(); 
            
            List<MDM_Manufacturer__c> locManufacturers = getManufacturers();
            Map<String, String>  manufacturerMap  = new Map<String,String>();
            for(MDM_Manufacturer__c t : locManufacturers){
                manufacturerMap.put(t.Name.toUpperCase(), t.ID);
            }
            
            
            List<MDM_Brand__c> locBrands = getBrands();
            //Manufacturer and Brand name as key for Brand code
            Map<String, String>  brandMap  = new Map<String,String>();
            for(MDM_Brand__c t : locBrands){
                string cs = t.MAnufacturer__r.Name.toUpperCase() + t.Name.toUpperCase();
                brandMap.put(cs.toUpperCase(), t.ID);
            }
            
            List<MDM_ProductCategory__c> locProductCategory = getProductCategory();
            Map<String, String>  productCategoryMap  = new Map<String,String>();
            for(MDM_ProductCategory__c t : locProductCategory){
                productCategoryMap.put(t.Name.toUpperCase(), t.ID);
            }
            
            List<MDM_ManufacturerProductCategory__c> locManufacturerProductCategory = getManufacturerProductCategory();
            //Manufacturer and ManufacturerProductCategory name as key for ManufacturerProductCategory code
            Map<String, String>  manufacturerProductCategoryMap  = new Map<String,String>();
            for(MDM_ManufacturerProductCategory__c t : locManufacturerProductCategory){
                string cs = t.Manufacturer__r.Name.toUpperCase() + t.Name.toUpperCase();
                manufacturerProductCategoryMap.put(cs.toUpperCase(), t.ID);
            }
            
            List<MDM_Product_Group__c> locProductGroups = getProductGroups();
            //Manufacturer and Brand name as key for Brand code
            Map<String, String>  productGroupsMap  = new Map<String,String>();
            for(MDM_Product_Group__c t : locProductGroups){
                string cs = t.MAnufacturer__r.Name.toUpperCase() + t.Name.toUpperCase();
                productGroupsMap.put(cs.toUpperCase(), t.ID);
            }
            
            
            
            MDM_Source__c ls = [SELECT Id, Name FROM MDM_Source__c where id= : LocationSource limit 1];
            locationSourceName = ls.Name;
            
            
            //start processing the products
            system.debug('Step 001 number of records ' + scope.size() );
            string delimitercharacter =getDelimitercharacter();
            for (Integer i = 0; i < scope.size(); i++){
                
                string srcType = '';
                string strName = '';
                string strshortDescription = '';
                string strDescription = '';
                string strManufacturerDescription = '';
                string upc12= '';
                string upc8= '';
                string upc13= '';
                string upc14= '';
                string GTIN = '';
                string ManufacturerIdentifier= '';
                
                string Manufacturer = '';
                string Brand = ''; 
                string Category = ''; 
                string ManufacturerCategory = '';
                string ProductGroup = '';
                string CasePack = '';
                string CaseUPC = '';
                string Size = '';
                string SizeUnitofMeasure = '';
                string Status = '';
                string ConsumerProduct = '';
                string OrderableProduct= '';
                string PlanningProduct= '';
                string CostofGoodsSold = '';
                string DefaultUnitPrice = '';
                string DefaultUnitDeliveredCost = '';
                string IgnoreWarnings = '';
                string IdFromSource = '';
                
                
                
                isValidRecord = true;
                IsValidRow = true;   
                validationErrMsg  = 'Error: Invalid Row: ';
                string csvRecord =  scope[i].Uploaded_Row_Original__c;
                //csvRecord = csvRecord.replace('&#124;', '|');
                if((delimitercharacter == '&#124;') ||(delimitercharacter == '|'))
                {
                    delimitercharacter = '\\|';
                }
                csvRecordData = csvRecord.split(delimitercharacter);
                system.debug('step 001.1 csvRecordData.size() ' + csvRecordData.size() ); 
                system.debug('step 001.2 csvRecordData.size() ' + csvRecord + ' : ' + 'delimitercharacter  '+ delimitercharacter ); 
                if(csvRecordData.size() != 29 )
                {
                    validationErrMsg = validationErrMsg + 'row' + i+'   Number of columns: '+ csvRecordData.size();
                    IsValidRow = false;
                }
                else
                {   
                    system.debug('Step 002 Start Process row  ' + i );
                    //Source validation can't be blank  only allowed value is cmk_mdm_Product
                    srcType = csvRecordData[0].trim();
                    strName = csvRecordData[1].trim();
                    strshortDescription = csvRecordData[2].trim();
                    strDescription = csvRecordData[3].trim();
                    strManufacturerDescription = csvRecordData[4].trim();
                    upc12= csvRecordData[5].trim(); 
                    upc8= csvRecordData[6].trim();  
                    upc13= csvRecordData[7].trim();
                    upc14= csvRecordData[8].trim(); 
                    GTIN= csvRecordData[9]; 
                    ManufacturerIdentifier= csvRecordData[10].trim(); 
                    
                    Manufacturer = csvRecordData[11].trim(); 
                    Brand = csvRecordData[12].trim(); 
                    Category = csvRecordData[13].trim(); 
                    ManufacturerCategory = csvRecordData[14].trim(); 
                    ProductGroup = csvRecordData[15].trim(); 
                    CasePack = csvRecordData[26].trim(); 
                    CaseUPC = csvRecordData[17].trim(); 
                    Size = csvRecordData[18].trim(); 
                    SizeUnitofMeasure = csvRecordData[19].trim(); 
                    Status = csvRecordData[20].trim(); 
                    ConsumerProduct = csvRecordData[21].trim(); 
                    OrderableProduct= csvRecordData[22].trim(); 
                    PlanningProduct = csvRecordData[23].trim(); 
                    CostofGoodsSold = csvRecordData[24].trim(); 
                    DefaultUnitPrice = csvRecordData[25].trim(); 
                    DefaultUnitDeliveredCost = csvRecordData[26].trim(); 
                    IgnoreWarnings = csvRecordData[27].trim(); 
                    IdFromSource = csvRecordData[28].trim(); 
                    
                    
                    
                    if(srcType != 'cmk_mdm_Product' )
                    {
                        validationErrMsg = validationErrMsg + ' Source should be cmk_mdm_Product ' + csvRecordData.size();
                        IsValidRow = false;
                    }
                    if(strName == '' )
                    {
                        validationErrMsg = validationErrMsg + ' Name Can not be blank ' + csvRecordData.size();
                        IsValidRow = false;
                    }
                    //short Description max lenght 50
                    if(strshortDescription.length() > 50 || strshortDescription.length() < 0)
                    {
                        validationErrMsg = validationErrMsg + ' Sort Description max length 50 and required' + csvRecordData.size();
                        IsValidRow = false;
                    }
                    // Description max lenght 150
                    
                    if(strDescription.length() > 150 || strshortDescription.length() < 0)
                    {
                        validationErrMsg = validationErrMsg + '  Description max length 150 and required ' + csvRecordData.size();
                        IsValidRow = false;
                    }
                    // Manufacturer Description max lenght 150
                    
                    if(strManufacturerDescription.length() > 150 )
                    {
                        validationErrMsg = validationErrMsg + '  Manufacturer description max length 150 ' + csvRecordData.size();
                        IsValidRow = false;
                    }
                    //UPC 12 validation 
                    
                    //if(upc12.trim() == '' || upc12.length() >12  || !upc12.isNumeric())
                    if(String.isNotBlank(upc12) && (upc12.length() >12  || !upc12.isNumeric()))
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid UPC 12 ,';
                        system.debug('Error Invalid UPC-12 '+ csvRecordData[2]);
                        IsValidRow = false;
                    } 
                    
                    if(String.isNotBlank(upc8) && (upc8.length() != 8   || !upc8.isNumeric()))
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid EAN-8 ,';
                        system.debug('Error Invalid EAN-8 '+ csvRecordData[2]);
                        IsValidRow = false;
                    } 
                    
                    if(String.isNotBlank(upc13) &&  (upc13.length() != 13  || !upc13.isNumeric())  )
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid EAN-13 ,';
                        system.debug('Error Invalid EAN-13 '+ csvRecordData[2]);
                        IsValidRow = false;
                    } 
                    
                    if( String.isNotBlank(upc14) &&  (upc14.length() != 14  || !upc14.isNumeric()) )
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid EAN-14 ,';
                        system.debug('Error Invalid EAN-14 '+ csvRecordData[2]);
                        IsValidRow = false;
                    } 
                    
                    if( String.isNotBlank(GTIN) && GTIN.length() >16  )
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid GTIN ,';
                        system.debug('Error Invalid GTIN '+ csvRecordData[2]);
                        IsValidRow = false;
                    } 
                    /*
if(locOtherIdentifierTypes.contains(OtherIdentifierType.toUpperCase()))
{
validationErrMsg = validationErrMsg + ' Invlaid Other Identifier Type Type,';
system.debug('Error Other Identifier Type Type'+ csvRecordData[10]);
IsValidRow = false;
}
else
{
if( OtherIdentifier.length() >128  )
{
validationErrMsg = validationErrMsg + ' Other Identifier Max length 128';
system.debug('Error Invalid Other Identifier '+ csvRecordData[9]);
IsValidRow = false;
}
}*/
                    
                    if( ManufacturerIdentifier.length() >100  )
                    {
                        validationErrMsg = validationErrMsg + ' Invlaid Manufacturer Identifier (Max 100 chars),';
                        system.debug('Error Invalid Manufacturer Identifier '+ csvRecordData[11]);
                        IsValidRow = false;
                    }
                    
                    
                    system.debug('Step 002 Start Process row  ' + i );
                    system.debug('AllIdfromSource' + ' ' +AllIdfromSource ); 
                    if(AllIdfromSource.contains(IdFromSource))
                    {
                        if(locationSourceName  == 'SalesForce-Product' && IdFromSource.trim() == '0') // '0' is default value for sales force new locations
                        {
                            validationErrMsg = validationErrMsg ;
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + '   Duplicate IdFromSource found '+ i;
                            IsValidRow = false; 
                        }
                        
                    }
                    
                    locmasterProductObj = new MDM_product__C();
                    system.debug('Step 002.1 IsValidRow  ' + i );
                }
                if(IsValidRow)
                {
                    
                    validationErrMsg  = 'Error:RECORD ';
                    validrows= validrows + 1;
                    string csvr = csvRecordData[0];
                    csvr = String.valueOf(csvr).trim();
                    
                    //Create the stage object
                    system.debug('step 3 Create scope[i] ' + csvRecord );
                    system.debug('step 3 Create the stage object ' + csvr);
                    
                    //----------------------------product
                    //set Manufacturer
                    
                    system.debug('============== test the vlaues  start !!!=============');  
                    try
                    {
                        locmasterProductObj.BulkUploadID__c = scope[i].ID;
                        locmasterProductObj.name    =  strName ;
                        locmasterProductObj.Short_Description__c    =  strshortDescription ;
                        locmasterProductObj.Description__c    =  strDescription;
                        locmasterProductObj.ManufacturerDescription__c    =  strManufacturerDescription;
                        
                        locmasterProductObj.UPC12__c    =  upc12;
                        locmasterProductObj.EAN8__c    =  upc8;
                        locmasterProductObj.EAN13__c    =  upc13;
                        locmasterProductObj.EAN14__c    =  upc14;
                        locmasterProductObj.GTIN__c    =  GTIN;
                        //locmasterProductObj.DomainSpecificID__c    =  csvRecordData[9];
                        //locmasterProductObj.DomainSpecificIDType__c    =  csvRecordData[10];
                        locmasterProductObj.ManufacturerID__c    =  ManufacturerIdentifier;
                        csvr = String.valueOf(Manufacturer.trim());
                        system.debug('mfg : csvr  ' + csvr);  
                        
                        if(manufacturerMap.containsKey(csvr.toUpperCase()))
                        {
                            //locLocationStageObj.Country__c = manufacturerMap.get(csvr.toUpperCase());
                            locmasterProductObj.Manufacturer__c = manufacturerMap.get(csvr.toUpperCase());
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + ' Invalid manufacturer ['+ csvr + '],';
                            IsValidRecord = false;
                        } 
                        //Brand                   
                        csvr = csvr + String.valueOf(Brand).trim();
                        system.debug('Brand : csvr  ' + csvr.toUpperCase());  
                        if(brandMap.containsKey(csvr.toUpperCase()))
                        {
                            locmasterProductObj.Brand__c=brandMap.get(csvr.toUpperCase());
                            //locLocationStageObj.State__c = locStateMap.get(csvr.toUpperCase());
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + ' Invalid Brand OR Manufacturer  combination ['+ csvr + '],';
                            IsValidRecord = false;
                        }  
                        //Category 
                        csvr = String.valueOf(Category).trim();
                        if(productCategoryMap.containsKey(csvr.toUpperCase()) || csvr == '' )
                        {
                            locmasterProductObj.Category__c =productCategoryMap.get(csvr.toUpperCase());
                            //locLocationStageObj.State__c = locStateMap.get(csvr.toUpperCase());
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + ' Invalid catogory ['+ csvr + '],';
                            IsValidRecord = false;
                        }  
                        
                        //Manufacturer category                   
                        csvr = String.valueOf(Manufacturer).trim() + String.valueOf(ManufacturerCategory).trim();
                        system.debug('Manufacturer Category : csvr  ' + csvr.toUpperCase());  
                        if(manufacturerProductCategoryMap.containsKey(csvr.toUpperCase()) || String.valueOf(ManufacturerCategory).trim() =='')
                        {
                            locmasterProductObj.ManufacturerCategory__c =manufacturerProductCategoryMap.get(csvr.toUpperCase());
                            //locLocationStageObj.State__c = locStateMap.get(csvr.toUpperCase());
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + ' Invalid manufacturer ProductCategory : Manufacturer  combination ['+ csvr + '],';
                            IsValidRecord = false;
                        } 
                        
                        //ProductGroup                   
                        csvr = String.valueOf(Manufacturer).trim() + String.valueOf(ProductGroup).trim();
                        system.debug('ProductGroup : csvr  ' + csvr.toUpperCase());  
                        if(productGroupsMap.containsKey(csvr.toUpperCase()) || String.valueOf(ProductGroup).trim() == '' )
                        {
                            locmasterProductObj.Product_Group__c =productGroupsMap.get(csvr.toUpperCase());
                        }
                        else
                        {
                            validationErrMsg = validationErrMsg + ' Invalid productGroups OR Manufacturer  combination ['+ csvr + '],';
                            IsValidRecord = false;
                        }  
                        
                        
                        
                        //Additional detail
                        locmasterProductObj.Case_Pack__c    = (String.IsNotBlank(CasePack)) ?Double.valueof(CasePack) : 0.0;
                        locmasterProductObj.Case_UPC__c     = CaseUPC;
                        locmasterProductObj.Size__c     = Size;
                        locmasterProductObj.Size_Unit_of_Measure__c     = SizeUnitofMeasure;
                        //locmasterProductObj.Package_Unit__c     = csvRecordData[21];
                        if(Status != null)
                        {
                            locmasterProductObj.Product_Status__c = Status;
                        }
                        //23 product Country 
                        //locmasterProductObj.End_Availability_Date__c    = (String.IsNotBlank(csvRecordData[31])) ?Date.valueOf(csvRecordData[24]):Null;
                        //locmasterProductObj.Start_Availability_Date__c  = (String.IsNotBlank(csvRecordData[31])) ?Date.valueOf(csvRecordData[25]) :NULL;  
                        
                        //Domain / Usage
                        locmasterProductObj.Is_Consumer_Product__c  = Boolean.valueOf(ConsumerProduct);
                        locmasterProductObj.Is_Orderable_Product__c     = Boolean.valueOf(OrderableProduct);
                        locmasterProductObj.Is_Planning_Product__c  = Boolean.valueOf(PlanningProduct);
                        //locmasterProductObj.Is_Shipping_Product__c  = Boolean.valueOf(csvRecordData[29]);
                        //locmasterProductObj.Is_Invoicable_Product__c    = Boolean.valueOf(csvRecordData[30]);
                        
                        //Pricing        
                        locmasterProductObj.Cost_of_Goods_Sold__c   = (String.IsNotBlank(CostofGoodsSold)) ?Double.valueof(CostofGoodsSold) : 0.0; 
                        locmasterProductObj.Default_Unit_Price__c   = (String.IsNotBlank(DefaultUnitPrice)) ?Double.valueof(DefaultUnitPrice) : 0.0; 
                        locmasterProductObj.Default_Unit_Delivered_Cost__c  = (String.IsNotBlank(DefaultUnitDeliveredCost)) ?Double.valueof(DefaultUnitDeliveredCost) : 0.0;
                        
                        //dimensions
                        
                        
                        
                        //locmasterProductObj.Package_Height__c   = (String.IsNotBlank(csvRecordData[17])) ?Double.valueof(csvRecordData[34]) : 0.0;//Double.valueof(csvRecordData[34]);
                        //locmasterProductObj.Package_Width__c    = (String.IsNotBlank(csvRecordData[17])) ?Double.valueof(csvRecordData[35]) : 0.0;//Double.valueof(csvRecordData[35]);
                        //locmasterProductObj.Package_Depth__c    = (String.IsNotBlank(csvRecordData[17])) ?Double.valueof(csvRecordData[36]) : 0.0;//Double.valueof(csvRecordData[36]);
                        //locmasterProductObj.Dimension_Unit_of_Measure__c    = csvRecordData[37];
                        //locmasterProductObj.Package_Weight__c   = (String.IsNotBlank(csvRecordData[17])) ?Double.valueof(csvRecordData[38]) : 0.0;//Double.valueof(csvRecordData[38]);
                        //locmasterProductObj.Weight_Unit_of_Measure__c   = csvRecordData[39];                    
                        locmasterProductObj.IgnoreWarnings__c   = Boolean.valueOf(IgnoreWarnings);
                        locmasterProductObj.IdFromSource__c = IdFromSource;
                    }
                    catch(Exception e)
                    {
                        system.debug('============== test the vlaues end !!!=============');                        
                        validationErrMsg = validationErrMsg ;
                        IsValidRecord = false;
                    } 
                    
                    csvr = String.valueOf(IdFromSource).trim();
                    
                    // Validate the source id if salesforceid
                    if(locationSourceName  == 'SalesForce-Product' && csvr != '') 
                    {
                        system.debug('step 333 SalesForce IsValidRecord ' + csvr); 
                        MDM_Location__c lt = new   MDM_Location__c();
                        //lt.id  = csvr;
                        List<MDM_Location__c> tl = new List<MDM_Location__c>();
                        List<MDM_Product__c> pl = new List<MDM_Product__c>();
                        // id ii  =  CASESAFEID(lt.id);
                        try
                        {
                            id manufacturerID = locmasterProductObj.Manufacturer__c;
                            // UPC-12 may be a id from source manufacturer
                            if(upc12 == IdFromSource)
                            {
                                system.debug('Step 002.3 UPC-12 may be a id from source manufacturer' + i );
                                //string upc12 = String.valueOf(csvRecordData[4]).trim();
                                pl = [select id from MDM_Product__c where UPC12__c = :upc12 limit 1 ];//and Manufacturer__C =: manufacturerID limit 1 ];
                                if(pl.size() > 0 )
                                {
                                    locmasterProductObj.id = pl[0].id;
                                    locmasterProductObj.IdFromSource__c = pl[0].id;
                                }
                                else
                                {
                                    locmasterProductObj.IdFromSource__c = '0';
                                    csvr= '0';
                                }
                                
                            }
                            // Manufacturer ID may be a id from manufacturer
                            else if(ManufacturerIdentifier == IdFromSource)
                            {
                                system.debug('Step 002.4 Manufacturer ID may be a id from manufacturer' + i );
                                string mfgid = String.valueOf(ManufacturerIdentifier).trim();
                                pl = [select id from MDM_Product__c where ManufacturerID__c= :mfgid and Manufacturer__C =: manufacturerID  ];
                                if(pl.size() > 0 )
                                { 
                                    locmasterProductObj.id = pl[0].id;
                                    locmasterProductObj.IdFromSource__c = pl[0].id;
                                }
                                else
                                {
                                    locmasterProductObj.IdFromSource__c = '0';
                                    csvr= '0';
                                }
                                
                            }
                            else if(csvr!='0') //// for new records to insert  set the column valus as 0
                            {
                                system.debug('Step 002.5  salsforce id check' + i );
                                pl = [select id from MDM_Product__c where id = :csvr];
                                if(pl.size() == 0 )
                                {
                                    IsValidRecord = false;
                                    validationErrMsg = validationErrMsg + ' Invalid SaleforceID for update ['+ csvr + '],';
                                }
                                
                            }
                        }
                        catch(Exception e)
                        {
                            system.debug('============== Invalid Salesforce id  exception caught!!!=============');                        
                            validationErrMsg = validationErrMsg + ' Invalid SaleforceID for update ['+ csvr + '],';
                            IsValidRecord = false;
                        } 
                        
                    }
                    
                    
                    
                    // Create the location master object
                    system.debug('step 1 Create the master object ' + csvr);                    
                    //Location__c locmasterLocationObj = new Location__c();
                    
                    
                    AllIdfromSource.add(locmasterProductObj.IdFromSource__c);
                }
                else // IsValidRow
                {
                    system.debug('Step 003.5  Not IsValidRow' + i );
                    IsValidRecord= false;
                }
                
                if(IsValidRecord){
                    system.debug('Step 003.6  IsValidRecord' + i );
                    system.debug('Step 003.7  IsValidRecord ' + IsValidRecord); 
                    
                    
                    
                    if(locationSourceName  == 'SalesForce-Product') 
                    {
                        system.debug('step 003.8 locationSourceName  ' + 'SalesForce-Product'); 
                        validationErrMsg ='';
                        try
                        {
                            //insert locmasterLocationObj;
                            validationErrMsg = 'Success: Validate and insert/update into Master';
                            if(locmasterProductObj.IdFromSource__c != '0') // for new records to insert  set the column valus as 0
                            {
                                locmasterProductObj.id = locmasterProductObj.IdFromSource__c;
                            }
                            productMasterList.add(locmasterProductObj);
                            
                        }
                        catch( Exception e) {
                            validationErrMsg = 'Error:'+ e.getMessage();
                            System.debug('An unexpected error has occurred: ' + e.getMessage());
                            scope[i].Status__c = 'INVALID ROW';
                            validationErrMsg = 'Error: Invalid Row : Can not get the SFID';
                        }
                        system.debug('step 003.9 record processed' +  validationErrMsg   );
                        //updateRecodsProcessed(scope[i].ID,validationErrMsg );
                        
                    }
                    
                }    
                else // invalid record
                {
                    invalidrows = invalidrows + 1;
                    system.debug('step 003.10 invalid record ' + csvRecord + validationErrMsg   );
                    //updateRecodsProcessed(scope[i].ID,'Error'+validationErrMsg );
                    scope[i].Status_Message__c = validationErrMsg.left(250);
                    scope[i].IsProcessed__c = true;
                    
                    if(validationErrMsg.contains('Error: Invalid Row'))
                    {
                        scope[i].Status__c = 'INVALID ROW';
                    }
                    
                    if(validationErrMsg.contains('Error:RECORD'))
                    {
                        scope[i].Status__c = 'INVALID RECORD';
                    }
                }
                
                system.debug('locmasterLocationObj> insert' + locmasterLocationObj);
                
                
            }//for end
            Boolean status;
            if(locationSourceName  == 'SalesForce-Product') {
                // insert master
                //Database.SaveResult[] srList = Database.insert(locationMasterList, false);
                System.debug('step 004.1 srList size  :'  );
                Database.UpsertResult[] srList = Database.upsert(productMasterList, MDM_Product__c.id ,false);
                integer inx = 0;
                string dbmsgStr = '';
                System.debug('srList size  :' + srList.size());
                for (Database.UpsertResult sr: srList) {
                    System.debug('sr.isSuccess()  : ' + sr.isSuccess());
                    if (sr.isSuccess()) {
                        validrecords = validrecords + 1;
                        // Operation was successful, so get the ID of the record that was processed
                        dbmsgStr  = 'Successfully inserted Location. Location ID:'  + sr.getId();
                        System.debug('Master Successfully inserted Location. Location ID: ' + sr.getId());
                        
                    } else {
                        invalidrecords = invalidrecords+ 1;
                        // Operation failed, so get all errors
                        string errMsg = 'The following error has occurred.';
                        for (Database.Error err: sr.getErrors()) {
                            System.debug('The following error has occur red.');
                            errMsg = errMsg + err.getStatusCode() + ': ' + err.getMessage();
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                            errMsg = errMsg + err.getStatusCode() + 'Fields that affected this error: ' + err.getFields();
                            dbmsgStr  = 'Error:RECORD' + errMsg ;
                        }// for get error
                        
                        //originalCSVRecords[inx].SF_ErrorMessage =  errMsg;
                        
                        
                    } //isSuccess else end here
                    for (MDM_BulkUpload__c  ll: scope) {
                        System.debug('  ll.id   :' + ll.id);
                        System.debug('  locationMasterList[inx].BulkUploadID__c  :' + productMasterList[inx].BulkUploadID__c);
                        System.debug('  dbmsgStr  :' + dbmsgStr);  
                        
                        if(ll.id == productMasterList[inx].BulkUploadID__c){
                            ll.Status_Message__c =  dbmsgStr.left(250);//dbmsgStr ;
                            if(dbmsgStr.contains('Error:RECORD'))
                            {
                                ll.Status__c = 'INVALID RECORD';
                            }
                            ll.IsProcessed__c = true;
                            status=dbmsgStr.contains('Successfully');
                            ll.IdFromSource__c = productMasterList[inx].ID;
                            if(status)
                            {
                                ll.Status__c = 'VALID RECORD';
                            }                                   
                            
                        }
                        
                        
                    }
                    inx= inx + 1;
                }// for end
                Database.SaveResult[] SR1 = Database.update(scope);
                
                //update scope;
            }
            /*else{
//insert  stage 
Database.SaveResult[] srList = Database.insert(locationStageList, false);
integer inx = 0;
string dbmsgStr = '';
for (Database.SaveResult sr: srList) {
if (sr.isSuccess()) {
validrecords = validrecords+ 1;
// Operation was successful, so get the ID of the record that was processed
dbmsgStr  = 'Successfully inserted Location. Location ID:'  + sr.getId();
System.debug('Stage Successfully inserted Location. Location ID: ' + sr.getId());

} else {
invalidrecords = invalidrecords+ 1;
// Operation failed, so get all errors
string errMsg = 'STAGE The following error has occurred.';
for (Database.Error err: sr.getErrors()) {
System.debug('The following error has occur red.');
errMsg = errMsg + err.getStatusCode() + ': ' + err.getMessage();
System.debug(err.getStatusCode() + ': ' + err.getMessage());
System.debug('Account fields that affected this error: ' + err.getFields());
errMsg = errMsg + err.getStatusCode() + 'Fields that affected this error: ' + err.getFields();
dbmsgStr  = 'Error:RECORD' + errMsg ;
}// for get error
} //isSuccess else end here
//originalCSVRecords[inx].SF_ErrorMessage =  errMsg;
System.debug('  ll.id   :');
for (MDM_BulkUpload__c  ll: scope) {
System.debug('  ll.id   :' + ll.id);
System.debug('  locationStageList[inx].BulkUploadID__c  :' + locationStageList[inx].BulkUploadID__c);
System.debug('  dbmsgStr  :' + dbmsgStr);                                

if(ll.id == locationStageList[inx].BulkUploadID__c){
ll.Status_Message__c = dbmsgStr.left(250) ;
ll.IsProcessed__c = true;
if(dbmsgStr.contains('Error:RECORD'))
{
ll.Status__c = 'INVALID RECORD';
}
status=dbmsgStr.contains('Successfully');
ll.IdFromSource__c = locationStageList[inx].IdFromSource__c;
if(status)
{
ll.Status__c = 'VALID RECORD';
}


}

}
inx= inx + 1;

}// for end
//update scope;
Database.SaveResult[] SR2 = Database.update(scope);
}
*/
            //insert scope;
            
        } //try end
        catch (System.DmlException e) {
            System.debug('MDM_Location_ValidateLocationbt Execute : DmlException' + e);
        } catch (Exception e) {
            System.debug('MDM_Location_ValidateLocationbt Execute' + e);
            System.debug('MDM_Location_ValidateLocationbt Execute : Exception' + e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        try
        {
            batchEnddt =  Datetime.now().format('MM/dd/yyyy hh:mm a');
            // Get the ID of the AsyncApexJob representing this batch job
            // from Database.BatchableContext.
            // Query the AsyncApexJob object to retrieve the current job's information.
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
                //String[] toAddresses = new String[] {'murali.pamidi@crossmark.com'};
                //String[] toAddresses = new String[] {'suneetha.paturi@crossmark.com'};
                String Msg1 = 'Your products are validated.\n ';
            string Msg2 = '-------------------------------------------------- .\n ';
            String Msg3 = 'Name of the upload		: 	'+ UploadName +' .\n ';
            String Msg4 = 'Batch Start date time	:  	'+ batchStartdt +' .\n ';
            String Msg5 = 'Batch End date time 		:  	' + batchEnddt +'.\n';
            
            validrows = [SELECT count() FROM MDM_BulkUpload__c  where name = :UploadName];
            invalidrows = [SELECT count() FROM MDM_BulkUpload__c  where name = :UploadName and IsProcessed__c  = true and status_message__C  like '%Invalid row%'];
            invalidrecords =[ SELECT count() FROM MDM_BulkUpload__c  where name = :UploadName and IsProcessed__c  = true and status_message__C  like '%Error%'];
            String Msg6= 'Number of rows in file 	: 	'+ validrows+'.\n';
            String Msg7= 'Invalid rows in file 		: 	'+ invalidrows+'\n';
            String Msg8= '';// 'Valid records : ' + validrecords+'\n';
            String Msg9= 'Invalid records 			:	' + invalidrecords+'\n';
            String Msg10='Mastering Products		: Pending'+'\n';
            
            mail.setToAddresses(toAddresses);
            mail.setSubject('project.Name' + ' schedule locations status - ' + a.Status);
            mail.setPlainTextBody(Msg1+Msg2+Msg3+Msg4+Msg5+Msg6+Msg7+Msg8+Msg9+Msg10 ); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(System.EmailException ex){
            system.debug('============== email exception caught!!!=============');
        }
        
    }
    // get the Delimiter character
    public String getDelimitercharacter()       {
        string retStr = ',';
        MDM_Configuration__C lv = new MDM_Configuration__C();
        lv = [select  Value__c from MDM_Configuration__C where name = 'BatchUploadDelimiter' limit 1];
        retStr = lv.Value__c;
        return retStr;
    }
    
    // Get the reference data
    public Set<String> getOtherIdentifierTypes()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.DomainSpecificIDType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    public Set<String> getStatus()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.Product_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    public Set<String> getWeightUnitofMeasures()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.Weight_Unit_of_Measure__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    public Set<String> getSizeUnitofMeasures()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.Size_Unit_of_Measure__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    
    public Set<String> getDimensionUnitofMeasures()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.Dimension_Unit_of_Measure__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    public Set<String> getPackageUnits()
    {
        
        Set<String> options= new Set<String>();     
        Schema.DescribeFieldResult fieldResult =  MDM_Product__c.Package_Unit__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            
            options.add(f.getLabel().toUpperCase());
        }       
        return options;
    }
    
    
    public List<MDM_Manufacturer__c> getManufacturers()
    {
        
        List<MDM_Manufacturer__c> chl =  new List<MDM_Manufacturer__c>();
        chl = [SELECT Id, Name FROM MDM_Manufacturer__c where Enterpriseid__c like 'MG-%'];     
        
        return chl;
    }
    public List<MDM_Brand__c > getBrands()
    {
        List<MDM_Brand__c > chl =  new List<MDM_Brand__c >();
        chl = [SELECT Id, Name,Manufacturer__c,Manufacturer__R.name FROM MDM_Brand__c where Enterpriseid__c like 'BD-%'  ];     
        return chl;
    }
    public List<MDM_ProductCategory__c > getProductCategory()
    {
        List<MDM_ProductCategory__c > chl =  new List<MDM_ProductCategory__c >();
        chl = [SELECT Id, Name FROM MDM_ProductCategory__c where Enterpriseid__c like 'PC-%'   ];     
        return chl;
    }
    
    public List<MDM_ManufacturerProductCategory__c > getManufacturerProductCategory()
    {
        List<MDM_ManufacturerProductCategory__c > chl =  new List<MDM_ManufacturerProductCategory__c >();
        chl = [SELECT Id, Name,Manufacturer__c,Manufacturer__R.name FROM MDM_ManufacturerProductCategory__c where Enterpriseid__c like 'MC-%'   ];     
        return chl;
    }
    public List<MDM_Product_Group__c > getProductGroups()
    {
        List<MDM_Product_Group__c > chl =  new List<MDM_Product_Group__c >();
        chl = [SELECT Id, Name,Manufacturer__c,Manufacturer__R.name FROM MDM_Product_Group__c where Enterpriseid__c like 'PG-%'   ];     
        return chl;
    }
    
    
    
    
    
}