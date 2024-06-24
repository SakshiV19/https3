global with sharing class SampleFunctionCallback implements MCCallback {
    global void execute(Function__c function, Result__c result, String status) {
        try {
            result.Description__c = 'Added from callback';
            update result;
        } catch (Exception ex) {
            throw new ApplicationException(ex.getMessage() + '' + ex.getStackTraceString());
        }
    }
}