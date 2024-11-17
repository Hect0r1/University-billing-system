@isTest
public class TestCheckChangeInAverageHandler {
	@isTest
    static void Run() {
        
        Opportunity opp = new Opportunity(CloseDate = Date.Today().addDays(1), Name = 'test', ForecastCategoryName = 'Pipeline', Probability = 0.5, StageName='Prospecting');
        insert opp;
        Contact cont = new Contact(FirstName='Test first name', LastName='Test last name', Period__c='Semester', Average__c=10, Email='email@fakemail.com');
        insert cont;
        Product2 product = new Product2(Name='Test name', IsActive=true);
        insert product;
        Pricebook2 priceB = new Pricebook2(Name='test name', IsActive = true);
        insert priceB;
        Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        PricebookEntry priceBE = new PricebookEntry(IsActive=true, UnitPrice=10.0, Pricebook2Id=priceB.Id, Product2Id=product.Id);
        insert priceBE;
        Quote qt = new Quote(OpportunityId = opp.Id, Name = 'Test name', ContactId=cont.Id, Payment_Method__c='Monthly', Status='Draft', Pricebook2Id=priceB.Id, Scholarship_options__c='Excellence;Sports;Related teachers');
        insert qt;
        List<QuoteLineItem> qtLineItems = new List<QuoteLineItem>();
        QuoteLineItem qtLineItem = new QuoteLineItem(UnitPrice = 10.0, Quantity = 1, QuoteId = qt.Id, PricebookEntryId=priceBE.Id, Product2Id=product.Id);
        qtLineItems.add(qtLineItem);
        insert qtLineItems;
        
        Test.startTest();
        cont.Average__c = 9;
        update cont;
        Test.stopTest();
        
        Quote updatedQuote = [SELECT Scholarship_options__c FROM Quote];
        Assert.areEqual('Sports;Related teachers', updatedQuote.Scholarship_options__c);
    }
}