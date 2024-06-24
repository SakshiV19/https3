public with sharing class RollbackHeaderCtrl {
    @AuraEnabled
    public static Id initiateRollback(String config) {
        try {
            if (String.isBlank(config)) {
                throw new AuraHandledException('test');
            }

            RollbackConfig rollbackConfig = (RollbackConfig) JSON.deserialize(config, RollbackConfig.class);

            if (
                rollbackConfig == null ||
                (String.isBlank(rollbackConfig.promotionId) ||
                rollbackConfig.isValidation == null ||
                rollbackConfig.startExecution == null ||
                String.isBlank(rollbackConfig.testLevel))
            ) {
                throw new AuraHandledException('test');
            }

            return 'a177Q000001m03gQAA';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    // INNER
    public class RollbackConfig {
        @AuraEnabled
        public Boolean isValidation;
        @AuraEnabled
        public String testLevel;
        @AuraEnabled
        public Id promotionId;
        @AuraEnabled
        public Boolean startExecution;
    }
}