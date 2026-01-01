global class TradingScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ProductFeedService.refreshProducts();
    }
}
