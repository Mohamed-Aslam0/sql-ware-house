-- =====================================================
-- BRONZE LAYER - DDL (Data Definition Language) Script
-- =====================================================
-- Purpose: Create raw ingestion tables in the Bronze layer
-- Author: MOHAMED ASLAM P
-- Description: Stores raw data from source systems with minimal transformation
-- Usage: Execute to create Bronze layer table structures for the data warehouse
-- =====================================================

-- ERP Customer Master (AZ12) - Stores basic customer details from ERP system
CREATE TABLE BRONZE.ERP_CUST_AZ12(
    CID    VARCHAR(50),  
    BDATE  DATE,         
    GEN    VARCHAR(20)    
);

-- ERP Location Master (A101) - Stores customer location and country information
CREATE TABLE BRONZE.ERP_LOC_A101(
    CID    VARCHAR(20),   
    CNTRY  VARCHAR(30)   
);

-- ERP Product Category Master (G1V2) - Stores product category and subcategory details
CREATE TABLE BRONZE.ERP_PX_CAT_G1V2(
    ID           VARCHAR(20),  
    CAT          VARCHAR(30), 
    SUBCAT       VARCHAR(30), 
    MAINTENANCE  VARCHAR(10)   
);

-- CRM Customer Info - Stores customer profile and demographic details from CRM system
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,         
    cst_key             VARCHAR(50), 
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50), 
    cst_marital_status  VARCHAR(50),  
    cst_gndr            VARCHAR(50), 
    cst_create_date     DATE         
);

-- CRM Product Info - Stores product details, cost, and lifecycle dates
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,          
    prd_key      VARCHAR(50),  
    prd_nm       VARCHAR(50),  
    prd_cost     INT,         
    prd_line     VARCHAR(50),  
    prd_start_dt DATE,        
    prd_end_dt   DATE          
);

-- CRM Sales Details - Stores transactional sales data including orders, shipping, and pricing
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),  
    sls_prd_key  VARCHAR(50),  
    sls_cust_id  INT,        
    sls_order_dt INT,    
    sls_ship_dt  INT,          
    sls_due_dt   INT,         
    sls_sales    INT,         
    sls_quantity INT,          
    sls_price    INT          
);
