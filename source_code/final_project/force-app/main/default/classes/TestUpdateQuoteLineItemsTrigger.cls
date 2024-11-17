@isTest
public class TestUpdateQuoteLineItemsTrigger {
	@isTest
    static void CheckPDFCreationSentWhenPayInFull() {
        Test.startTest();
		Quote qt = createTestData('Payment in full', 'Semester', 1, '');
		qt.Status='Approved';
        update qt;
        Test.stopTest();

       	Quote qtUpdated = [SELECT Payment_Method__c, Partial_Payment__c, GrandTotal FROM Quote];
        QuoteLineItem qtLineItemUpdated = [SELECT Discount, QuoteId FROM QuoteLineItem];
        // This would fail if there was no quote document created
        QuoteDocument qtDoc = [SELECT Id FROM QuoteDocument];
       
        Assert.areEqual(5, qtLineItemUpdated.Discount);
        Assert.areEqual('Payment in full', qtUpdated.Payment_Method__c);
        Assert.isTrue(qtUpdated.Partial_Payment__c == qtUpdated.GrandTotal);
    }
    
    @isTest
    static void CheckPDFCreationSentWhenMonthlyPayAndSemester() {
        
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Semester', 1, '');
        qt.Status = 'Approved';
        update qt;
        Test.stopTest();
        
        // This would fail if there was no quote document created
        QuoteDocument qtDoc = [SELECT Id FROM QuoteDocument];
        
        Quote qtUpdated = [SELECT Payment_Method__c, Partial_Payment__c, GrandTotal FROM Quote];
        QuoteLineItem qtLineItemUpdated = [SELECT Discount, QuoteId FROM QuoteLineItem];
        
        Assert.areEqual(0, qtLineItemUpdated.Discount);
        Assert.isTrue(qtUpdated.Partial_Payment__c == qtUpdated.GrandTotal / 6);
    }
    
    @isTest
    static void CheckPDFCreationSentWhenMonthlyAndQuarterly() {
        
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, '');
        qt.Status = 'Approved';
        update qt;
        Test.stopTest();
        
        // This would fail if there was no quote document created
        QuoteDocument qtDoc = [SELECT Id FROM QuoteDocument];
        
        Quote qtUpdated = [SELECT Payment_Method__c, Partial_Payment__c, GrandTotal FROM Quote];
        QuoteLineItem qtLineItemUpdated = [SELECT Discount, QuoteId FROM QuoteLineItem];
        
