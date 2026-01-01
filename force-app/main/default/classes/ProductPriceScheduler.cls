global class ProductPriceScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ProductPriceBatch(), 1);
    }
}
