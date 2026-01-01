public class ProductPriceBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Dummy query just to trigger the batch
        return Database.getQueryLocator([SELECT Id FROM PriceReceiver__c LIMIT 1]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        ProductPriceReceiver.fetchAndUpsertProducts();
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: logging, notifications, etc.
    }
}
