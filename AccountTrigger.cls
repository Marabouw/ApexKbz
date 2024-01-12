trigger AccountTrigger on Account (after update){

    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.size, Trigger.isExecuting);

    switch on Trigger.operationType {
        when AFTER_UPDATE{
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}