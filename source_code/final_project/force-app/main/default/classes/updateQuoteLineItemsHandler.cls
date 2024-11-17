public class updateQuoteLineItemsHandler {
    public static void Run(List<Quote> newQuotes) {
        List<Quote> quotesToCreatePDF = new List<Quote>();
        List<Quote> quotesToUpdatePartialPayment = new List<Quote>();
		List<Quote> quotesToChangeItemsDiscounts = new List<Quote>();
   
        for (Integer i = 0; i < newQuotes.size(); i++) {
            Quote oldQuote = (Quote)Trigger.oldMap.get(newQuotes[i].Id);
            if (newQuotes[i].LineItemCount != oldQuote.LineItemCount) {
                quotesToChangeItemsDiscounts.add(newQuotes[i]);
            }
            else if (newQuotes[i].Status == 'Approved' && oldQuote.Status != newQuotes[i].Status) {
                quotesToUpdatePartialPayment.add(newQuotes[i]);
            }
            else if (newQuotes[i].Partial_Payment__c != null && oldQuote.Partial_Payment__c == null) {
                quotesToCreatePDF.add(newQuotes[i]);
            }
        }
        
        if (quotesToUpdatePartialPayment.size() > 0) {
            List<Quote> quotesToUpdatePartPay = [SELECT Contact.Period__c, Payment_Method__C, GrandTotal FROM Quote WHERE Id IN : quotesToUpdatePartialPayment];
            for (Quote currentQt: quotesToUpdatePartPay) {
                if (currentQt.Payment_Method__c == 'Payment in full') {
                    currentQt.Partial_Payment__c = currentQt.GrandTotal;
                }
                else {
                    if (currentQt.Contact.Period__c == 'Quarterly') {
                        currentQt.Partial_Payment__c = currentQt.GrandTotal / 4;
                    }
                    else {
                        currentQt.Partial_Payment__c = currentQt.GrandTotal / 6;
                    }
                }
            }
            update quotesToUpdatePartPay;
        }
        
        
        if (quotesToCreatePDF.size() > 0) {
            EmailPDFController.generatePDFAndSendEmail(quotesToCreatePDF);
        }
        
        // The logic inside this 'if' updates the discounts in the related Quote Line Items when a new Quote Line Item is just related to a Quote
        if (quotesToChangeItemsDiscounts.size() > 0) {
            List<QuoteLineItem> qtLineItems = [SELECT Discount, Quote.Id FROM QuoteLineItem WHERE Quote.Id in : quotesToChangeItemsDiscounts];
            List<QuoteLineItem> qtLineItemsToUpdate = new List<QuoteLineItem>();
            for (Integer i = 0; i < quotesToChangeItemsDiscounts.size(); i++) {
                List<QuoteLineItem> correspondingQtLI = new List<QuoteLineItem>();
                for (Integer j = 0; j < qtLineItems.size(); j++) {
                    if (quotesToChangeItemsDiscounts[i].Id == qtLineItems[j].Quote.Id) {
                        correspondingQTLI.add(qtLineItems[j]);
                    }
                }
                if (correspondingQTLI.size() == 1) {
                    correspondingQTLI[0].Discount = 0;
                }
                else if(correspondingQTLI.size() == 2) {
                    correspondingQTLI[0].Discount = 0;
                    correspondingQTLI[1].Discount = 10;
                }
                else if(correspondingQTLI.size() >= 3) {
                    for (Integer k = 0; k < correspondingQTLI.size(); k++) {
                        if (k == 0) {
                            correspondingQTLI[k].Discount = 0;
                        }
                        else {
                            correspondingQTLI[k].Discount = 15;
                        }
                    }
                }
                if (quotesToChangeItemsDiscounts[i].Payment_Method__c == 'Payment in full') {
                    for (Integer o = 0; o < correspondingQTLI.size(); o++) {
                        correspondingQTLI[o].Discount += 5;
                    }
                }
                if (quotesToChangeItemsDiscounts[i].Scholarship_options__c != null) {
                    if (quotesToChangeItemsDiscounts[i].Scholarship_options__c.length() > 0) {
                        for (Integer g = 0; g < correspondingQTLI.size(); g++) {
                            List<String> scholarshipOptions = quotesToChangeItemsDiscounts[i].Scholarship_options__c.split(';');
                            for (Integer c = 0; c < scholarshipOptions.size(); c++) {
                                if (scholarshipOptions[c] == 'Excellence') {
                                    correspondingQTLI[g].Discount += 10;
                                }
                                if (scholarshipOptions[c] == 'Sports') {
                                    correspondingQTLI[g].Discount += 10;
                                }
                                if (scholarshipOptions[c] == 'Related teachers') {
                                    correspondingQTLI[g].Discount += 30;
                                }
                                if (scholarshipOptions[c] == 'Economic need') {
                                    correspondingQTLI[g].Discount += 30;
                                }
                            } 
                        }
                    }  
                }

                qtLineItemsToUpdate.addAll(correspondingQtLI);
            }
            update qtLineItemsToUpdate;  
        }
        List<Quote> qtToChangeDiscountPm = new List<Quote>();
        for (Quote qt : newQuotes) {
            Quote oldQt = (Quote)Trigger.oldMap.get(qt.Id);
            if (qt.Payment_Method__c != oldQt.Payment_Method__c) {
                qtToChangeDiscountPm.add(qt);
            }
        }

        // The logic inside this 'if' updates de discounts in the related Quote Line Items when the 'Payment method' is changed
        if (qtToChangeDiscountPm.size() > 0) {
            List<QuoteLineItem> qtLineItems = [SELECT Discount, Quote.Id FROM QuoteLineItem WHERE Quote.Id in : newQuotes];
            List<QuoteLineItem> qtLineItemsToUpdate = new List<QuoteLineItem>();
            for (Quote qt : qtToChangeDiscountPm) {
                for (QuoteLineItem qtLI : qtLineItems) {
                    if (qt.Id == qtLI.Quote.Id && qt.Payment_Method__c == 'Payment in full') {
                        qtLI.Discount += 5;
                        qtLineItemsToUpdate.add(qtLI);
                    }
                    else if (qt.Id == qtLI.Quote.Id && qt.Payment_Method__c == 'Monthly') {
                        qtLI.Discount -= 5;
                        qtLineItemsToUpdate.add(qtLI);
                    }
                }
            }
            update qtLineItemsToUpdate;
        }
		List<Quote> quotesToChangeItemsDiscountScholarNew = new List<Quote>();
        List<Quote> quotesToChangeItemsDiscountScholarOld = new List<Quote>();
        for (Integer i = 0; i < newQuotes.size(); i++) {
            Quote oldQuote = (Quote)Trigger.oldMap.get(newQuotes[i].Id);
            if (newQuotes[i].Scholarship_options__c != oldQuote.Scholarship_options__c) {
                quotesToChangeItemsDiscountScholarNew.add(newQuotes[i]);
                quotesToChangeItemsDiscountScholarOld.add(oldQuote);
            }
        }

        if (quotesToChangeItemsDiscountScholarNew.size() > 0) {
            List<QuoteLineItem> relatedQuoteLineItems = [SELECT Discount, Quote.Id FROM QuoteLineItem WHERE Quote.Id in : quotesToChangeItemsDiscountScholarNew];
            List<QuoteLineItem> quoteLineItemsToUpdate = new List<QuoteLineItem>();
            for (Integer i = 0; i < quotesToChangeItemsDiscountScholarNew.size(); i++) {
                for (QuoteLineItem qtLineItem : relatedQuoteLineItems) {
                    if (quotesToChangeItemsDiscountScholarNew[i].Id == qtLineItem.Quote.Id) {
                        if (quotesToChangeItemsDiscountScholarNew[i].Scholarship_options__c == null) {
                            List<String> oldQuoteSchoolOptionsList = quotesToChangeItemsDiscountScholarOld[i].Scholarship_options__c.split(';');
                            for (Integer k = 0; k < oldQuoteSchoolOptionsList.size(); k++) {
                                if (oldQuoteSchoolOptionsList[k] == 'Excellence') {
                                    qtLineItem.Discount -= 10;
                                }
                                else if (oldQuoteSchoolOptionsList[k] == 'Sports') {
                                    qtLineItem.Discount -= 10;
                                }
                                else if (oldQuoteSchoolOptionsList[k] == 'Related teachers') {
                                    qtLineItem.Discount -= 30;
                                }
                                else if (oldQuoteSchoolOptionsList[k] == 'Economic need') {
                                    qtLineItem.Discount -= 30;
                                }
                            }
                        }
                        else if (quotesToChangeItemsDiscountScholarOld[i].Scholarship_options__c == null) {
                            List<String> newQuoteSchoolOptionsList = quotesToChangeItemsDiscountScholarNew[i].Scholarship_options__c.split(';');
                            for (Integer k = 0; k < newQuoteSchoolOptionsList.size(); k++) {
                                if (newQuoteSchoolOptionsList[k] == 'Excellence') {
                                    qtLineItem.Discount += 10;
                                }
                                else if (newQuoteSchoolOptionsList[k] == 'Sports') {
                                    qtLineItem.Discount += 10;
                                }
                                else if (newQuoteSchoolOptionsList[k] == 'Related teachers') {
                                    qtLineItem.Discount += 30;
                                }
                                else if (newQuoteSchoolOptionsList[k] == 'Economic need') {
                                    qtLineItem.Discount += 30;
                                }
                            }
                        }
                        else {
                            List<String> newQuoteSchoolOptionsList = quotesToChangeItemsDiscountScholarNew[i].Scholarship_options__c.split(';');
                            List<String> oldQuoteSchoolOptionsList = quotesToChangeItemsDiscountScholarOld[i].Scholarship_options__c.split(';');
                            for (Integer j = 0; j < oldQuoteSchoolOptionsList.size(); j++) {
                                if (!newQuoteSchoolOptionsList.contains(oldQuoteSchoolOptionsList[j])) {
                                    if (oldQuoteSchoolOptionsList[j] == 'Excellence') {
                                        qtLineItem.Discount -= 10;
                                    }
                                    else if (oldQuoteSchoolOptionsList[j] == 'Sports') {
                                        qtLineItem.Discount -= 10;
                                    }
                                    else if (oldQuoteSchoolOptionsList[j] == 'Related teachers') {
                                        qtLineItem.Discount -= 30;
                                    }
                                    else if (oldQuoteSchoolOptionsList[j] == 'Economic need') {
                                        qtLineItem.Discount -= 30;
                                    }
                                }
                            }
                            for (Integer c = 0; c < newQuoteSchoolOptionsList.size(); c++) {
                                if (!oldQuoteSchoolOptionsList.contains(newQuoteSchoolOptionsList[c])) {
                                    if (newQuoteSchoolOptionsList[c] == 'Excellence') {
                                        qtLineItem.Discount += 10;
                                    }
                                    else if (newQuoteSchoolOptionsList[c] == 'Sports') {
                                        qtLineItem.Discount += 10;
                                    }
                                    else if (newQuoteSchoolOptionsList[c] == 'Related teachers') {
                                        qtLineItem.Discount += 30;
                                    }
                                    else if (newQuoteSchoolOptionsList[c] == 'Economic need') {
                                        qtLineItem.Discount += 30;
                                    }
                                }
                            }
                        }
                        quoteLineItemsToUpdate.add(qtLineItem);
                    }
                }
            }
            update quoteLineItemsToUpdate;
        }
		List<Quote> updatedQuotes = [SELECT Id, Discount FROM Quote WHERE Id IN : newQuotes];
        List<Quote> currentQuotesToDeleteQLI = new List<Quote>();
        List<QuoteLineItem> quoteLineItemsToDelete = new List<QuoteLineItem>();
        List<Quote> quotesToUpdate = new List<Quote>();
        for (Quote currentNewQt : newQuotes) {
            for (Quote currentUpdateQuote: updatedQuotes) {
                if (currentUpdateQuote.Id == currentNewQt.Id) {
                    Quote oldQt = (Quote)Trigger.oldMap.get(currentNewQt.Id);
                    if (currentUpdateQuote.Discount > 60 && currentNewQt.LineItemCount > oldQt.LineItemCount) {
                        currentQuotesToDeleteQLI.add(currentNewQt);
                    }
                    else if (currentNewQt.Scholarship_options__c != null) {
                        if (currentUpdateQuote.Discount > 60 && oldQt.Scholarship_options__c == null) {
                            Quote currentNewQtClone = currentNewQt.clone(true);
                            currentNewQtClone.Scholarship_options__c = oldQt.Scholarship_options__c;
                            if (currentNewQt.Payment_Method__c != oldQt.Payment_Method__c && currentNewQt.Payment_Method__c == 'Payment in full') {
                                currentNewQtClone.Payment_Method__c = 'Monthly';
                            }
                            quotesToUpdate.add(currentNewQtClone);
                        }
                        else if (oldQt.Scholarship_options__c != null && currentNewQt.Scholarship_options__c.length() > oldQt.Scholarship_options__c.length()) {
                            if (currentUpdateQuote.Discount > 60) {
                                Quote currentNewQtClone = currentNewQt.clone(true);
                                currentNewQtClone.Scholarship_options__c = oldQt.Scholarship_options__c;
                                if (currentNewQt.Payment_Method__c != oldQt.Payment_Method__c && currentNewQt.Payment_Method__c == 'Payment in full') {
                                    currentNewQtClone.Payment_Method__c = 'Monthly';
                                }
                                quotesToUpdate.add(currentNewQtClone);
                            } 
                        }
                        else if (currentNewQt.Scholarship_options__c == oldQt.Scholarship_options__c) {
                            if (currentNewQt.Payment_Method__c != oldQt.Payment_Method__c && currentNewQt.Payment_Method__c == 'Payment in full' && currentUpdateQuote.Discount > 60) {
                                Quote currentNewQtClone = currentNewQt.clone(true);
                                currentNewQtclone.Payment_Method__c = 'Monthly';
                                quotesToUpdate.add(currentNewQtClone);
                            }
                        }
                    }
                }
            }
        }

        if (quotesToUpdate.size() > 0) {
            update quotesToUpdate;
        }
        if (currentQuotesToDeleteQLI.size() > 0) {
            List<QuoteLineItem> currentQLIs = [SELECT Quote.Id FROM QuoteLineItem WHERE Quote.Id IN : currentQuotesToDeleteQLI Order by CreatedDate DESC];
            for (Quote currentQt : currentQuotesToDeleteQLI) {
                Quote oldQt = (Quote)Trigger.oldMap.get(currentQt.Id);
                Integer maximumNumOfQLiToSave = currentQt.LineItemCount - oldQt.LineItemCount;
                for (QuoteLineItem currentQLI : currentQLIs) {
                    if (maximumNumOfQLiToSave > 0 && currentQt.Id == currentQLI.Quote.Id) {
                        quoteLineItemsToDelete.add(currentQLI);
                        maximumNumOfQLiToSave--;
                    }
                }
            }
            delete quoteLineItemsToDelete;
        }
    }
}