-- Insert transformed records from BRONZE.ERP_CUST_AZ12 into silver.erp_cust_az12
-- Normalizes CID (removes NAS prefix), validates birthdate, and normalizes gender values

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
