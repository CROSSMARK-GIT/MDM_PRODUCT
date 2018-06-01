public with sharing class MDM_Location_BulkUploadProductExt {
    //get the upload temlate id from document 
    public string DocID{
        public get
        {
            string errMsg ='Error: ';
            string retStr = '';
            
            try
            {
                retStr =  [select id from document where developername=:TemplateName limit 1].id;
            }
            catch (System.DmlException e) {
                System.debug('DocID ERROR:' + e);
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
                ApexPages.addMessage(errorMessage);
            } catch (Exception e) {
                System.debug('DocID ERROR:' + e);
                errMsg = 'Upload template Document is missing in MDM_Configuration__C where name =  TemplateName' + e.getMessage();
                ApexPages.Message errorMessage1 =   new ApexPages.Message(ApexPages.severity.ERROR,errMsg);
                ApexPages.addMessage(errorMessage1);
            }
            return retStr;
        }
        private set;
    }
    public string EnrichLocation {
        public get
        {
            string errMsg ='Error: ';
            boolean enrichLocation = true;
            string retStr = 'TRUE';
            MDM_Configuration__C lv = new MDM_Configuration__C();
            try
            {
                lv = [select  Value__c from MDM_Configuration__C where name = 'EnrichLocation' limit 1];
                if(lv.Value__c.toUpperCase() == 'FALSE')
                {
                    retStr = lv.Value__c;
                }
            }
            catch (System.DmlException e) {
                System.debug('EnrichLocation ERROR:' + e);
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
                ApexPages.addMessage(errorMessage);
            }  
            return retStr;
            
        }
        public set;
    }

    // to get list of location Source from location_source__c   
    
    public SelectOption[] LocationSource{  
        public get
        {
            String errMsg = 'Error : ';
            SelectOption[] locationSource;
            try
            {
                //List<MDM_Source__c> LocationSourcelist =[select  id,name from MDM_Source__c where name != 'SalesTrak'];
                List<MDM_Source__c> LocationSourcelist =[select  id, name from MDM_Source__c  WHERE enableBulkupload__C = true and name like 'Product%'];
                
                locationSource = new SelectOption[]{};
                    locationSource.add(new SelectOption('Select One','-- Select One --'));
                
                for (MDM_Source__c c: LocationSourcelist ) {
                    locationSource.add(new SelectOption(c.id,c.name));
                }
            }
            catch (Exception e) {
                System.debug('LocationSource ERROR:' + e);
                errMsg = 'MDM_Source__c no records ' + e.getMessage();
                ApexPages.Message errorMessage =   new ApexPages.Message(ApexPages.severity.ERROR,errMsg);
                ApexPages.addMessage(errorMessage);
            }
            
            return locationSource;
        } 
        public set;
    }
    
    Public boolean IsDebug{
        public get{
            return false;
        }
        public set;
    }
    
    public integer NumberofSelectedUPloadrows
    {
        public get;
        public set;
    }
    public string Debugtext
    {
        public get;
        public set;
    }
    
    // get the header row from config
    public string HeaderRow
    {
        public get
        {
            // get the Delimiter character
            String errMsg = 'Error : ';
            string retStr = ',';
            MDM_Configuration__C lv = new MDM_Configuration__C();
            
            try
            {
                lv = [select  Value__c from MDM_Configuration__C where name = 'BatchUploadHeaderLine' limit 1];
            }
            catch (System.DmlException e) {
                System.debug('HeaderRow ERROR:' + e);
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
                ApexPages.addMessage(errorMessage);
            } catch (Exception e) {
                System.debug('HeaderRow ERROR:' + e);
                errMsg = 'HeaderRow is missing MDM_Configuration__C where name =  BatchUploadHeaderLine' + e.getMessage();
                ApexPages.Message errorMessage1 =   new ApexPages.Message(ApexPages.severity.ERROR,errMsg);
                ApexPages.addMessage(errorMessage1);
            }
            
            retStr = lv.Value__c;
            return retStr;
            
            //return 'Location Type,Location Number,Location Status,Location Name,Address line 1:,Address line 2:,Address line 3:,City,State,Country,Postal Code,Phone Number,Latitude,Longitude,Owning Company,Chain,TradeChannel,TradeSubchannel,IdFromSource';
        }
        private set;
    }
    public string TemplateName
    {
        public get
        {
            // get the Delimiter character
            string errMsg ='Error:';
            string retStr = 'MDM_Location_Bulkupload_Temlate';
            MDM_Configuration__C lv = new MDM_Configuration__C();
            try
            {
                lv = [select  Value__c from MDM_Configuration__C where name = 'TemplateName' limit 1];
            }
            catch (System.DmlException e) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
                ApexPages.addMessage(errorMessage);
            } catch (Exception e) {
                errMsg = 'Upload template Document is missing in MDM_Configuration__C where name =  TemplateName' + e.getMessage();
                ApexPages.Message errorMessage1 =   new ApexPages.Message(ApexPages.severity.ERROR,errMsg);
                ApexPages.addMessage(errorMessage1);
            }
            
            retStr = lv.Value__c;
            return retStr;
            //return MDM_Location_Bulkupload_Temlate
            
        }
        private set;
    }
    public string LocationSourceValue{
        get;
        set;
    }  
    public integer inx {
        get;
        set;
    }
    
    public Transient Blob csvFileBody {
        get;
        set;
    }
    public Transient string csvAsString {
        get;
        set;
    }
    public string csvFilenameString {
        get;
        set;
    }        
    public string locationListName{
        get;
        set;
    }        
    
    
    public Transient String[] csvFileLines {
        get;
        set;
    }
    public Transient string[] csvRecordData {
        get;
        set;
    }
    public string UploadStatusMsg{
        public get {
            string str = 'Thanks for uploading the locations. <br>';
            str += 'Your Locations file loaded successfully. It will be validated and processed.<br>';
            str += 'Step 1. Upload the locations file. [Completed].<br>';
            str += 'Step 2. Validate and process records. [Started].<br>';
            str += 'Step 3. Mastering the locations.[Pending]. <br>';             
            str += '<br>';
            str += 'You will be notified on each step of the process.';
            return str;
        }
        private set;
    }
    
    
    
    
    // custom local object to get the rows from file
    
    public void insertHelper(list<MDM_Bulkupload__c> slist, string filename){
        
        MDM_Location_BulkUploadProductExtbt slb= new MDM_Location_BulkUploadProductExtbt (slist,filename);
        Database.executeBatch(slb,200);
    }
    
    public List<String> safeSplit(String inStr, String delim)
    {
        Integer regexFindLimit = 1000;
        Integer regexFindCount = 0;
        List<String> output = new List<String>();
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if(m.find())
                {
                    output.add(inStr.substring(lastEnd, m.start())); 
                    lastEnd = m.end();
                }
                else
                {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }
            m.reset(inStr);       
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return output;
        
    }
    
    
    
    public MDM_Location_BulkUploadProductExt(ApexPages.StandardController controller) {
        
        csvFileLines = new String[] {};
            
            }
    
    public void importCSVFile() {
        string filename = '';
        boolean IsValidRecord = true;
        string errmessage = '';
        SelectOption[]  LocationSourceNamVal= LocationSource;
        string locationSource = '';
        locationSource = LocationSourceValue;
        
        
        try {
            
            
            csvAsString = csvFileBody.toString();
            String formattedDt = DateTime.now().format('yyyy/MM/dd - HH:mm:ss') ;
            //filename = filename+':'+ formattedDt+' : '+ formattedDt ;
            if(csvFilenameString.length() > 29)
            {
                string fext=  csvFilenameString.right(5);
                string fname= csvFilenameString.left(20);
                fname = fname + '...'+fext;
                csvFilenameString= fname;
            }
            filename = locationListName + '  |  ' + csvFilenameString + ' | ' + formattedDt ;
            
            //csvFileLines = csvAsString.split('\n');
            List < String > result = new List < String > ();
            //myset.addAll(csvFileLines);
            
            NumberofSelectedUPloadrows = csvAsString.countMatches('\n');
            //result = safeSplit(csvAsString,'\n')
            result = safeSplit(csvAsString,'\r\n');
            //result.addAll(csvFileLines);
            
            
            system.debug('rama csvFileLines.size()');
            system.debug(csvFileBody.size());
            //String Projid = ApexPages.currentPage().getParameters().get('projectid');
            //NumberofSelectedUPloadrows = result.size();
            
            // Validate the source selection
            if(locationSource.trim() == 'Select One')
            {
                system.debug('Invaild Location Source');
                IsValidRecord = false;
                errmessage = errmessage + 'Invaild Location Source: Please select a [correct] Location source';
            }
            // start for every line in the file
            List<MDM_Bulkupload__c>  llist = new  List<MDM_Bulkupload__c>();
            Debugtext = result[0].trim();
            if(!HeaderRow.equals(result[0].trim()))
            {
                system.debug('HeaderRow'+HeaderRow);
                system.debug('result[0]'+ result[0]);                
                IsValidRecord = false;
                errmessage = errmessage + 'Invaild file format: Incorrect header row. Check Upper/Lower case, Space and Delimiter in header row.';
            }
            if(IsValidRecord)
            {
                for (Integer i = 1; i < result.size()-1; i++)
                {
                    MDM_Bulkupload__c locBulkUploadLocation = new  MDM_Bulkupload__c();
                    locBulkUploadLocation.Name = filename;
                    locBulkUploadLocation.Uploaded_Row_Original__c= result[i];
                    locBulkUploadLocation.IsProcessed__c= false;
                    locBulkUploadLocation.MDM_Source__c= locationSource;
                    if(locBulkUploadLocation.Uploaded_Row_Original__c != '')
                    {
                        llist.add(locBulkUploadLocation);
                    }
                    //IsValidRecord = true;   
                    //String validationErrMsg  = '';  
                    //csvRecordData = result[i].split(',');
                    system.debug(csvRecordData);
                    //String csvr = csvRecordData[0];
                    //csvr = String.valueOf(csvr).trim();
                    
                    
                }
                //Database.SaveResult[] srList = Database.insert(llist, false);
                insertHelper(llist,filename);
                //ApexPages.Message loadMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,UploadStatusMsg,'00detail'));
                locationListName='';
            }
            else //if(IsValidRecord)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errmessage,'00detail'));
                
            }
            
            
            //srList = Database.insert(LocationUploadList, false);
            //insert LocationUploadList ;
        } catch (System.DmlException e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getDMLMessage(0));
            ApexPages.addMessage(errorMessage);
            
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid file with errors.');
            
            ApexPages.Message errorMessage1 =   new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
            ApexPages.addMessage(errorMessage1);
        }
        csvFileBody = null;
        
    } 
}