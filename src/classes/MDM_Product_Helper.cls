public with sharing class MDM_Product_Helper {
    Public List<String> ret;
    Public MDM_Product_Stage__c lretProduct;
    Public MDM_Product_Stage__c lretProduct_Stage;
    public MDM_Product__c lstProduct;
    Public MDM_Product_Stage__c lProduct_Stage;
    
    public List<String> IsValidProduct(MDM_Product__c pProduct)
    {
        /*
* this method will return String list :  
* Element [0] = Flag :: TRUE :IS valid  / False ID Invalid Product".
* Element [1] = Type :: Error / Warning.  
* Element [2] = Type :: Error / Warning  Message.
* */
        String errMsg= ''; //'Duplicate product already exist.';
        String warMsg= ''; //'Duplicate product already exist.';
        lstProduct = new MDM_Product__c();
        lstProduct=pProduct;
        List<String> ret  = new List<String>();
        String ISvalid = 'False';
        String msg = 'Error / Eexception :'; 
        /*Alll vlaidation starts here */
        try
        {
            /*----------Start Validation-----------*/
            //ALL upsert
            //required fields             //Manufacturer is a required field            //Brand is a required field            //Product status is a required field
            if(lstProduct.Manufacturer__c == null || lstProduct.Brand__c == null || lstProduct.Product_Status__c == null || lstProduct.Name == Null)    
            {
                errMsg+= 'Please enter all required fields [Name,Manufacturer,Brand,Status]';
            }
            //At least one of the following identifiers needs to have a value (UPC-12, EAN-8, EAN-13, EAN-14, GTIN, Domain-specific ID)
            if((lstProduct.UPC12__c == null || lstProduct.UPC12__c == '' ) && 
               (lstProduct.EAN13__c == null || lstProduct.EAN13__c == '') && 
               (lstProduct.EAN14__c == null || lstProduct.EAN14__c == '') && 
               (lstProduct.EAN8__c  == null || lstProduct.EAN8__c  == '') &&
               (lstProduct.GTIN__c == null  || lstProduct.GTIN__c ==  '') && 
               (lstProduct.DomainSpecificID__c == '' || lstProduct.DomainSpecificID__c == null))
            {
                errMsg+= 'One of the following identifiers needs to have a value (UPC-12, EAN-8, EAN-13, EAN-14, GTIN, Domain-specific ID)'; 
            }
            // all UPC should be numeric only.
            //if( (lstProduct.UPC12__c != null && (!lstProduct.UPC12__c.isNumeric()) )   || (lstProduct.EAN13__c ! = null && (!lstProduct.EAN13__c.isNumeric()) )||
            //    (lstProduct.EAN14__c ! = null && !lstProduct.EAN14__c.isNumeric())  || (lstProduct.EAN8__c != null  && !lstProduct.EAN8__c.isNumeric() )
            //   )
            if( (lstProduct.UPC12__c != null &&  !lstProduct.UPC12__c.isNumeric()   ) ||
                (lstProduct.EAN8__c != null &&  !lstProduct.EAN8__c.isNumeric()   ) ||
                 (lstProduct.EAN14__c != null &&  !lstProduct.EAN14__c.isNumeric()  ) ||
                 (lstProduct.EAN13__c != null &&  !lstProduct.EAN13__c.isNumeric()  ) 
                )
            {
                System.debug('lstProduct.UPC12__c ' + lstProduct.UPC12__c );
                System.debug('lstProduct.EAN13__c ' + lstProduct.EAN13__c );
                System.debug('lstProduct.EAN14__c ' + lstProduct.EAN14__c );
                System.debug('lstProduct.EAN8__c ' + lstProduct.EAN8__c );
                errMsg+= 'One of the following identifiers have a invalid character  (UPC-12, EAN-8, EAN-13, EAN-14)';  
                
            }
            
            
            //errMsg+=   lstProduct.UPC12__c +'&&' + lstProduct.EAN13__c + '  && ' +  lstProduct.EAN14__c   ;
            //errMsg+=      '&&' + lstProduct.EAN8__c+ '   &&' + lstProduct.GTIN__c +' &&' + lstProduct.DomainSpecificID__c ;
            //The product must have a name value
            if(lstProduct.Name =='')
            {
                errMsg+= 'The product must have a name';
            }
            
            //If a Domain-specific ID is entered, the user must enter the domain type
            System.debug('lstProduct.DomainSpecificID__c :' + lstProduct.DomainSpecificID__c);
            System.debug('lstProduct.DomainSpecificIDType__c :' + lstProduct.DomainSpecificIDType__c);
            if(lstProduct.DomainSpecificID__c <> '' && lstProduct.DomainSpecificID__c <> null && lstProduct.DomainSpecificIDType__c == null)
            {
                errMsg+= 'A Domain-specific ID is entered. Select a domain type'; 
            }
            //If a UPC-12 value is entered, it must be 12-digits and have a valid check digit
            boolean Validupc12 = false;
            integer checkdigit =0; 
            // upc12 checkdigit validation.
            
            if(lstProduct.UPC12__c <> null && lstProduct.UPC12__c.length() == 12 && lstProduct.UPC12__c.isNumeric())
            {
                
                Integer [] digits=new Integer[]{0,0,0,0,0,0,0,0,0,0,0,0};
                    for (Integer i = 0; i < lstProduct.UPC12__c.length(); i++) {
                        digits[i] = integer.valueof(lstProduct.UPC12__c.substring(i,i+1));
                    }
                integer evens = integer.valueof(digits[1]) + integer.valueof(digits[3]) + integer.valueof(digits[5]) + integer.valueof(digits[7]) + integer.valueof(digits[9]);
                integer odds  = integer.valueof(digits[0]) + integer.valueof(digits[2]) + integer.valueof(digits[4]) + integer.valueof(digits[6]) + integer.valueof(digits[8]) + integer.valueof(digits[10]);
                System.debug('evens' + evens);
                System.debug('odds' + odds);
                odds = odds * 3 ;
                integer tot = odds + evens;
                Integer remainder =  math.mod(tot, 10); 
                checkdigit =  (10 - remainder == 10) ? 0 : 10 - remainder ;
                
                if(checkdigit == integer.valueof(digits[11]))
                {
                    Validupc12 = true;
                }
                else
                {
                    errMsg+= 'Invalid UPC-12 [Checkdigit present : ';
                    errMsg+= String.valueOf(digits[11])  ;
                    errMsg+= 'correct Checkdigit : ' + checkdigit;
                }
                
                System.debug('tot' + tot);
                System.debug('odds' + odds);
                System.debug('remainder' + math.mod(tot, 10));
                System.debug('checkdigit' + checkdigit);
                
            }
            else
            {
                // errMsg+= 'Invalid UPC-12 [size / Checkdigit]';
            }
            //up is not required any more
            /*if(!Validupc12)
            {
                errMsg+= 'Invalid UPC-12';
            }*/
            
            //If a height, width, or depth dimension are entered, there must be a dimension unit of measure selected
            if(lstProduct.Package_Height__c <> 0 || lstProduct.Package_Width__c <> 0 || lstProduct.Package_Depth__c <> 0)
            {
                if(lstProduct.Dimension_Unit_of_Measure__c == '')  
                {
                    errMsg+= 'A Height / Width / Depth  is entered. Select a Dimension unit of measure '; 
                }
            }
            
            //If a weight value is entered, a weight unit of measure must be selected
            if(lstProduct.Package_Weight__c <> 0 && lstProduct.Weight_Unit_of_Measure__c == '')
            {
                errMsg+= 'A weight is entered. Select a weight unit of measure'; 
            }
            
            // If planning product is selected.   
            //If the Planning Product check box is selected, the Manufacturer should have Default CPG Toolbox Business Unit value (to make CPG Toolbox complete)
             String BUID ='';
            List<MDM_Manufacturer__c>  rlist0 = new List<MDM_Manufacturer__c>();
            rlist0 =   [SELECT Id ,name , TPM_DefaultBusinessUnit__c FROM MDM_Manufacturer__c where  id =: lstProduct.Manufacturer__c    limit 1];
            if(rlist0.size() > 0 )
                {
                      BUID = rlist0[0].TPM_DefaultBusinessUnit__c;
                }
            if(lstProduct.Is_Planning_Product__c &&  BUID == null)
            {
                errMsg+=lstProduct.Manufacturer__r.TPM_DefaultBusinessUnit__c +'If the Planning Product check box is selected, the Manufacturer should have Default CPG Toolbox Business Unit value (to make CPG Toolbox complete)';
                
            }
            System.debug('lstProduct.IgnoreWarnings__c : ' + lstProduct.IgnoreWarnings__c);
            
            // UPC 12 duplicate allowed with in manufacturer 
              List<MDM_Product__c> plst0=[SELECT Name, UPC12__c,EAN13__c,EAN14__c,EAN8__c,GTIN__c, Id  FROM MDM_Product__c 
                                            WHERE (Manufacturer__c =: lstProduct.Manufacturer__c and id <>: lstProduct.id )
                                            AND( (UPC12__c =: lstProduct.UPC12__c AND UPC12__c != null )
                                               )];
                
                if(plst0.size() > 0)
                {
                    
                    errMsg+=plst0[0].UPC12__c +'Duplicate UPC_12 Allowed within the manufacturer';
                    
                }
            
            
            //Warning not accepted
            if(!lstProduct.IgnoreWarnings__c)
            {
                
                //At least one of the Domain/Usage check boxes should be checked    
                if(!lstProduct.Is_Consumer_Product__c && !lstProduct.Is_Planning_Product__c && !lstProduct.Is_Orderable_Product__c 
                   && !lstProduct.Is_Shipping_Product__c && !lstProduct.Is_Invoicable_Product__c)
                {
                    warMsg+='At least one of the Domain/Usage check boxes should be checked';
                }
                //If the Planning Product check box is selected, the user should enter a Cost of Good sold value (to make CPG Toolbox complete)
                if(lstProduct.Is_Planning_Product__c &&  lstProduct.Cost_of_Goods_Sold__c == 0.0)
                {
                    warMsg+='If the Planning Product check box is selected, the user should enter a Cost of Good sold value (to make CPG Toolbox complete)';
                    
                }
                
                //We should warn if the same Manufacturer Product identifier is used for a given manufacturer
                System.debug('lstProduct.Manufacturer__c: ' + lstProduct.Manufacturer__c);
                System.debug('lstProduct.ManufacturerID__c: ' + lstProduct.ManufacturerID__c);
                List<MDM_Product__c> plst=[SELECT Name,  Id  FROM MDM_Product__c where Manufacturer__c =: lstProduct.Manufacturer__c
                                           and ManufacturerID__c=:lstProduct.ManufacturerID__c  and id <>: lstProduct.id and ManufacturerID__c != NULL];
                if(plst.size() > 0)
                {
                    String pname ='';
                    for(MDM_Product__c p:plst)
                    {
                        pname+= p.name +' :  \b \n';
                    }
                    warMsg+='Manufacturer Product identifier is already in Products' +pname;
                    
                }
                
                //We should warn if a product with the same industry ID is entered as a new product(UPC-12, EAN-8, EAN-13, EAN-14, GTIN)
                List<MDM_Product__c> plst1=[SELECT Name, UPC12__c,EAN13__c,EAN14__c,EAN8__c,GTIN__c, Id  FROM MDM_Product__c 
                                            WHERE (Manufacturer__c =: lstProduct.Manufacturer__c and id <>: lstProduct.id )
                                            AND(// (UPC12__c =: lstProduct.UPC12__c AND UPC12__c != null ) OR
                                                 (EAN13__c =:lstProduct.EAN13__c AND EAN13__c != null )
                                                OR (EAN14__c =:lstProduct.EAN14__c AND EAN14__c != null )
                                                OR (EAN8__c =:lstProduct.EAN8__c AND EAN8__c != null )
                                                OR (GTIN__c =:lstProduct.GTIN__c AND  GTIN__c != null)
                                               )];
                
                if(plst1.size() > 0)
                {
                    String pname ='';
                    for(MDM_Product__c p:plst1)
                    {
                        String matchedIds='';
                        //if(p.UPC12__c == lstProduct.UPC12__c )
                        //{
                        //   matchedIds += 'UPC12 '+ p.UPC12__c ;
                        //}
                        if(p.EAN13__c == lstProduct.EAN13__c )
                        {
                            matchedIds += 'EAN13  '+ p.EAN13__c ;
                        }
                        if(p.EAN14__c == lstProduct.EAN14__c )
                        {
                            matchedIds += 'EAN14  '+ p.EAN14__c ;
                        }
                        if(p.EAN8__c == lstProduct.EAN8__c )
                        {
                            matchedIds += 'EAN8  '+ p.EAN8__c ;
                        }
                        if(p.GTIN__c == lstProduct.GTIN__c )
                        {
                            matchedIds += 'GTIN  '+ p.GTIN__c ;
                        }
                        pname+= p.name +' :  '+ matchedIds;
                    }
                    warMsg+='Identifier[UPC12/EAN8/EAN13/EAN14/GTIN] is already used by other Products for the same manufacturer' +pname;
                    
                }
                
                
                
                
                
                //If Consumer Product is selected and any of the remaining, the user should probably provide a case UPC and a CasePack
                if(lstProduct.Is_Consumer_Product__c && lstProduct.Case_Pack__c == null && lstProduct.Case_UPC__c == null )
                {
                    warMsg+='Consumer Product is selected, Provide a case UPC and a CasePack';
                    
                }
                //errMsg+=    warMsg;
                //errMsg+=  '<a href=\'/'+ warMsg +'\'> '+ warMsg + '</a>';
                //'<a style="text-decoration: none;" href="/'+warMsg+'">Name</a>';
                
            }
            
            
            
            /*----------End   Validation ----------*/
            /*
//Check the Name contain Good
if(lstProduct.Name.indexOf('Good') == -1)
{
ISvalid = 'false' ;
errMsg = 'A Valid Product';
}

*/
            
            
        }
        Catch(Exception Ex)
        {
            errMsg += ex.getMessage();
        }
        
        /*Alll vlaidation End here */
        ret.add(ISvalid);
        //ret.add(msg);
        if(errMsg <> '')
        {
            ret.add('Error:: ');
            ret.add('Error: ' + errMsg );
        }
        else if(warMsg <> '')
        {
            ret.add('Warning:: ');
            ret.add('Warning: ' + warMsg + 'To Ignore the warning and proceed, Accept Ignore Warnings.' );
        }
        return ret;
        
    }
    Public static  MDM_Product_Stage__c convertProduct_TO_ProductStage(MDM_Product__c pProduct)
    {
        MDM_Product_Stage__c oProduct_stage = new MDM_Product_Stage__c();
        // Identifiers
        oProduct_stage.Name = pProduct.Name;
        oProduct_stage.UPC12__c    = pProduct.UPC12__c;
        oProduct_stage.EAN13__c    = pProduct.EAN13__c;
        oProduct_stage.EAN14__c    = pProduct.EAN14__c;
        oProduct_stage.EAN8__c     = pProduct.EAN8__c;
        oProduct_stage.GTIN__c     = pProduct.GTIN__c;
        oProduct_stage.DomainSpecificID__c = pProduct.DomainSpecificID__c;
        if(pProduct.DomainSpecificIDType__c != null)
        {
            oProduct_stage.DomainSpecificIDType__c =pProduct.DomainSpecificIDType__c;            
        }
        oProduct_stage.ManufacturerID__c   = pProduct.ManufacturerID__c;
        oProduct_stage.Comments__c   = pProduct.Comments__c;
        User u =  pProduct.createdBy;
        //String name = (String) u.get('ID');
        oProduct_stage.CustomizedOriginalCreatedUser__c   = String.valueOf(pProduct.createdBy);// pProduct.createdBy.Name;
        oProduct_stage.ManufacturerDescription__c   = pProduct.ManufacturerDescription__c;
        oProduct_stage.Product_Country__c   = pProduct.Product_Country__c;
        //oProduct_stage.Country_of_Origin__c  = pProduct.Country_of_Origin__c;
        
        
        //Information
        oProduct_stage.Description__c  = pProduct.Description__c;
        oProduct_stage.Short_Description__c    = pProduct.Short_Description__c;
        if(pProduct.Manufacturer__c != null)
        {
            oProduct_stage.Manufacturer__c     = pProduct.Manufacturer__c;
        }
        if(pProduct.Category__c != null)
        {
            oProduct_stage.Category__c     = pProduct.Category__c;
        }
        if(pProduct.Category__c != null)
        {
            oProduct_stage.ManufacturerCategory__c = pProduct.ManufacturerCategory__c;
        }
        if(pProduct.Product_Group__c != null)
        {
            oProduct_stage.Product_Group__c    = pProduct.Product_Group__c;
        }
        oProduct_stage.EnterpriseID__c     = pProduct.EnterpriseID__c;
        if(pProduct.Brand__c != null)
        {
            oProduct_stage.Brand__c    = pProduct.Brand__c;
        }
        
        //Additional detail
        oProduct_stage.Case_Pack__c    = pProduct.Case_Pack__c;
        oProduct_stage.Case_UPC__c     = pProduct.Case_UPC__c;
        oProduct_stage.Size__c     = pProduct.Size__c;
        oProduct_stage.Package_Unit__c     = pProduct.Package_Unit__c;
        oProduct_stage.Size_Unit_of_Measure__c     = pProduct.Size_Unit_of_Measure__c;
        if(pProduct.Product_Status__c != null)
        {
            oProduct_stage.Product_Status__c = pProduct.Product_Status__c;
        }
        //oProduct_stage.ValidationStatus__c   = pProduct.ValidationStatus__c;
        oProduct_stage.End_Availability_Date__c    = pProduct.End_Availability_Date__c;
        oProduct_stage.Start_Availability_Date__c  = pProduct.Start_Availability_Date__c;  
        
        //Domain / Usage
        oProduct_stage.Is_Consumer_Product__c  = pProduct.Is_Consumer_Product__c;
        oProduct_stage.Is_Planning_Product__c  = pProduct.Is_Planning_Product__c;
        oProduct_stage.Is_Orderable_Product__c     = pProduct.Is_Orderable_Product__c;
        oProduct_stage.Is_Shipping_Product__c  = pProduct.Is_Shipping_Product__c;
        oProduct_stage.Is_Invoicable_Product__c    = pProduct.Is_Invoicable_Product__c;
        
        //Pricing        
        oProduct_stage.Cost_of_Goods_Sold__c   = pProduct.Cost_of_Goods_Sold__c;
        oProduct_stage.Default_Unit_Delivered_Cost__c  = pProduct.Default_Unit_Delivered_Cost__c;
        oProduct_stage.Default_Unit_Price__c   = pProduct.Default_Unit_Price__c;
        
        //dimensions
        
        
        oProduct_stage.Package_Depth__c    = pProduct.Package_Depth__c;
        oProduct_stage.Package_Height__c   = pProduct.Package_Height__c;
        oProduct_stage.Package_Weight__c   = pProduct.Package_Weight__c;
        oProduct_stage.Package_Width__c    = pProduct.Package_Width__c;
        oProduct_stage.Weight_Unit_of_Measure__c   = pProduct.Weight_Unit_of_Measure__c;
        oProduct_stage.Dimension_Unit_of_Measure__c    = pProduct.Dimension_Unit_of_Measure__c;
        oProduct_stage.IdFromSource__c = pProduct.id;
        oProduct_stage.IgnoreWarnings__c   = pProduct.IgnoreWarnings__c;
        
        return oProduct_stage;
        
    }
    Public MDM_Product__c convertProductStage_TO_Product(MDM_Product_Stage__c pProduct_Stage)
    {
        MDM_Product__c oProduct = new MDM_Product__c();
        
        // Identifiers
        oProduct.Name = pProduct_stage.Name;
        oProduct.UPC12__c    = pProduct_stage.UPC12__c;
        oProduct.EAN13__c    = pProduct_stage.EAN13__c;
        oProduct.EAN14__c    = pProduct_stage.EAN14__c;
        oProduct.EAN8__c     = pProduct_stage.EAN8__c;
        oProduct.GTIN__c     = pProduct_stage.GTIN__c;
        oProduct.DomainSpecificID__c = pProduct_stage.DomainSpecificID__c;
        if(pProduct_stage.DomainSpecificIDType__c != null)
        {
            oProduct.DomainSpecificIDType__c =pProduct_stage.DomainSpecificIDType__c;            
        }
        oProduct.ManufacturerID__c   = pProduct_stage.ManufacturerID__c;
        oProduct.Product_Country__c   = pProduct_stage.Product_Country__c;
        oProduct.Product_Country__c   = pProduct_stage.Product_Country__c;
        
        //oProduct.Country_of_Origin__c  = pProduct_stage.Country_of_Origin__c;
        
        
        //Information
        oProduct.Description__c  = pProduct_stage.Description__c;
        oProduct.Short_Description__c    = pProduct_stage.Short_Description__c;
        if(pProduct_stage.Manufacturer__c != null)
        {
            oProduct.Manufacturer__c     = pProduct_stage.Manufacturer__c;
        }
        if(pProduct_stage.Category__c != null)
        {
            oProduct.Category__c     = pProduct_stage.Category__c;
        }
        if(pProduct_stage.Category__c != null)
        {
            oProduct.ManufacturerCategory__c = pProduct_stage.ManufacturerCategory__c;
        }
        if(pProduct_stage.Product_Group__c != null)
        {
            oProduct.Product_Group__c    = pProduct_stage.Product_Group__c;
        }
        oProduct.EnterpriseID__c     = pProduct_stage.EnterpriseID__c;
        if(pProduct_stage.Brand__c != null)
        {
            oProduct.Brand__c    = pProduct_stage.Brand__c;
        }
        
        //Additional detail
        oProduct.Case_Pack__c    = pProduct_stage.Case_Pack__c;
        oProduct.Case_UPC__c     = pProduct_stage.Case_UPC__c;
        oProduct.Size__c     = pProduct_stage.Size__c;
        oProduct.Package_Unit__c     = pProduct_stage.Package_Unit__c;
        oProduct.Size_Unit_of_Measure__c     = pProduct_stage.Size_Unit_of_Measure__c;
        if(pProduct_stage.Product_Status__c != null)
        {
            oProduct.Product_Status__c = pProduct_stage.Product_Status__c;
        }
        //oProduct.ValidationStatus__c   = pProduct_stage.ValidationStatus__c;
        oProduct.End_Availability_Date__c    = pProduct_stage.End_Availability_Date__c;
        oProduct.Start_Availability_Date__c  = pProduct_stage.Start_Availability_Date__c;  
        
        //Domain / Usage
        oProduct.Is_Consumer_Product__c  = pProduct_stage.Is_Consumer_Product__c;
        oProduct.Is_Planning_Product__c  = pProduct_stage.Is_Planning_Product__c;
        oProduct.Is_Orderable_Product__c     = pProduct_stage.Is_Orderable_Product__c;
        oProduct.Is_Shipping_Product__c  = pProduct_stage.Is_Shipping_Product__c;
        oProduct.Is_Invoicable_Product__c    = pProduct_stage.Is_Invoicable_Product__c;
        
        //Pricing        
        oProduct.Cost_of_Goods_Sold__c   = pProduct_stage.Cost_of_Goods_Sold__c;
        oProduct.Default_Unit_Delivered_Cost__c  = pProduct_stage.Default_Unit_Delivered_Cost__c;
        oProduct.Default_Unit_Price__c   = pProduct_stage.Default_Unit_Price__c;
        
        //dimentions
        
        
        oProduct.Package_Depth__c    = pProduct_stage.Package_Depth__c;
        oProduct.Package_Height__c   = pProduct_stage.Package_Height__c;
        oProduct.Package_Weight__c   = pProduct_stage.Package_Weight__c;
        oProduct.Package_Width__c    = pProduct_stage.Package_Width__c;
        oProduct.Weight_Unit_of_Measure__c   = pProduct_stage.Weight_Unit_of_Measure__c;
        oProduct.Dimension_Unit_of_Measure__c    = pProduct_stage.Dimension_Unit_of_Measure__c;
        
        oProduct.IgnoreWarnings__c   = pProduct_stage.IgnoreWarnings__c;
        return oProduct;
        
    }
    
    Public String IdValidUPloadRecord()
    {
        String RetMsg= '';
        {
            
        }
        return RetMsg;
    }
    
    public static void sleep(integer milliseconds) 
    {
              Long timeDiff = 0;
            DateTime firstTime = System.now();
            do
            {
                timeDiff = System.now().getTime() - firstTime.getTime();
            }
            while(timeDiff <= milliseconds);      
    }
    
}