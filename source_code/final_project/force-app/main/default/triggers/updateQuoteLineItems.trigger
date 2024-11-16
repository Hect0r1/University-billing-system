trigger updateQuoteLineItems on Quote (after update, after insert) {
	updateQuoteLineItemsHandler.Run(Trigger.new);
}