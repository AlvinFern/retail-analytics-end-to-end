# 🛍️ Verve Retail Co. — End-to-End Retail Analytics Project

## 📌 Project Overview

Verve Retail Co. is a mid-sized American lifestyle retail chain operating **14 physical stores** across the U.S. and a growing online channel. This project delivers a full end-to-end business analytics review covering **3 years of transaction data (2022–2024)**, addressing three critical business problems identified by leadership ahead of their 2025 expansion cycle.

The dataset was **synthetically generated using AI** to simulate realistic retail operations — including customer transactions, store performance, inventory levels, and return records — making this a fully self-contained analytics project built from the ground up.

> 📁 This repository contains all SQL queries, Power BI dashboards, and written reports produced across three analytical workstreams.

---

## 🏢 Company Background

| Attribute | Detail |
|---|---|
| HQ | New York City |
| Founded | 2017 |
| Store Network | 14 physical stores + 1 online channel |
| Target Customer | Urban professionals aged 25–45 |
| Product Categories | Electronics, Clothing, Home & Kitchen, Beauty & Personal Care, Sports & Outdoors |
| Regional Divisions | Northeast, West, South, Southeast, Midwest |
| Suppliers | 12 |
| Analysis Period | January 2022 – December 2024 |

---

## ❗ Business Problems

Leadership identified three growing concerns ahead of 2025 planning:

**1. Rising Return & Refund Rates**
Customer returns had been climbing steadily, cutting into net revenue. The operations team suspected product quality and fulfilment issues but lacked the data visibility to confirm root causes or quantify financial impact.

**2. Uneven Store Performance & Inventory Misalignment**
Several regional stores were underperforming despite high-population locations. Simultaneously, inventory was piling up in some stores while others faced stockout risk — pointing to poor demand forecasting across the network.

**3. Shifting Customer Base & Loyalty Concerns**
A growing share of revenue was concentrated in a small group of high-value repeat customers, while a large segment had only purchased once and never returned. Without a clear segmentation view, Verve couldn't design targeted retention strategies.

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|---|---|
| **MySQL** | Data extraction, transformation, and business question answering |
| **Microsoft Excel** | Data cleaning, pivot analysis, and preliminary exploration |
| **Power BI** | Interactive dashboards and executive-facing visualisations |

---

## 📊 Key Findings

### 💰 Revenue & Profitability

- **$1.76M** total revenue across 2022–2024
- Revenue peaked at **$624K in 2023 (+13.9%)** before declining **5.6% in 2024**
- Profit margin held steady at **74–75%** — the 2024 decline is a **demand and retention problem, not a cost problem**

### 🔄 Problem 1 — Returns & Refunds

- **18.1% average return rate** across all 3 years
- **$385K lost to refunds** — 22% of potential revenue
- **Electronics** was the biggest offender at **$164K** in refunds (18.7% of its potential revenue)
- No single dominant return reason — spread evenly across 9 categories, pointing to a broad operational challenge
- E-Commerce had the highest return rate at **20%**; Flagship stores the lowest at **16%**

### 🏪 Problem 2 — Store Performance & Inventory

- **Manhattan Flagship** leads the network in both revenue and profit — sets the performance benchmark
- **Chicago Loop, Dallas Premium, and Atlanta Peachtree** are bottom-quartile performers requiring operational review
- **Online store is Verve's only growing channel** (+9% in 2023, +4.7% in 2024) while physical store revenue is declining
- **430 products severely overstocked** (stock > 3× reorder level)
- **5 products at immediate stockout or critical risk**, including UltraBook 15

### 👥 Problem 3 — Customer Segmentation (RFM Analysis)

- **499 active customers** analysed across 4 RFM segments
- **Only 9 Loyal Customers** out of 499 (1.8% of the base)
- **197 Potential Loyalists** identified — the single biggest retention opportunity in the dataset
- **Premium segment** (61 customers): highest CLV at $11,823 and AOV of $780 — highest value, highest risk if lost
- **20%+ of every customer segment** has gone quiet (6–12 months inactive) — a network-wide retention issue, not segment-specific

---

## 📋 Recommendations

| Priority | Action | Timeline |
|---|---|---|
| 🔴 Immediate | Restock 5 critical/stockout products (incl. UltraBook 15) | Now |
| 🔴 Immediate | Launch structured loyalty programme — 197 Potential Loyalists to convert | Now |
| 🟡 Q1 2025 | Fix shipping & packaging — damaged shipping is the #1 return reason (14%) | Q1 2025 |
| 🟡 Q1 2025 | Mandate return reason capture — 12% of returns have no reason logged | Q1 2025 |
| 🟡 Q1 2025 | Operational review of Chicago Loop, Dallas Premium & Atlanta Peachtree | Q1 2025 |
| 🟡 Q1 2025 | Create exclusive loyalty tier for the 61 Premium customers (CLV $11,823) | Q1 2025 |
| 🟢 Q2 2025 | Win-back campaign for 20%+ lapsing customers across all segments | Q2 2025 |
| 🟢 Q2 2025 | Invest in online channel — growth slowing from 9% → 4.7% | Q2 2025 |
| 🟢 Q2 2025 | Competitive pricing review for Electronics — 11% of returns cite better price elsewhere | Q2 2025 |

---

## 📸 Dashboard Preview

**Executive Summary Dashboard**
<img width="1187" height="664" alt="Screenshot 2026-08-19 202021" src="https://github.com/user-attachments/assets/24c85987-d360-45d4-b09d-4c334f31952b" />

**Returns & Refunds Dashboard**
<img width="1202" height="676" alt="image" src="https://github.com/user-attachments/assets/1431a243-3f50-450b-9a22-66209020ba79" />

**Store Performance Dashboard**
<img width="1191" height="669" alt="image" src="https://github.com/user-attachments/assets/450de5b2-2d3d-4f0c-919c-acf5b6601daf" />

**Customer Segmentation Dashboard**
<img width="1193" height="671" alt="image" src="https://github.com/user-attachments/assets/9d7776c2-c53c-4d9f-8962-1692ec5f53d8" />


---

## 💡 Skills Demonstrated

- **Data Generation** — Used AI to produce a realistic, multi-table retail dataset
- **Data Cleaning & Preparation** — Structured raw data for analysis in Excel and MySQL
- **SQL** — Complex queries across joined tables, aggregations, window functions, CTEs
- **RFM Analysis** — Customer segmentation using Recency, Frequency, and Monetary scoring
- **Business Intelligence** — Built interactive Power BI dashboards for executive stakeholders
- **Storytelling with Data** — Translated raw findings into clear business recommendations
- **Report Writing** — Produced four structured analytical reports + an executive summary

---

## 👤 Author

**Alvin Fernandes**
📧 alvinfernandes2001@gmail.com
🔗 [GitHub Portfolio](https://github.com/AlvinFern?tab=repositories)











