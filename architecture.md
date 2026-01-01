# Precious Metals Trading Platform – Architecture

This document describes how the real-time precious metals trading platform is built on Salesforce.

---

## High Level System

External Market Data API (Spot Prices)
↓
Apex Callout
↓
PriceReceiver__c (Custom Object)
↓
LWC Trading Terminal
↓
Live Bid / Ask / Change

External Product Feed (Premiums & Inventory)
↓
Apex Callout
↓
Product2 Records
↓
Tiered Product Sheet

---

The trading terminal combines **two independent live feeds**:
- Market prices (Gold, Silver, Platinum, Palladium)
- Tradable products with premiums and availability

---

## Data Flow

### 1️⃣ Market Price Feed
A scheduled Apex job calls the external market data API to fetch:
- Bid
- Ask
- Price change
- Change percentage

This data is stored in `PriceReceiver__c`.

---

### 2️⃣ Product Feed
Another Apex callout fetches:
- Product codes
- Buy / sell prices
- Premiums
- Inventory

These are stored in `Product2` and related custom objects.

---

### 3️⃣ Lightning Web Component
The LWC trading terminal:
- Reads live prices from `PriceReceiver__c`
- Reads tradable products from `Product2`
- Displays tiered product groups
- Highlights tradable vs sold-out products
- Refreshes automatically during trading hours

---

## Why this Architecture

This design is used in:
- Bullion trading platforms
- Crypto exchanges
- FX desks
- Commodity markets

It provides:
- Real-time updates
- High reliability
- Separation between market data and products
- Scalable enterprise architecture

---

## Key Design Principles

- Market data and product data are independent
- All external systems are integrated via Apex callouts
- Data is cached in Salesforce for fast UI rendering
- LWC provides high-performance real-time UI
- Schedulers keep prices fresh during trading hours

---

This architecture allows Salesforce to function as a **real trading platform**, not just a CRM.
