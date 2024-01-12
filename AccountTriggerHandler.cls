public class AccountTriggerHandler {

    // Handler for account trigger that handles all different trigger contexts

    private Integer size;
    private Boolean isExceting;
    private AccountTriggerHelper helper;

    public AccountTriggerHandler(Integer triggerSize, Boolean triggerIsExecuting){
        this.size = triggerSize;
        this.isExecuting = triggerIsExecuting;
        this.helper = new AccountTriggerHelper();
    }

    /*
    public void BeforeInsert(){}

    public void BeforeDelete(){}

    public void BeforeUpdate(){}

    public void afterInsert(){}

    public void afterDelete(){} */

    public void afterUpdate(List<Account> triggerOld, List<Account> triggerNew, Map<Id,Account> triggerOldMap, Map<Id,Account> triggerNewMap){
        helper.handleAccountMissionsStatus(triggerNew, triggerOldMap);
    }    

}