@isTest
public class TestUpdateQuoteLineItemsTrigger {
	@isTest
    static void Run() {
        Opportunity opp = new Opportunity(CloseDate = Date.Today().addDays(1), Name = 'test', ForecastCategoryName = 'Pipeline', Probability = 0.5, StageName='Prospecting');
        insert opp;
        Quote qt = new Quote(OpportunityId = opp.Id, Name = 'Test');
        insert qt;
        /*Product2 product = new Product2(Name = 'Test');
        insert product;
        QuoteLineItem qtLineItem = new QuoteLineItem(UnitPrice = 10.0, Product2 = product, Quantity = 1, QuoteId = qt.Id, ServiceDate=Date.Today());
        */
        Test.startTest();
		qt.Name='Test 2';
        update qt;
        Test.stopTest();
       	Opportunity oppUpdated = [SELECT Description FROM Opportunity];
        Assert.areEqual('Testing', oppUpdated.Description);
       /* QuoteLineItem qtLineItemAfterInsertion = [SELECT ServiceDate FROM QuoteLineItem];
        Date dayAfterToday = Date.Today().addDays(1);
       */
    }
}