        Assert.areEqual(0, qtLineItemUpdated.Discount);
        Assert.isTrue(qtUpdated.Partial_Payment__c == qtUpdated.GrandTotal / 4);
    }
    
    @isTest
    static void CheckQuoteLIDiscountdsWhenTwo() {
        
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 2, '');
        Test.stopTest();
        
        List<QuoteLineItem> qtLineItems = [SELECT Discount FROM QuoteLineItem];
        
        Assert.isTrue(qtLineItems.size() == 2);
        Assert.areEqual(0 , qtLineItems[0].Discount);
        Assert.areEqual(10, qtLineItems[1].Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenThree() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 3, '');
        Test.stopTest();
        
        List<QuoteLineItem> qtLineItems = [SELECT Discount FROM QuoteLineItem];
        
        Assert.isTrue(qtLineItems.size() == 3);
        Assert.areEqual(0 , qtLineItems[0].Discount);
        Assert.areEqual(15, qtLineItems[1].Discount);
        Assert.areEqual(15, qtLineItems[2].Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenFour() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 4, '');
        Test.stopTest();
        
        List<QuoteLineItem> qtLineItems = [SELECT Discount FROM QuoteLineItem];
        
        Assert.isTrue(qtLineItems.size() == 4);
        Assert.areEqual(0 , qtLineItems[0].Discount);
        Assert.areEqual(15, qtLineItems[1].Discount);
        Assert.areEqual(15, qtLineItems[2].Discount);
        Assert.areEqual(15, qtLineItems[3].Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenSports() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, 'Sports');
        Test.stopTest();
        
        QuoteLineItem qtLineItem = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual('Sports', qt.Scholarship_options__c);
        Assert.areEqual(10, qtLineItem.Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenEconomicNeed() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, 'Economic need');
        Test.stopTest();
        
        QuoteLineItem qtLineItem = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual('Economic need', qt.Scholarship_options__c);
        Assert.areEqual(30, qtLineItem.Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenExcellence() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, 'Excellence');
        Test.stopTest();
        
        QuoteLineItem qtLineItem = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual('Excellence', qt.Scholarship_options__c);
        Assert.areEqual(10, qtLineItem.Discount);
    }
    
    @isTest
    static void CheckQuoteLIDiscountWhenRelatedTeachers() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, 'Related teachers');
        Test.stopTest();
        
        QuoteLineItem qtLineItem = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual('Related teachers', qt.Scholarship_options__c);
        Assert.areEqual(30, qtLineItem.Discount);
    }
    
    @isTest
    static void CheckDiscountChangingToPF() {
        Quote qt = createTestData('Monthly', 'Semester', 1, '');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Payment_Method__c = 'Payment in full';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(0, qtLIBeforeUpdate.Discount);
        Assert.areEqual(5, qtLI.Discount);
    }
    
    @isTest
    static void CheckDiscountChangingToMonth() {
        Quote qt = createTestData('Payment in full', 'Semester', 1, '');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Payment_Method__c = 'Monthly';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(5, qtLIBeforeUpdate.Discount);
        Assert.areEqual(0, qtLI.Discount);
    }
    
    @isTest
    static void CheckExcellenceIsRemoved() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Excellence');
        String scholarshipBeforeUpdate = qt.Scholarship_options__c;
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = null;
        update qt;
        Test.stopTest();
        
        Quote qtUpdated = [SELECT Scholarship_options__c FROM Quote];
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(null, qtUpdated.Scholarship_options__c);
        Assert.areEqual('Excellence', scholarshipBeforeUpdate);
        Assert.areEqual(10, qtLIBeforeUpdate.Discount);
        Assert.areEqual(0, qtLI.Discount);
    }
    
    @isTest
    static void CheckSportsIsRemoved() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Sports');
        String scholarshipBeforeUpdate = qt.Scholarship_options__c;
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = null;
        update qt;
        Test.stopTest();
        
        Quote qtUpdated = [SELECT Scholarship_options__c FROM Quote];
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(null, qtUpdated.Scholarship_options__c);
        Assert.areEqual('Sports', scholarshipBeforeUpdate);
        Assert.areEqual(10, qtLIBeforeUpdate.Discount);
        Assert.areEqual(0, qtLI.Discount);
    }
    
    @isTest
    static void CheckRelatedTeachersIsRemoved() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Related teachers');
        String scholarshipBeforeUpdate = qt.Scholarship_options__c;
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = null;
        update qt;
        Test.stopTest();
        
        Quote qtUpdated = [SELECT Scholarship_options__c FROM Quote];
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(null, qtUpdated.Scholarship_options__c);
        Assert.areEqual('Related teachers', scholarshipBeforeUpdate);
        Assert.areEqual(30, qtLIBeforeUpdate.Discount);
        Assert.areEqual(0, qtLI.Discount);
    }
    
    @isTest
    static void CheckEconomicNeedIsRemoved() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Economic need');
        String scholarshipBeforeUpdate = qt.Scholarship_options__c;
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = null;
        update qt;
        Test.stopTest();
        
        Quote qtUpdated = [SELECT Scholarship_options__c FROM Quote];
        QuoteLineItem qtLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(null, qtUpdated.Scholarship_options__c);
        Assert.areEqual('Economic need', scholarshipBeforeUpdate);
        Assert.areEqual(30, qtLIBeforeUpdate.Discount);
        Assert.areEqual(0, qtLI.Discount);
    }
    
    @isTest
    static void CheckThreeScholarshipsAddedWhenInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, '');
       	QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Excellence;Sports;Related teachers';
        update qt;
        Test.stopTest();
        
        QuoteLineItem updatedQLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(0, qtLIBeforeUpdate.Discount);
        Assert.areEqual(50, updatedQLI.Discount);
    }
    
    @isTest
    static void CheckEconomicNeedIsAddedWhenInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, '');
       	QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Economic need';
        update qt;
        Test.stopTest();
        
        QuoteLineItem updatedQLI = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(0, qtLIBeforeUpdate.Discount);
        Assert.areEqual(30, updatedQLI.Discount);
    }
    
    @isTest
    static void CheckSportsRelatedTeachersAreRemovedWhenNotInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Excellence;Sports;Related teachers');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Excellence';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtAfterUpdate = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(50, qtLIBeforeUpdate.Discount);
        Assert.areEqual(10, qtAfterUpdate.Discount);
    }
    
    @isTest
    static void CheckExcellenceEconomicNeedAreRemovedWhenNotInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Excellence;Sports;Economic need');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Sports';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtAfterUpdate = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(50, qtLIBeforeUpdate.Discount);
        Assert.areEqual(10, qtAfterUpdate.Discount);
    }
    
    @isTest
    static void CheckSportsRelatedTeachersWereAddedWhenNotInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Excellence');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Excellence;Sports;Related teachers';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtLIAfterUpdate = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(10, qtLIBeforeUpdate.Discount);
        Assert.areEqual(50, qtLIAfterUpdate.Discount);
    }
    
    @isTest
    static void CheckExcellenceEconomicNeedWereAddedWhenNotInitiallyNull() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Sports');
        QuoteLineItem qtLIBeforeUpdate = [SELECT Discount FROM QuoteLineItem];
        Test.startTest();
        qt.Scholarship_options__c = 'Excellence;Sports;Economic need';
        update qt;
        Test.stopTest();
        
        QuoteLineItem qtLIAfterUpdate = [SELECT Discount FROM QuoteLineItem];
        Assert.areEqual(10, qtLIBeforeUpdate.Discount);
        Assert.areEqual(50, qtLIAfterUpdate.Discount);
    }
    
    @isTest
    static void CheckQuoteLIWasRemovedWhenDiscountAboveSixty() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Economic need;Related teachers');
    	List<QuoteLineItem> qtLIsBeforeUpdate = [SELECT Id FROM QuoteLineItem];
        
        Test.startTest();
        Product2 product = new Product2(Name='Test name2', IsActive=true);
        insert product;
        Pricebook2 priceB = new Pricebook2(Name='test name2', IsActive = true);
        insert priceB;
        Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 1000, IsActive = true);
    	insert standardPBE;
        PricebookEntry priceBE = new PricebookEntry(IsActive=true, UnitPrice=10.0, Pricebook2Id=qt.Pricebook2Id, Product2Id=product.Id);
        insert priceBE;
        QuoteLineItem qtLineItem = new QuoteLineItem(UnitPrice = 10.0, Quantity = 1, QuoteId = qt.Id, PricebookEntryId=priceBE.Id, Product2Id=product.Id);
        insert qtLineItem;
        Test.stopTest();
        
        List<QuoteLineItem> qtLIsAfterUpdate = [SELECT Id FROM QuoteLineItem];
        
        Assert.areEqual(1, qtLIsBeforeUpdate.size());
        Assert.areEqual(1, qtLIsAfterUpdate.size());
    }
    
    @isTest
    static void CheckReversionScholarhipsPaymentMethFirst() {
        Quote qt = createTestData('Monthly', 'Semester', 1, '');
        Test.startTest();
        qt.Scholarship_options__c = 'Economic need;Related teachers';
        qt.Payment_Method__c = 'Payment in full';
        update qt;
        Test.stopTest();
        
        Quote updatedQt = [SELECT Scholarship_options__c, Payment_Method__c FROM Quote WHERE Id =: qt.Id];
        Assert.areEqual(null, updatedQt.Scholarship_options__c);
        Assert.areEqual('Monthly', updatedQt.Payment_Method__c);
    }
    
    @isTest
    static void CheckReversionScholarhipsPaymentMethTwo() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Economic need;Related teachers');
        List<String> scholarshipsBeforeUpdate = qt.Scholarship_options__c.split(';');
        Test.startTest();
        qt.Scholarship_options__c = 'Economic need; Related teachers;Sports';
        qt.Payment_Method__c = 'Payment in full';
        update qt;
        Test.stopTest();
        
        Quote updatedQt = [SELECT Scholarship_options__c, Payment_Method__c FROM Quote WHERE Id =: qt.Id];
        List<String> updatedScholarships = updatedQt.Scholarship_options__c.split(';');
        Assert.isTrue(scholarshipsBeforeUpdate.size() == updatedScholarships.size());
        List<Boolean> flags = new List<Boolean>();
        for (Integer i = 0; i < scholarshipsBeforeUpdate.size(); i++) {
            Boolean isOldInNew = false;
            for (Integer j = 0; j < updatedScholarships.size(); j++) {
                if (scholarshipsBeforeUpdate[i] == updatedScholarships[j]) {
                    isOldInNew = true;
                }
            }
            flags.add(isOldInNew);
        }
        
        Boolean areOldAndUpdatedScholarshipsTheSame = true;
        for (Integer i = 0; i < flags.size(); i++) {
            if (flags[i] == false) {
                areOldAndUpdatedScholarshipsTheSame = false;
            }
        }
        Assert.isTrue(areOldAndUpdatedScholarshipsTheSame);
        Assert.areEqual('Monthly', updatedQt.Payment_Method__c);
    }
    
    @isTest
    static void CheckReversePaymentMethod() {
        Quote qt = createTestData('Monthly', 'Semester', 1, 'Economic need;Related teachers');
        Test.startTest();
        qt.Payment_Method__c = 'Payment in full';
        update qt;
        Test.stopTest();
        
        Quote qtUpdated = [SELECT Payment_Method__c FROM Quote WHERE Id =: qt.Id];
        Assert.areEqual('Monthly', qtUpdated.Payment_Method__c);
    }
    
    @isTest
    static void RunEmailPDFControllerSuccessful() {
        Test.startTest();
        Quote qt = createTestData('Monthly', 'Quarterly', 1, 'Excellence');
        Test.stopTest();
        PageReference pageRefResult = null;
        EmailPDFController controller = null;
        Try {
            PageReference pageRef = new PageReference('/apex/EmailPDF?quoteId=' + qt.Id);
        	Test.setCurrentPage(pageRef);
			controller = new EmailPDFController();
        }
        catch (Exception e) {
            pageRefResult = Page.Failure;
            pageRefResult.getParameters().put('error', 'noInsert');
        }
        
        if (pageRefResult == null) {
            pageRefResult = Page.Success;
        }
        
        pageRefResult.setRedirect(true);
        String nextPage = pageRefResult.getUrl();
        Assert.areEqual('/apex/success', nextPage);
        Assert.isTrue(controller != null);
        Assert.isTrue(controller.qtToGeneratePDF.Payment_Method__c == 'Monthly');
    }
    
    @isTest
    static void RunEmailPDFControllerFailure() {
        PageReference pageRefResult = null;
        EmailPDFController controller = null;
        String invalidId = '12399asdf';
        Try {
            PageReference pageRef = new PageReference('/apex/EmailPDF?quoteId=' + invalidId);
        	Test.setCurrentPage(pageRef);
			controller = new EmailPDFController();
        }
        catch (Exception e) {
            pageRefResult = Page.Failure;
            pageRefResult.getParameters().put('error', 'noInsert');
        }
        
        if (pageRefResult == null) {
            pageRefResult = Page.Success;
        }
        
        pageRefResult.setRedirect(true);
        String nextPage = pageRefResult.getUrl();
        System.assertEquals('/apex/failure?error=noInsert', nextPage);
    }
    
    public static Quote createTestData(String paymentMethod, String period, Integer amountOfQtliToCreate, String scholarShipName) {
        Opportunity opp = new Opportunity(CloseDate = Date.Today().addDays(1), Name = 'test', ForecastCategoryName = 'Pipeline', Probability = 0.5, StageName='Prospecting');
        insert opp;
        Contact cont = new Contact(FirstName='Test first name', LastName='Test last name', Period__c=period, Average__c=10, Email='email@fakemail.com');
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
        Quote qt;
        if (scholarShipName != '') {
            qt = new Quote(OpportunityId = opp.Id, Name = 'Test name', ContactId=cont.Id, Payment_Method__c=paymentMethod, Status='Draft', Pricebook2Id=priceB.Id, Scholarship_options__c=scholarShipName);
        }
        else {
            qt = new Quote(OpportunityId = opp.Id, Name = 'Test name', ContactId=cont.Id, Payment_Method__c=paymentMethod, Status='Draft', Pricebook2Id=priceB.Id);
        }
           
        insert qt;
        List<QuoteLineItem> qtLineItems = new List<QuoteLineItem>();
        for (Integer i = 0; i < amountOfQtliToCreate; i++) {
            QuoteLineItem qtLineItem = new QuoteLineItem(UnitPrice = 10.0, Quantity = 1, QuoteId = qt.Id, PricebookEntryId=priceBE.Id, Product2Id=product.Id);
            qtLineItems.add(qtLineItem);
        }
        insert qtLineItems;
        return qt;
    }
}