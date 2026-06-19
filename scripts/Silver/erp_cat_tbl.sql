INSERT INTO silver.erp_px_cat_g1v2(ID,cat,subcat,maintenance)
SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
FROM
	BRONZE.ERP_PX_CAT_G1V2