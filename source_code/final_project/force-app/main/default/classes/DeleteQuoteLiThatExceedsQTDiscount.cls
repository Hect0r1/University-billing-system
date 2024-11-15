public class DeleteQuoteLiThatExceedsQTDiscount {
    public static void Run(List<QuoteLineItem> updatedQuoteLineItems) {
        Quote relatedQt = [SELECT Discount FROM Quote WHERE Id =: updatedQuoteLineItems[0].QuoteId];
        QuoteLineItem cloneQTLI = updatedQuoteLineItems[0].clone(true);
        if (relatedQt.Discount == 0) {
            delete cloneQTLI;
        }
    }
}