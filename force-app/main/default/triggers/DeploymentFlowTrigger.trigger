trigger DeploymentFlowTrigger on Deployment_Flow__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(DeploymentFlowTriggerHandler.class);
}