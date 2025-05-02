

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '============================================';
		PRINT 'Loading the silver layer';
		PRINT '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE(); -- start time to the loading process
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,   -- Used trimming to remove unwanted spaces
			TRIM(cst_lastname) cst_lastname,
			CASE WHEN UPPER(cst_marital_status) ='M' THEN 'Married'
				WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
				ELSE 'n/a'						-- Handled missing values
			END cst_marital_status,				-- Normalise marital status values to readable format
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'						-- Handled missing values
			END cst_gndr,						-- Normalise gender values to readable format
			cst_create_date
		FROM (									-- Removed duplicates and NULL values for cst_id as it's our primary key
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1	;				-- Select the most recent record per customer
		SET @end_time = GETDATE();   -- end time to the loading process
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		PRINT '-------------------' 

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		/*
		IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
			DROP TABLE silver.crm_prd_info;

		CREATE TABLE silver.crm_prd_info (
			prd_id			INT,
			cat_id			NVARCHAR(50),
			prd_key			NVARCHAR(50),
			prd_nm			NVARCHAR(50),
			prd_cost		INT,
			prd_line		NVARCHAR(50),
			prd_start_dt	DATE,
			prd_end_dt		DATE,
			dwh_create_date DATETIME2 DEFAULT GETDATE()
		);
		*/

		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id,  -- new column: extract category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) prd_key,		 -- extract product key
			prd_nm,
			ISNULL(prd_cost,0) prd_cost,					 -- replaced NULL values with 0 
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,									 -- Map product line codes to descriptive values
			CAST(prd_start_dt AS DATE) prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1
				AS DATE
			) prd_end_dt									 -- Calculate end date as one dat brfore the next start date.
		FROM bronze.crm_prd_info;
		/*
		WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN 
		(SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details ); -- filters out unmatched product keys
		*/
		/*
		WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_') NOT IN 
		(SELECT DISTINCT ID FROM bronze.erp_px_cat_g1v2);  -- Filters out unmatched categories
		*/ 
		-- cat_id = CO_PE is missing in the bronze.erp_px_cat_g1v2 table
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		PRINT '-------------------' 

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		/*
		IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
			DROP TABLE silver.crm_sales_details;

		CREATE TABLE silver.crm_sales_details (
				[sls_ord_num] NVARCHAR(50)
			  ,[sls_prd_key] NVARCHAR(50)
			  ,[sls_cust_id] INT
			  ,[sls_order_dt] DATE
			  ,[sls_ship_dt] DATE
			  ,[sls_due_dt] DATE
			  ,[sls_sales] INT
			  ,[sls_quantity] INT
			  ,[sls_price] INT
			  ,[dwh_create_date] DATETIME2 DEFAULT GETDATE()
		);
		*/

		INSERT INTO silver.crm_sales_details (
			[sls_ord_num] 
			  ,[sls_prd_key] 
			  ,[sls_cust_id] 
			  ,[sls_order_dt] 
			  ,[sls_ship_dt] 
			  ,[sls_due_dt] 
			  ,[sls_sales] 
			  ,[sls_quantity] 
			  ,[sls_price] 
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL  -- Replaced the invalid dates with NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)			-- Convert INT -> DATE,can;t do it directly from INT -> DATE in SQL Server 
			END sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END sls_due_dt,
			CASE WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price <=0 OR sls_price IS NULL THEN sls_sales/NULLIF(sls_quantity,0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		PRINT '--------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------------------'; 

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE															-- Remove 'NAS' prefix if present 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END AS cid,
			CASE															-- Set future birthdates to NULL
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE															-- Normalise gender values and handle unknowns
				WHEN TRIM(UPPER(gen)) IN ('F','FEMALE') THEN 'Female'
				WHEN TRIM(UPPER(gen)) IN ('M','MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		PRINT '-------------------' 

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
		REPLACE(cid,'-','') AS cid,
		CASE
			WHEN TRIM(UPPER(cntry)) IN ('DE','GERMANY') THEN 'Germany'
			WHEN TRIM(UPPER(cntry)) IN ('US','USA','UNITED STATES') THEN 'United States'
			WHEN TRIM(UPPER(cntry)) IN ('UK','UNITED KINGDOM') THEN 'United Kingdom'
			WHEN TRIM(UPPER(cntry)) IN ('AU','AUSTRALIA') THEN 'Australia'
			WHEN TRIM(UPPER(cntry)) IN ('CN','CANADA') THEN 'Canada'
			WHEN TRIM(UPPER(cntry)) IN ('FR','FRANCE') THEN 'France'
			ELSE 'n/a'
		END AS cntry	--Normalise and handle the missing or blank country codes
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		PRINT '-------------------' 

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		SET @batch_end_time = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Silver Layer is completed';
		PRINT '		- Total load duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '=================================================';
	END TRY
	BEGIN CATCH	
		PRINT '============================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================================';
	END CATCH
END


