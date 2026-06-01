-- =====================================================
-- BRONZE LAYER - DDL (Data Definition Language) Script
-- =====================================================
-- Purpose: Create and manage raw data ingestion tables in Bronze layer
-- Author: [Your Name]
-- Created: [YYYY-MM-DD]
-- Description: Stores raw data from source systems with minimal transformation
-- Usage: Execute to create Bronze layer table structures for data warehouse
-- =====================================================

-- Example template (uncomment and modify as needed):
-- CREATE TABLE IF NOT EXISTS bronze_<source>_<entity> (
--     id                  BIGINT,
--     raw_data            STRING,          -- Or individual columns as VARCHAR
--     load_timestamp      TIMESTAMP,       -- When the record was loaded
--     source_filename     STRING,          -- Track data source file
--     record_hash         STRING,          -- For change detection
--     ingestion_date      DATE             -- For partitioning
-- )
-- PARTITIONED BY (ingestion_date)
-- COMMENT 'Bronze layer table for <source> <entity> data';


