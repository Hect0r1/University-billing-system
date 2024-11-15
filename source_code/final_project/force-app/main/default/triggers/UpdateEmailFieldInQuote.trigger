trigger UpdateEmailFieldInQuote on Quote (after insert) {
	UpdateEmailFieldInQuoteHandler.Run(Trigger.new);
}