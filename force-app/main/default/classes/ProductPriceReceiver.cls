public with sharing class ProductPriceReceiver {

    // Uses Named Credential: TradingProductAPI
    private static final String ENDPOINT = 'callout:TradingProductAPI';

    /**
     * Fetches tradable products, premiums and availability from external trading system
     * and upserts them into Salesforce.
     */
    public static void fetchAndUpsertProducts() {

        // Metadata-driven filters (metal + category)
        List<MetalCategoryConfig__mdt> configs = [
            SELECT MetalType__c, Category__c
            FROM MetalCategoryConfig__mdt
        ];

        if (configs.isEmpty()) return;

        // Existing product price records
        Map<String, PriceReceiver__c> existing = new Map<String, PriceReceiver__c>();
        for (PriceReceiver__c p : [
            SELECT Id, Product_Code__c
            FROM PriceReceiver__c
        ]) {
            existing.put(p.Product_Code__c, p);
        }

        List<PriceReceiver__c> toUpsert = new List<PriceReceiver__c>();

        for (MetalCategoryConfig__mdt cfg : configs) {

            List<ProductData> products =
                fetchProducts(cfg.MetalType__c, cfg.Category__c);

            for (ProductData p : products) {

                PriceReceiver__c rec =
                    existing.containsKey(p.productCode)
                    ? existing.get(p.productCode)
                    : new PriceReceiver__c(Product_Code__c = p.productCode);

                rec.Buy_Price__c = p.buyPrice;
                rec.Sell_Price__c = p.sellPrice;
                rec.Available_Qty__c = p.activeBuy;

                toUpsert.add(rec);
            }
        }

        upsert toUpsert Product_Code__c;
    }

    // Calls external trading product API
    private static List<ProductData> fetchProducts(String metalType, String category) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(new Map<String,String>{
            'metalType' => metalType,
            'category' => category
        }));

        HttpResponse res = new Http().send(req);

        Map<String,Object> result =
            (Map<String,Object>)((Map<String,Object>)
            JSON.deserializeUntyped(res.getBody())).get('result');

        List<ProductData> list = new List<ProductData>();

        for (String code : result.keySet()) {
            Map<String,Object> item = (Map<String,Object>) result.get(code);

            ProductData p = new ProductData();
            p.productCode = code;
            p.buyPrice = Decimal.valueOf(item.get('buyPrice').toString());
            p.sellPrice = Decimal.valueOf(item.get('sellPrice').toString());
            p.activeBuy = Decimal.valueOf(item.get('activeBuy').toString());

            list.add(p);
        }

        return list;
    }

    // Lightweight DTO
    public class ProductData {
        public String productCode;
        public Decimal buyPrice;
        public Decimal sellPrice;
        public Decimal activeBuy;
    }
}
