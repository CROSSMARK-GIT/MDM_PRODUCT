@IsTest
public class MDM_Product_All_Reference_Test {
    @istest
    Static void MDM_Product_All_Reference_Test()
    {
        
        MDM_Configuration__c mdc = new MDM_Configuration__c();
        mdc.name='MDM_IntegrationUser';
        mdc.Value__c = 'Ramakrishnan.Ramadur@crossmark.com.mdmlocuat' ;
        insert mdc;
        
        MDM_Configuration__c mdc0 = new MDM_Configuration__c();
        mdc0.name='DeleteStageRecordsBeforeInsert';
        mdc0.Value__c = 'true' ;
        insert mdc0;
        
        MDM_Configuration__c mdc00 = new MDM_Configuration__c();
        mdc00.name='TemplateName';
        mdc00.Value__c = 'MDM_Location_Bulkupload_Temlate' ;
        insert mdc00;
        
        MDM_Configuration__c mdc1 = new MDM_Configuration__c();
        mdc1.name='BatchUploadHeaderLine';
        mdc1.Value__c = 'Type|Number|Status|Name|Address line 1:|Address line 2:|Address line 3:|City|State|Country|Postal Code|Phone Number|Fax Number|Latitude|Longitude|Owning Company|Chain|Franchiser|TradeChannel|TradeSubchannel|TDLinxNO|IdFromSource' ;
        insert mdc1;
        
        MDM_Configuration__c mdc2 = new MDM_Configuration__c();
        mdc2.name='BatchUploadDelimiter';
        mdc2.Value__c = '|' ;
        insert mdc2;
        
        
        
        MDM_Source__c lsc = new MDM_Source__c();
        lsc.Name = 'SalesForce-Product';
        lsc.SourceCode__c = 'CMKPSF';
        lsc.EnableBulkupload__c=true;
        lsc.Domain__c='MDM_Product';
        insert(lsc);
        
        MDM_Manufacturer__c mfg0 = new MDM_Manufacturer__c();
        mfg0.Name = 'Test Manufacturer0';
        mfg0.EnterpriseID__c = 'MG-01';
        insert(mfg0);
        
        MDM_Manufacturer__c mfg1 = new MDM_Manufacturer__c();
        mfg1.Name = 'Test Manufacturer1';
        mfg1.EnterpriseID__c = 'MG-02';
        insert(mfg1);
        
        MDM_Manufacturer__c mfg3 = new MDM_Manufacturer__c();
        mfg3.Name = 'Test Manufacturer3';
        insert(mfg3);
        mfg3.Name = 'Test Manufacturer3-updated';
        update(mfg3);
        try{
            mfg3.Name = 'Test Manufacturer0'; //try duplicate update
            update(mfg3);    
        }catch(Exception ex){}
        
        
        
        MDM_Brand__C bra0 = new MDM_Brand__C();
        bra0.Name = 'Test Manufacturer0-Bra0';
        bra0.Manufacturer__C = mfg0.id;
        bra0.EnterpriseID__c = 'BD-01';
        insert(bra0);
        
        MDM_Brand__C bra1 = new MDM_Brand__C();
        bra1.Name = 'Test Manufacturer1-Bra1';
        bra1.Manufacturer__C = mfg1.id;
        bra1.EnterpriseID__c = 'BD-02';
        insert(bra1);
        
        MDM_Brand__C bra3 = new MDM_Brand__C();
        bra3.Name = 'Test Manufacturer1-Bra3';
        bra3.Manufacturer__C = mfg1.id;
        
        insert(bra3);
        bra3.Name = 'Test Manufacturer1-Bra3-updated';
        update(bra3);
        try{
            bra3.Name = 'Test Manufacturer1-Bra1';
            update(bra3);
        }catch(Exception ex){}
        
        
        MDM_Product_Group__c pg0= new MDM_Product_Group__c();
        pg0.Name = 'Test Manufacturer1- PRGRP 0';
        pg0.Manufacturer__C = mfg1.id;
        pg0.EnterpriseID__c = 'PG-01';
        insert(pg0);
        
        
        MDM_Product_Group__c pg1= new MDM_Product_Group__c();
        pg1.Name = 'Test Manufacturer1- PRGRP 1';
        pg1.Manufacturer__C = mfg1.id;
        pg1.EnterpriseID__c = 'PG-02';
        insert(pg1);
        
        MDM_Product_Group__c pg3= new MDM_Product_Group__c();
        pg3.Name = 'Test Manufacturer1- PRGRP3';
        pg3.Manufacturer__C = mfg1.id;
        insert(pg3);
        pg3.Name = 'Test Manufacturer1- PRGRP3-updated';
        update(pg3);
        try{
            pg3.Name = 'Test Manufacturer1- PRGRP 1';
            update(pg3); 
        }catch(Exception ex){}
        
        
        
        MDM_ProductCategory__c pc1= new MDM_ProductCategory__c();
        pc1.Name = 'ProductCategory 1';
        pc1.CategoryFamilyName__c = 'ProductCategory - Family1';
        pc1.EnterpriseID__c = 'PC-01';
        insert(pc1);
        
        MDM_ProductCategory__c pc2= new MDM_ProductCategory__c();
        pc2.Name = 'ProductCategory 2';
        pc2.CategoryFamilyName__c = 'ProductCategory - Family2';
        insert(pc2);
        
        pc2.Name = 'ProductCategory 2- updated';
        update(pc2);
        try{
            pc2.Name = 'ProductCategory 1';
            update(pc2);
        }catch(Exception ex){}
        
        
        
        MDM_ManufacturerProductCategory__c mpc0= new MDM_ManufacturerProductCategory__c();
        mpc0.Name = 'Test Manufacturer ProductCategory  MPC1 ';
        mpc0.Manufacturer__C = mfg1.id;
        mpc0.EnterpriseID__c = 'MC-01';
        insert(mpc0);
        
        
        MDM_ManufacturerProductCategory__c mpc1= new MDM_ManufacturerProductCategory__c();
        mpc1.Name = 'Test Manufacturer ProductCategory  MPC2';
        mpc1.Manufacturer__C = mfg1.id;
        mpc1.EnterpriseID__c = 'MC-02';
        insert(mpc1);
        
        MDM_ManufacturerProductCategory__c mpc3= new MDM_ManufacturerProductCategory__c();
        mpc3.Name = 'Test Manufacturer ProductCategory  MPC3';
        mpc3.Manufacturer__C = mfg1.id;
        insert(mpc3);
        mpc3.Name = 'Test Manufacturer ProductCategory  MPC3 - updated';
        update(mpc3);
        try{
            mpc3.Name = 'Test Manufacturer ProductCategory  MPC1';
            update(mpc3);
        }catch(Exception ex){}
        
        
        MDM_Product_Country__c c0 = new MDM_Product_Country__c();
        c0.Name='UNITED STATES';
        c0.EnterpriseID__c= 'CN-0001';
        insert(c0);
        MDM_Product_Country__c c1 = new MDM_Product_Country__c();
        c1.Name='CANADA';
        c1.EnterpriseID__c= 'CN-002';
        insert(c1);
        
        
        try{
            c0.Name='CANADA -1 ';
            update(c0);
        }catch(Exception ex){}
        
        
        MDM_Product__c  p0	= new MDM_Product__c();
        p0.name= 'Test Product1';
        p0.Manufacturer__c = mfg0.id;
        p0.Brand__c = bra0.id;
        p0.Product_Status__c = 'Active';
        p0.Short_Description__c = 'Test Product1';
        p0.Description__c='Test Product1';
        p0.UPC12__c = '233333324233';
        p0.Is_Shipping_Product__c = true;
        
        insert p0;
        p0.name= 'Test Product1-updated';
        update p0;
        try{
        p0.UPC12__c = '23333924233';
        }catch(Exception ex){}
        
        
        delete(mpc3);
        delete(pc2);
        delete(pg3);
        delete(bra3);
        delete(mfg3);
   
        
        
        Test.startTest();
        
        
        
        Test.stopTest();  
    }
}