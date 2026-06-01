-- =====================================================
-- BRONZE LAYER - ETL Procedure Script
-- =====================================================
-- Purpose   : Load raw source data into Bronze layer tables
-- Author    : Mohamed Aslam P
-- Description:
--   This procedure truncates Bronze layer staging tables
--   and reloads them from CSV source files. It logs start
--   and end times, and calculates total load duration.
-- Usage:
--   CALL bronze.load_bronze();
-- Notes:
--   - Paths are Windows-based (use forward slashes for portability).
--   - RAISE NOTICE used for logging; consider audit tables for production.
-- =====================================================

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql AS $$
DECLARE
    v_start_time TIMESTAMPTZ := clock_timestamp(); -- Batch start time
    v_end_time   TIMESTAMPTZ;                      -- Batch end time
BEGIN
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Starting Bronze Layer Load at %', v_start_time;
    RAISE NOTICE '====================================';

    -- CRM Customer Info Load
    RAISE NOTICE 'TRUNCATE : bronze.crm_cust_info';
    TRUNCATE bronze.crm_cust_info RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM 'D:/ware_house_dataset/source_crm/cust_info.csv'
    DELIMITER ',' CSV HEADER;

    -- CRM Product Info Load
    RAISE NOTICE 'TRUNCATE : bronze.crm_prd_info';
    TRUNCATE bronze.crm_prd_info RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM 'D:/ware_house_dataset/source_crm/prd_info.csv'
    DELIMITER ',' CSV HEADER;

    -- CRM Sales Details Load
    RAISE NOTICE 'TRUNCATE : bronze.crm_sales_details';
    TRUNCATE bronze.crm_sales_details RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM 'D:/ware_house_dataset/source_crm/sales_details.csv'
    DELIMITER ',' CSV HEADER;

    -- ERP Customer Master (AZ12) Load
    RAISE NOTICE 'TRUNCATE : bronze.erp_cust_az12';
    TRUNCATE bronze.erp_cust_az12 RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM 'D:/ware_house_dataset/source_erp/CUST_AZ12.csv'
    DELIMITER ',' CSV HEADER;

    -- ERP Location Master (A101) Load
    RAISE NOTICE 'TRUNCATE : bronze.erp_loc_a101';
    TRUNCATE bronze.erp_loc_a101 RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM 'D:/ware_house_dataset/source_erp/LOC_A101.csv'
    DELIMITER ',' CSV HEADER;

    -- ERP Product Category Master (PX_CAT_G1V2) Load
    RAISE NOTICE 'TRUNCATE : bronze.erp_px_cat_g1v2';
    TRUNCATE bronze.erp_px_cat_g1v2 RESTART IDENTITY;
    RAISE NOTICE 'INSERT INTO : bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM 'D:/ware_house_dataset/source_erp/PX_CAT_G1V2.csv'
    DELIMITER ',' CSV HEADER;

    -- Capture end time and log duration
    v_end_time := clock_timestamp();
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Bronze Layer Load Completed at %', v_end_time;
    RAISE NOTICE 'Total Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));
    RAISE NOTICE '====================================';
END;
$$;

-- Execute procedure
CALL bronze.load_bronze();
