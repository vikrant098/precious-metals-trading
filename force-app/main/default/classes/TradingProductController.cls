public with sharing class TradingProductController {

    /**
     * Returns tradable products for the trading terminal.
     * Data is normally populated by ProductFeedService via callouts.
     */
    @AuraEnabled(cacheable=true)
    public static List<TradingProductDTO> getProducts() {

        List<Product2> products = [
            SELECT Id, Name, ProductCode,
                   Price__c,
                   Category__c,
                   SubCategory__c,
                   Tier__c,
                   Available_Qty__c,
                   Is_Tradable__c
            FROM Product2
            WHERE Category__c != null
        ];

        List<TradingProductDTO> result = new List<TradingProductDTO>();

        for (Product2 p : products) {
            result.add(new TradingProductDTO(p));
        }

        return result;
    }

    // Lightweight DTO for LWC
    public class TradingProductDTO {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductCode;
        @AuraEnabled public Decimal Price__c;
        @AuraEnabled public String Category__c;
        @AuraEnabled public String SubCategory__c;
        @AuraEnabled public String Tier__c;
        @AuraEnabled public Decimal Available_Qty__c;
        @AuraEnabled public Boolean Is_Tradable__c;

        public TradingProductDTO(Product2 p) {
            Id = p.Id;
            Name = p.Name;
            ProductCode = p.ProductCode;
            Price__c = p.Price__c;
            Category__c = p.Category__c;
            SubCategory__c = p.SubCategory__c;
            Tier__c = p.Tier__c;
            Available_Qty__c = p.Available_Qty__c;
            Is_Tradable__c = p.Is_Tradable__c;
        }
    }
}
