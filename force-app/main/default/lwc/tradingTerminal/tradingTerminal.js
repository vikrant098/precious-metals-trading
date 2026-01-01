import { LightningElement, wire } from 'lwc';
import getSpotPrices from '@salesforce/apex/SpotPriceService.getSpotPrices';
import getProducts from '@salesforce/apex/ProductController.getProducts';

export default class TradingTerminal extends LightningElement {
    spotPrices = [];
    products;

    @wire(getSpotPrices)
    wiredSpot({ data }) {
        if (data) this.spotPrices = data;
    }

    @wire(getProducts)
    wiredProducts({ data }) {
        if (data) this.products = data;
    }
}
