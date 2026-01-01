public with sharing class ProductFeedService {

    // Pulls tradable products from external trading system
    public static void refreshProducts() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:TradingProductAPI');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = new Http().send(req);

        Map<String,Object> json =
            (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        Map<String,Object> result = (Map<String,Object>) json.get('result');

        List<Product2> toUpsert = new List<Product2>();

        for (String code : result.keySet()) {
            Map<String,Object> p = (Map<String,Object>) result.get(code);

            Product2 prod = new Product2();
            prod.ProductCode = code;
            prod.Name = (String) p.get('description');
            prod.GoldPrice__c = Decimal.valueOf(p.get('buyPrice').toString());
            prod.Category__c = (String) p.get('category');

            toUpsert.add(prod);
        }

        upsert toUpsert ProductCode;
    }
}
