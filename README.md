# Data Warehouse and Data Analysis Project

This project demonstrates a comprehensive data warehousing and analytics solution,from building a data warehouse to generating actionable insights.

---
---
## Project Overview

This project involves:

- **Data Architecture:** Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
- **ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.
- **Data Modeling:** Developing fact and dimension tables optimized for analytical queries.
- **Analytics & Reporting:** Creating SQL-based reports and **PowerBI dashboards** for actionable insights.

The dataset used for the projects originally constitutes of six different tables, belonging to two different source systems:

```
dataset/
|
├── source_crm/                           # Data-source for Customer Relationship Management(CRM)
│   ├── cust_info.csv                     # Customer information
│   ├── prd_info.csv                      # Information about current and history products
│   ├── sales_details.csv                 # Transactional records about sales and orders
│
├── source_erp/                           # Data-source for Enterprise Resource Planning(ERP)
│   ├── CUST_AZ12.csv                     # Additional Customer info
│   ├── LOC_A101.csv                      # Location info of Customers
│   ├── PX_CAT_G1V2.csv                   # Product Categories info
|
```

<p align="left">
  <img src="docs/DataIntegrationModel.png" width = "70%" />
</p>

---
---
## Project Requirements

### 1. Building the Data Warehouse

#### 1.1 Objective 

Develope a modern data warehouse using SQL Server to consolidate sales data,enabling analytics and informed decision-making.

#### 1.2 Data Warehouse Architecture

![Data Warehouse Architecture](docs/DataWarehouseArchitecture.png)

<br>

- **Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
- **Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
- **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.

---
#### 1.3 Specifications

- **Data Sources:** Import Data from two source systems:**ERP**(*Enterprise Resource Planning*) & **CRM**(*Customer Relationship Management*),that are provided as CSV files
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis
- **Integration:** Combine both sources into single, user-friendly data model designed for analytical queries.

![Data Flow Diagram](docs/DataFlowDiagram.png)

---
### 2. Analytics & Reporting

#### 2.1 Objective

Develope comprehensive collection of SQL scripts for data exploration, analytics, and reporting. These scripts cover various analyses such as database exploration, measures and metrics, time-based trends, cumulative analytics, segmentation, and more to deliver detailed insights into:
- Customer Behaviour
- Product Performance
- Sales Trends

#### 2.2 Data Analysis

We have already created views in the gold layer : **dim_customers,dim_products,dim_fact_sales**. These three will be used to perform the following tasks:
1. **Exploratory Data Analysis**
2. **Advanced Data Analysis**
3. Creating **Report Views** for **dashborading**.

Any column can be categories as a **Measure** or **Dimesnion**. 
- Is it numeric ? YES. Does it make sense to aggregate it ? YES
- Hence you have found a measure,evrything else is a Dimension.

**Explortary Data Analysis** <br>

The data contains order over 37 months between dates : 2010-12-29 to 2014-01-28.
There are **18,484 customers** fo our business. <br>
Male and female customers are almost 9300 and 9100 respectively, somewhat equal contribution. <br>
The customers belong to six different countries,while there are few customers whose country of origin is unknown. <br>

| Country | Count | Country | Count |
|---------|-------|---------|-------|
| USA | 7482 | Germany | 1780 |
| Australia | 3591 | Canada | 1571 |
| UK | 1913 | n/a | 337 |
| France | 1810 |  |  |

The Top-5 customers who have generated the highest revenue:

| Customer Name | Total Expenditure |
|---------------|-------------------|
| Katlyn Henderson | 13294 |
| Nichole Nara | 13294 |
| Margaret He | 13268 |
| Randall Dominguez | 13265 |
| Maurice Shan | 13242 |

The youngest and oldest customer of our business are aged 39 and 109 years respectively. <br>

| Number of Orders | Number of Customers |
|-----------------|-----------------|
| 1 | 11619 |
| 2 | 1254 |
| 3 | 1166 |
| 4 | 150 |
| 5 | 51 |
|>5 |44 |

There are ~ 11.6K customers who have placed an order only once. The number of two and three time customers is similar but drops rapidly for orders greater than three.

There are mainly four categories for the business: **Accessories,Bikes,Clothing** and **Components**. <br> There are 295 different types of products that are being sold across category. <br>
Category wise distribution is as follows:

| Category | Total Nr Products | Average Cost |Total Sales (Volume)| Total Revenue($) |
|----------|-------------------| -------------|--------------------|---------------|
| Components | 127 | 264 | - | - |
| Bikes | 97 | 343 | 15205 | ~ 28.3 M |
| Clothing | 35 | 24 |9101| ~340K |
| Accessories | 29 | 13 |36092| ~ 700K |


- Components have the maximum number of products but during this period,not a single product from this category has been sold.
- Bikes are the costliest items on average, and they have produced the majority of the revenue (close to **96%** ).
- Clothing and Accessories have a small spectrum of cheaper products to offer.
- Accessories are the most sold out item,neaarly double than bikes. But since they are on avg cheaper,they don't contribute anything major to the revenue.

| Best Performing Products | Revenue | Worst Performing Products | Revenue |
|-------------------------|---------|---------------------------|---------|
| Mountain-200 Black- 46 | 1373454 | Racing Socks- M | 2430 |
| Mountain-200 Black- 42 | 1361312 | Sport-100 Helmet- M | 282 |
| Mountain-200 Silver- 38 | 1339394 | Patch Kit/8 Patches | 6382 |
| Mountain-200 Silver- 46 | 1301029 | Bike Wash - Dissolver | 7272 |
| Mountain-200 Black- 38 | 1284954 | Touring Tire Tube | 7440 |

The abover table contains the best and wprst performing products respectively. <br>
Top 5 products are all bikes,different specs of *Mountain-200* .





#### 2.3 Sales Performance Dashboard

![PowerBI Dashboard](docs/Dashboard.png)

---
---
## Repository Structure

```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```

