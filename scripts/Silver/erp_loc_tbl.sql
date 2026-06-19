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
