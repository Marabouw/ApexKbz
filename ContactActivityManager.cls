public class ContactActivityManager {

    public static List<Contact> manageContactActivityFromAttachedAccounts(List<Account> updatedMissionStatusAccounts){
        /*   @Param : a list of accounts which have field MissionStatus__c updated to 'canceled'
         *   @Return value : a list of contacts, related to accounts in parameters, which have all attached accounts status set to false
         *   ----------------------------------------------------------------------------------------------------------------------------
         *   1. Populates a map containing ContactId as a key and related accounts status as a value
         *   2. For all contact Ids, checks if all of accounts status are set as canceled
         *   3. Makes modifications on Contacts that match that condition and add them on a list to return
         *   4. Makes synchronization callout for modified contacts with ContactApiManager class
         */
        
        // Set containing Ids from updatedMissionStatusAccounts list
        Set<Id> accountIds = new Set<Id>();
        
        for(Account acc : updatedMissionStatusAccounts){
            accountIds.add(acc.Id);
        }

        // List containing junction object data between Account and Contact from updatedMissionStatusAccounts accounts Ids
        List<AccountContactRelation> accountsAttachedToContacts = [SELECT ContactId, Account.MissionStatus__c FROM AccountContactRelation WHERE AccountId IN: accountIds];

        // Map that stores contactId as a key and a list of account mission status as values
        Map<Id,List<String>> contactAndAccountsMissionStatusMap = new Map<Id,List<String>>();

        // Iteration over junction object accountsAttachedToContacts records queried to populate contactAndAccountsMissionStatusMap
        for(AccountContactRelation accAndContact : accountsAttachedToContacts){
            if(!contactAndAccountsMissionStatusMap.containsKey(accAndContact.ContactId)){
                contactAndAccountsMissionStatusMap.put(accAndContact.ContactId, new List<String>{accAndContact.MissionStatus__c};
            } else {
                contactAndAccountsMissionStatusMap.get(accAndContact.ContactId).add(accAndContact.MissionStatus__c);
            }
        }

        // Set that will contain Ids from contactIds keys in map which attached values are list containing only canceled status
        Set<Id> contactsToBeCancelledIds = new Set<Id>();

        // Iteration over map to store contactIds matching criteria mentioned above
        for(Id contactId : contactAndAccountsMissionStatusMap.keySet()){
            Integer canceledAccountsCount = 0;
            for(String missionStatus : contactAndAccountsMissionStatusMap.get(contactId)){
                if(missionStatus == 'canceled') canceledAccountsCount++;
            }

            if(contactAndAccountsMissionStatusMap.get(contactId).size() == canceledAccountsCount && !contactAndAccountsMissionStatusMap.get(contactId).contains('active')){
                contactsToBeCancelledIds.add(contactId);
            }
        }

        // Apply modification on contacts from contactsToBeCancelledIds
        if(contactsToBeCancelledIds.size() > 0){

            List<Contact> contactsToBeCancelled = [SELECT Id, isActive__c FROM Contact WHERE Id IN: contactsToBeCancelledIds];
            for(Contact ctc : contactsToBeCancelled){
                ctc.isActive__c = false;
            }

            // Callout for API synchronization
            ContactApiManager.syncContacts(contactsToBeCancelled);

            return contactsToBeCancelled;

        } else {
            return null;
        }
    }
}