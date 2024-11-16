public class EmailPDFController {
    
    public Quote qtToGeneratePDF {get; set;}
    
    public List<QuoteLineItem> qtLineItemsToDisplay {get; set;}
    
    public List<String> scholarshipOptions {get; set;}
    
    public EmailPDFController() {
        
        String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        this.qtToGeneratePDF = [SELECT LineItemCount, Subtotal, Discount, TotalPrice, Scholarship_options__c, Partial_Payment__c, Payment_Method__c, Contact.Period__c FROM Quote WHERE Id =: quoteId];
        this.qtLineItemsToDisplay = [SELECT QuoteId, Product2.Name, UnitPrice, Subtotal, Discount FROM QuoteLineItem WHERE QuoteId =: quoteId];
		List<String> scholarships = new List<String>();
        if (qtToGeneratePDF.Scholarship_options__c != null) {
            this.scholarshipOptions = qtToGeneratePDF.Scholarship_options__c.split(';');
        }
        
    }
    
    public static void generatePDFAndSendEmail(List<Quote> quotes) {
        
        List<Quote> quotesWithContactsNames = [SELECT Contact.Name, Email, Id FROM Quote WHERE Id IN : quotes];
        List<String> idNameEmails = new List<String>();
        for (Quote currentQt : quotesWithContactsNames) {
            String idNameEmail = currentQt.Id + ';' + currentQt.Contact.Name + ';' + currentQt.Email;
            idNameEmails.add(idNameEmail);
        }
        createPDFsAndSendEmail(idNameEmails);
    }
    
    @future(callout=true)
    public static void createPDFsAndSendEmail(List<String> idNameEmails) {
        List<QuoteDocument> quoteDocumentsToSave = new List<QuoteDocument>();
        for (String currentIdNameEmail : idNameEmails) {
            
            Integer indexForQuoteId = 0;
            Integer indexForQuotesContactName = 1;
            Integer indexForQuotesContactEmail = 2;
            
            List<String> currentIdNameEmailList = currentIdNameEmail.split(';');
            PageReference invoicePDF = new PageReference('/apex/EmailPDF?quoteId=' + currentIdNameEmailList[indexForQuoteId]);
            Blob quoteBlob;
            if (!test.isRunningTest()){
            	quoteBlob = invoicePDF.getContent();
            }
            else {
            	quoteBlob = blob.valueof('TEST');
            }
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            
            attachment.setContentType('application/pdf');
            attachment.setFileName('Invoice.pdf');
            attachment.body = quoteBlob;
            attachment.setInline(false);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(new String[] {currentIdNameEmailList[indexForQuotesContactEmail]});
            mail.setSubject('School invoice pdf');
            mail.setHtmlBody('Greetings ' + currentIdNameEmailList[indexForQuotesContactName] + ', here is your tuition invoice of the next school term.');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
         
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    
            QuoteDocument quoteDoc = new QuoteDocument();
            quoteDoc.Document = quoteBlob;
            quoteDoc.QuoteId = currentIdNameEmailList[indexForQuoteId];
            quoteDocumentsToSave.add(quoteDoc);
        }
        Database.insert(quoteDocumentsToSave);
    }
}