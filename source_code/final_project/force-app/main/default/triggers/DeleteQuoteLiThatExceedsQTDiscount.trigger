trigger DeleteQuoteLiThatExceedsQTDiscount on QuoteLineItem (after update) {
	DeleteQuoteLiThatExceedsQTDiscount.Run(Trigger.new);
}