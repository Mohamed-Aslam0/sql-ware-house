/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to 
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.
        
Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL silver.load_silver();
===============================================================================
*/----------------------------------------------------
           -- crm_cus_info_table
----------------------------------------------------
CREATE OR REPLACE PROCEDURE silver.load_silver()
language plpgsql
As $$
DECLARE 
v_start_time  TIMESTAMP;
v_end_time  TIMESTAMP;
v_batch_start  timestamp;
v_batch_end  TIMESTAMP;
BEGIN 
V_batch_start := clock_timestamp();
RAISE NOTICE '==========================================';
RAISE NOTICE '----------Loading Silver layer------------';
RAISE NOTICE '==========================================';

-----------------------------------------------------------
                   --CRM_CUS_TABLE
-----------------------------------------------------------
V_START_TIME := CLOCK_TIMESTAMP();
RAISE NOTICE '>>>TRUNCATING TABLE SILVER.crm_prd_info<<<';
TRUNCATE TABLE silver.crm_cust_info;
RAISE NOTICE '>>>INSERTING TABLE<<<';

INSERT INTO
	SILVER.CRM_CUST_INFO (
		CST_ID,
		CST_KEY,
		CST_FIRSTNAME,
		CST_LASTNAME,
		CST_GNDR,
		CST_MARITAL_STATUS,
		CST_CREATE_DATE
	)
SELECT
	CST_ID,
	CST_KEY,
	TRIM(CST_FIRSTNAME) AS CST_FIRSTNAME,
	TRIM(CST_LASTNAME) AS CST_LASTNAME,
	CASE
		WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'MARRIED'
		WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'SINGLE'
		ELSE 'N/A'
	END CST_MARITAL_STATUS,
	CASE
		WHEN UPPER(TRIM(CST_GNDR)) = 'M' THEN 'MALE'
		WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'FEMALE'
		ELSE 'N/A'
	END CST_GNDR,
	CST_CREATE_DATE
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					CST_ID
				ORDER BY
					CST_CREATE_DATE DESC
			) AS FLAG_LAST
		FROM
			BRONZE.CRM_CUST_INFO
            WHERE cst_id IS NOT NULL
	) T
WHERE
	FLAG_LAST = 1;
v_end_time := clock_timestamp();
RAISE NOTICE'>>> LOAD DURATION : % secounds', extract (EPOCH from (v_end_time - v_start_time));
----------------------------------------------------------
               -- crm_prd_info_table
----------------------------------------------------------
V_start_time := clock_timestamp();
TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO
	SILVER.CRM_PRD_INFO (
		PRD_ID,
		PRD_KEY,
		CAT_ID,
		PRD_NM,
		PRD_COST,
		PRD_LINE,
		PRD_START_DT,
		PRD_END_DT
	)
SELECT
	PRD_ID,
	REPLACE(SUBSTRING(PRD_KEY FROM 1 FOR 5),'-','_') AS cat_id,
	substring(prd_key from 7 ) as prd_key,
	PRD_NM,
	COALESCE (PRD_COST, 0) AS PRD_COST,
	CASE  UPPER(TRIM(PRD_LINE))
	WHEN'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'Other sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'N/A'
	END AS PRD_LINE,
	CAST(prd_start_dt AS DATE) AS PRD_START_DT,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE ) AS PRD_END_DT
FROM
	BRONZE.CRM_PRD_INFO;
	v_end_time := clock_timestamp();
RAISE NOTICE 'Load DURATION : % secounds ', extract (EPOCH FROM (V_END_TIME - V_START_TIME));
-----------------------------------------------------
           -- CRM_SALES_DETAILS_TABLE
-----------------------------------------------------
V_START_TIME := CLOCK_TIMESTAMP();

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num, sls_prd_key, sls_cust_id,
    sls_order_dt, sls_ship_dt, sls_due_dt,
    sls_sales, sls_quantity, sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 
            THEN NULL
        ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD') 
    END,
    CASE 
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 
            THEN NULL
        ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD') 
    END,
    CASE 
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 
            THEN NULL
        ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD') 
    END,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales END,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price END
FROM bronze.crm_sales_details;
V_END_TIME := CLOCK_TIMESTAMP();
RAISE NOTICE 'Load Duration : % secounds', EXTRACT(EPOCH FROM (V_END_TIME - V_START_TIME));
RAISE NOTICE '==========================================';
RAISE NOTICE '>>> LOADING ERP TABLES >>>';
RAISE NOTICE '==========================================';
------------------------------------------
           -- ERP_CUST_AZ12_TA
------------------------------------------

V_START_TIME:= CLOCK_TIMESTAMP();

TRUNCATE TABLE SILVER.erp_cust_az12;

INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
SELECT
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
         ELSE cid
    END AS cid,
    CASE WHEN bdate > CURRENT_DATE THEN NULL ELSE bdate END AS bdate,
    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         ELSE 'n/a'
    END AS gen
FROM
    BRONZE.ERP_CUST_AZ12
WHERE
    CID NOT IN (SELECT CST_key FROM silver.crm_cust_info);
V_END_TIME:= CLOCK_TIMESTAMP();
RAISE NOTICE 'Load Duration: % secouds',EXTRACT (EPOCH FROM(V_END_TIME - V_START_TIME));

----------------------------------------
       -- ERP_LOC_A101_TABLE
----------------------------------------
v_start_time:= clock_timestamp();

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101(cid,cntry)
SELECT
	REPLACE(CID, '-', ''),
	Case when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US','USA') THEN 'United States' 
	when trim(cntry) in ('null','') THEN 'n\\a'
	else cntry
	end as cntry
FROM
	BRONZE.ERP_LOC_A101;
v_end_time:= clock_timestamp();
RAISE NOTICE 'Load Duration: % secounds', EXTRACT(EPOCH FROM(v_end_time - v_start_time));

-------------------------------------------
            --ERP_PX_CAT_TABLE
-------------------------------------------
v_start_time:= clock_timestamp();

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2(ID,cat,subcat,maintenance)
SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
FROM
	BRONZE.ERP_PX_CAT_G1V2;
v_end_time:= clock_timestamp();
RAISE NOTICE 'Load Duration: % secounds', EXTRACT (EPOCH FROM (V_END_TIME - V_START_TIME));
------------------------------------------
          --BATCH_END
------------------------------------------

v_batch_end:= clock_timestamp();
RAISE NOTICE '===================================================';
RAISE NOTICE 'Loading_silver_layer_completed';
RAISE NOTICE '==========================================';
RAISE NOTICE 'TOT_Batch_load duration: % secounds',EXTRACT(EPOCH FROM (V_BATCH_END - V_BATCH_START));
RAISE NOTICE '====================================================';
exception when others THEN
raise notice '================================================';
raise notice 'ERROR OCCURING DURING LOADING';
RAISE NOTICE '==========================================';

end;
$$;






















































