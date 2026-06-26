 -- select * from silver.crm_prd_info;
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
	substring(prd_key from 7 ) as prd_key,
	REPLACE(SUBSTRING(PRD_KEY FROM 1 FOR 5),'-','_') AS cat_id,
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


