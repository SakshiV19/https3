trigger SystemProperties on System_Property__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  fflib_SObjectDomain.triggerHandler(SystemProperties.class);
}