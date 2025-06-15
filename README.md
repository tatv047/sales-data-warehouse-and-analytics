# Data Warehouse and Analytics Project

This project demonstrates a comprehensive data warehousing and analytics solution,from building a data warehouse to generating actionable insights.

---
---
## Project Overview

This project involves:

- **Data Architecture:** Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
- **ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.
- **Data Modeling:** Developing fact and dimension tables optimized for analytical queries.
- **Analytics & Reporting:** Creating SQL-based reports and **PowerBI dashboards** for actionable insights.

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
- **Integration:** Combine both sources into single,user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only;historisation of data isn't required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

<p align="left">
  <img src="docs/DataFlowDiagram.png" width="500" height="320" />
  <img src="docs/DataIntegrationModel.png" width="500" height="320" />
</p>

---
### 2. Analytics & Reporting

#### 2.1 Objective

Develope comprehensive collection of SQL scripts for data exploration, analytics, and reporting. These scripts cover various analyses such as database exploration, measures and metrics, time-based trends, cumulative analytics, segmentation, and more to deliver detailed insights into:
- Customer Behaviour
- Product Performance
- Sales Trends

These insights empower stakeholders with key business metrics enabling strategic decision making 

