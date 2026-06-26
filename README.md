# sql-ware-house
# SQL Data Warehouse Project

A PostgreSQL data warehouse built using the **Medallion Architecture** (Bronze, Silver, Gold layers), following data engineering best practices with stored procedures and a star schema design for analytics.

##  Architecture

- **Bronze Layer** — Raw data ingested as-is from source systems
- **Silver Layer** — Cleaned, standardized, and business-rule-applied data
- **Gold Layer** — Business-ready data modeled as a star schema (fact & dimension tables) for reporting and analytics

## 📂 Repository Structure

```
sql-ware-house/
├── dataset/     # Source data used to populate the warehouse
├── docs/        # Documentation, diagrams, and notes
├── scripts/     # SQL scripts and stored procedures (Bronze/Silver/Gold)
├── test/        # Data quality and validation checks
└── README.md
```

##  Tech Stack

- PostgreSQL
- PL/pgSQL (stored procedures)

##  How to Use

1. Clone the repo
2. Set up a PostgreSQL database
3. Run the scripts in order: Bronze → Silver → Gold
4. Explore the Gold layer star schema for analytics
   
## Learning Goals
-Strengthen SQL fundamentals
-Practice real-world data engineering workflows
-Build recruiter-ready portfolio projects

##  Credits

This project follows the data warehouse methodology taught by **Data With Baraa**github.com/DataWithBaraa. Big thanks for the clear, structured approach to building a real-world data warehouse from scratch.

## 📄 License

This project is licensed under the MIT License.
