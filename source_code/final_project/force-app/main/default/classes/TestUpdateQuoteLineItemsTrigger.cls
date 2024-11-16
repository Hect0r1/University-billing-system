@isTest
public class TestUpdateQuoteLineItemsTrigger {
	@isTest
    static void CheckPartialPayAndPayFullDisc() {
		Quote qt = createTestData();
        Test.startTest();
		qt.Status='Approved';
        update qt;
        Test.stopTest();

       	Quote qtUpdated = [SELECT Payment_Method__c, Partial_Payment__c, GrandTotal FROM Quote];
        QuoteLineItem qtLineItemUpdated = [SELECT Discount, QuoteId FROM QuoteLineItem];
        Assert.areEqual(5, qtLineItemUpdated.Discount);
        Assert.areEqual('Payment in full', qtUpdated.Payment_Method__c);
        Assert.isTrue(qtUpdated.Partial_Payment__c == qtUpdated.GrandTotal);
    }
    
    public static Quote createTestData() {
        Opportunity opp = new Opportunity(CloseDate = Date.Today().addDays(1), Name = 'test', ForecastCategoryName = 'Pipeline', Probability = 0.5, StageName='Prospecting');
        insert opp;
        Contact cont = new Contact(FirstName='testiiiiing', LastName='Testiiiiing', Period__c='Semester', Average__c=10, Email='test@fakemail.com');
        insert cont;
        Product2 product = new Product2(Name='Test', IsActive=true);
        insert product;
        Pricebook2 priceB = new Pricebook2(Name='test', IsActive = true);
        insert priceB;
        Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        PricebookEntry priceBE = new PricebookEntry(IsActive=true, UnitPrice=10.0, Pricebook2Id=priceB.Id, Product2Id=product.Id);
        insert priceBE;
        Quote qt = new Quote(OpportunityId = opp.Id, Name = 'Test', ContactId=cont.Id, Payment_Method__c='Payment in full', Status='Draft', Pricebook2Id=priceB.Id);
        insert qt;
        QuoteLineItem qtLineItem = new QuoteLineItem(UnitPrice = 10.0, Quantity = 1, QuoteId = qt.Id, PricebookEntryId=priceBE.Id, Product2Id=product.Id);
        insert qtLineItem;
        return qt;
    }
}