public class AccountTriggerHelper(){

    /*
     *   Helper class that manages DML transactions for trigger handler and delegates business logic for appropriate classes
     *
     */

    // contructor
    public AccountTriggerHelper(){
        System.debug('AccountTriggerHelper');
    }

    public void handleAccountMissionsStatus(List<Account> triggerNew, Map<Id,SObject> triggerOldMap){

        List<SObject> recordsToUpdate = new List<SObject>();
        List<Account> accountsToUpdate = AccountMissionManager.manageAccountMissionStatus(triggerNew, triggerOldMap);
        List<Contact> contactsToUpdate = ContactActivityManager.manageContactActivityFromAttachedAccounts(accountsToUpdate);

        if(accountsToUpdate?.size() > 0){
            for(Account acc : accountsToUpdate){
                recordsToUpdate.add(acc);
            }
        }

        if(contactsToUpdate?.size() > 0){
            for(Contact ctc : contactsToUpdate){
                recordsToUpdate.add(ctc);
            }
        }

        if(recordsToUpdate.size() > 0){
            try{
                update recordsToUpdate;
            } catch(Exception e){
                System.debug('An error occured while updating records : ' + e.getMessage());
            }
        }
    }

}