global with sharing class MDM_Product_BulkUploadProductExtbt implements Database.Batchable<MDM_BulkUpload__c>,Database.Stateful{    
    global list<MDM_BulkUpload__c> blList;
    global String filename;
    global MDM_Product_BulkUploadProductExtbt(list<MDM_BulkUpload__c>al, string pfilename){
        blList=al;
        filename = pfilename;
    }
    
    global Iterable<MDM_BulkUpload__c> start(Database.BatchableContext BC){
        //return Database.getQueryLocator(query);
        return blList;
    }
    global void execute(Database.BatchableContext BC, List<MDM_BulkUpload__c> scope){
        insert scope;
    }
    global void finish(Database.BatchableContext BC){
        try
        {
            integer cnt = blList.Size();
            string Msg = 'Your products file is loaded for validation.';
            
            
            // Get the ID of the AsyncApexJob representing this batch job
            // from Database.BatchableContext.
            // Query the AsyncApexJob object to retrieve the current job's information.
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
                mail.setToAddresses(toAddresses);
            mail.setSubject(filename + '  Upload status  - ' + a.Status);
            string Msg1 =  'Upload Date                 : ' + Datetime.now().format('MM/dd/yyyy hh:mm a') + ' .\n';
            string Msg2 =  'Name of the upload          : ' + filename  +  ' .\n';
            String Msg3 =  'Number of records in file   : ' + cnt +  ' .\n'; 
            String Msg4 =  'Upload status               : ' + a.Status +  ' .\n';
            String Msg5 =  'Mastering Products: Pending : ' +  ' .\n';
            mail.setPlainTextBody(Msg1+Msg2+Msg3+Msg4+Msg5 ); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(System.EmailException ex){
            system.debug('============== email exception caught!!!=============');
        }
        //kick of the validation process
        MDM_Product_ValidateProductbt  objValidatebatch = new MDM_Product_ValidateProductbt(filename);
        Database.executebatch(objValidatebatch,25);
    }
    public MDM_Product_BulkUploadProductExtbt(ApexPages.StandardController controller) {
        
        
    }
}