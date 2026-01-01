import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/TradingProductController.getProducts';
import getSpotPrices from '@salesforce/apex/SpotPriceService.getSpotPrices';
import { refreshApex } from '@salesforce/apex';

export default class TradingTerminal extends LightningElement {

    products;
    error;
    spotPrices = [];
    wiredResult;
    refreshInterval;
    spotPriceInterval;

    @wire(getProducts)
    wiredProducts(result) {
        this.wiredResult = result;
        const { data, error } = result;

        if (data) {
            const grouped = {};

            data.forEach(record => {
                const category = record.Category__c || 'Uncategorized';
                const subcategory = record.SubCategory__c || null;
                const isActive = record.Is_Tradable__c === true;
                const isCut = record.Available_Qty__c === 0;

                if (!grouped[category]) {
                    grouped[category] = {};
                }

                const subKey = subcategory || '__no_sub__';

                if (!grouped[category][subKey]) {
                    grouped[category][subKey] = {
                        label: subcategory,
                        records: []
                    };
                }

                grouped[category][subKey].records.push({
                    ...record,
                    highlightClass: isActive ? 'green-cell' : '',
                    nameClass: `${isActive ? 'green-cell' : ''} ${isCut ? 'cut-text' : ''}`.trim()
                });
            });

            const tierOrder = label => {
                if (!label) return 99;
                if (label.includes('High')) return 1;
                if (label.includes('Mid')) return 2;
                return 99;
            };

            const categoryOrder = ['SILVER PREMIUM', 'GOLD PREMIUM', 'SILVER BULLION', 'GOLD BULLION'];

            this.products = Object.entries(grouped)
                .sort((a,b) => (categoryOrder.indexOf(a[0].toUpperCase()) || 99) - (categoryOrder.indexOf(b[0].toUpperCase()) || 99))
                .map(([category, subcats]) => ({
                    category,
                    subcategories: Object.entries(subcats)
                        .sort((a,b) => tierOrder(a[0]) - tierOrder(b[0]))
                        .map(([key, val]) => ({
                            subcategory: val.label,
                            showSubcategory: !!val.label,
                            records: val.records
                        }))
                }));

            this.error = undefined;
        } else {
            this.error = error;
            this.products = undefined;
        }
    }

    get formattedSpotPrices() {
        return (this.spotPrices || []).map(m => {
            const isPositive = m.change >= 0;
            return {
                metal: m.metal,
                bid: m.bid,
                ask: m.ask,
                changeClass: isPositive ? 'positive-change' : 'negative-change',
                changeSymbol: isPositive ? '▲' : '▼',
                changeAbs: m.change,
                changePercentAbs: m.changePercent
            };
        });
    }

    connectedCallback() {
        this.fetchSpotPrices();

        this.refreshInterval = setInterval(() => {
            if (this.wiredResult) {
                refreshApex(this.wiredResult);
            }
        }, 30000);

        this.spotPriceInterval = setInterval(() => {
            this.fetchSpotPrices();
        }, 5 * 60 * 1000);
    }

    disconnectedCallback() {
        clearInterval(this.refreshInterval);
        clearInterval(this.spotPriceInterval);
    }

    fetchSpotPrices() {
        getSpotPrices()
            .then(data => { this.spotPrices = data; })
            .catch(() => { this.spotPrices = []; });
    }
}
