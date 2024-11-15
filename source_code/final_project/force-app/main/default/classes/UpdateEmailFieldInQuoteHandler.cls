public class UpdateEmailFieldInQuoteHandler {
    public static void Run(List<Quote> insertedQuotes) {
        List<Quote> quotesInserted = [SELECT Contact.Email FROM Quote WHERE Id IN : insertedQuotes];
        List<Quote> quotesToUpdate = new List<Quote>();
        for (Quote currentQt: quotesInserted) {
            Quote currentQtClone = currentQt.clone(true);
            currentQtClone.Email = currentQtClone.Contact.Email;
            quotesToUpdate.add(currentQtClone);
        }
        update quotesToUpdate;
    }
}