public class CheckChangeInAverageHandler {
    public static void Run(List<Contact> contacts) {
        List<Contact> contactsToUpdateQtSO = new List<Contact>();
        for(Contact contact : contacts) {
            if (contact.Average__c < 9.5) {
                contactsToUpdateQtSO.add(contact);
            }
        }
        if (contactsToUpdateQtSO.size() > 0) {
            List<Quote> relatedQuotes = [SELECT ContactId, Scholarship_options__c FROM QUOTE WHERE ContactId IN : contactsToUpdateQtSO];
            List<Quote> quotesToUpdate = new List<Quote>();
            for (Contact contact : contactsToUpdateQtSO) {
                for (Quote qt : relatedQuotes) {
                    if (qt.ContactId == contact.Id) {
                        if (qt.Scholarship_options__c != null) {
                            List<String> scholarshipOptions = qt.Scholarship_options__c.split(';');
                            if (scholarshipOptions.contains('Excellence')) {
                                String scholarshipOptionsString = '';
                                for (Integer i = 0; i < scholarshipOptions.size(); i++) {
                                    if (i == scholarshipOptions.size() - 1 && scholarshipOptions[i] != 'Excellence') {
                                        scholarshipOptionsString += scholarshipOptions[i];
                                    }
                                    else if (scholarshipOptions[i] != 'Excellence') {
                                        scholarshipOptionsString += scholarshipOptions[i] + ';';
                                    }
                                }
                                qt.Scholarship_options__c = scholarshipOptionsString;
                                quotesToUpdate.add(qt);
                            }
                        }
                    }
                }
            }
            if (quotesToUpdate.size() > 0) {
            	update quotesToUpdate;
            }
        }
    }
}