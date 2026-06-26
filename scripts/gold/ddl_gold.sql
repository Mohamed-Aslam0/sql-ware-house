---------------------------------------------------------------
-- dim_customers
-- Purpose: Creates a dimension view of customers enriched with
-- demographic and geographic attributes. This supports customer
-- segmentation, lifetime value analysis, and demographic reporting
-- in the Gold Layer.
---------------------------------------------------------------
               --dim_customers
---------------------------------------------------------------

create view gold.dim_customers as

SELECT row_number() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    lo.cntry AS country,
    ci.cst_marital_status AS marital_status,
        CASE
            WHEN ci.cst_gndr::text <> 'n/a'::text THEN ci.cst_gndr
            ELSE COALESCE(ca.gen, 'n/a'::character varying)
        END AS genter,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
   FROM silver.crm_cust_info ci
     LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key::text = ca.cid::text
     LEFT JOIN silver.erp_loc_a101 lo ON ci.cst_key::text = lo.cid::text;

------------------------------------------------------
             --dim_product
------------------------------------------------------
create view gold.dim_product as

SELECT
    row_number() over( order by pn.PRD_START_DT ,pn.PRD_ID) as product_key,
	pn.PRD_ID AS product_id,
	pn.PRD_KEY AS product_number,
	pn.PRD_NM As product_name,
	pn.CAT_ID category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance,
	
	pn.PRD_COST as product_cost,
	pn.PRD_LINE as product_line,
	pn.PRD_START_DT as start_date
	
FROM
	SILVER.CRM_PRD_INFO pn
	left join silver.erp_px_cat_g1v2 pc
	on pn.cat_id = pc.id
	where prd_end_dt is null;

-------------------------------------------------
              --fact_sales
-------------------------------------------------
create view gold.fact_sales as
SELECT
	SLS_ORD_NUM AS order_number,
	pr.product_key,
	cu.customer_id,
	SLS_ORDER_DT AS order_date,
	SLS_SHIP_DT AS shipping_date,
	SLS_DUE_DT AS due_date,
	SLS_SALES AS sales,
	SLS_QUANTITY as quantity,
	SLS_PRICE as price
FROM
	SILVER.CRM_SALES_DETAILS sl
	left join gold.dim_product PR
	on sl.sls_prd_key= pr.product_number
    left join gold.dim_customers CU
	on sl.sls_cust_id = cu.customer_id;
