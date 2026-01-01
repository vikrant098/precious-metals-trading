public with sharing class SpotPriceService {

    // Uses Named Credential: MarketDataAPI
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSpotPrices() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketDataAPI');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = new Http().send(req);

        Map<String, Object> json =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Map<String, Object>> prices = new List<Map<String, Object>>();

        prices.add(buildMetal('Gold', json, 'gold'));
        prices.add(buildMetal('Silver', json, 'silver'));
        prices.add(buildMetal('Platinum', json, 'platinum'));
        prices.add(buildMetal('Palladium', json, 'palladium'));

        return prices;
    }

    private static Map<String,Object> buildMetal(String name, Map<String,Object> json, String key) {
        return new Map<String,Object>{
            'metal' => name,
            'bid' => json.get(key + 'Bid'),
            'ask' => json.get(key + 'Ask'),
            'change' => json.get(key + 'Change'),
            'changePercent' => json.get(key + 'ChangePercent')
        };
    }
}
