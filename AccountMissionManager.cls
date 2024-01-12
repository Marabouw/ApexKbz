public class AccountMissionManager {
    /*
     *   Class that handles business logic for changing account mission status
     */

    // Sets the account MissionCanceledDate__c for updated account which MissionStatus__c changed
    public static List<Account> manageAccountMissionStatus(List<Account> triggerNew, Map<Id,SObject> triggerOldMap){
        List<Account> accountsToUpdate = new List<Account>();

        for(Account acc : triggerNew){
            Account oldAccount = triggerOldMap.get(acc.Id);
            if(acc.MissionStatus__c == 'canceled' && acc.MissionStatus__c != oldAccount.MissionStatus__c && oldAccount.MissionStatus__c == 'active'){
                acc.MissionCanceledDate__c = Date.today();
                accountsToUpdate.add(acc);
            }
        }

        return accountsToUpdate;
    }
}