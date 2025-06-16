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

