trigger CheckChangeInAverage on Contact (after update) {
	CheckChangeInAverageHandler.Run(Trigger.new);
}