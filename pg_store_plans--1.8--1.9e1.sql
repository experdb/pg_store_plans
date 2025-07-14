/*
 * pg_store_plans/pg_store_plans--1.8--1.9e1.sql
 *
 * Upgrade script: pg_store_plans 1.8 -> 1.9e1
 *
 * - Drop existing functions and views
 * - Recreate functions with PostgreSQL version branching (17+/below)
 * - Create views and grant permissions
 */

-- Prevent direct execution in psql (only through CREATE EXTENSION)
\echo Use "CREATE EXTENSION pg_store_plans" to load this file. \quit

-- Drop existing views and functions
DROP VIEW pg_store_plans;
DROP FUNCTION pg_store_plans();

-- Create main function based on PostgreSQL version (17+/below branching)
DO
$$
BEGIN
    IF (SELECT split_part(setting,'.',1) FROM pg_settings WHERE name = 'server_version')::int >= 17 THEN
        -- PostgreSQL 17+: separate shared/local block time columns
        CREATE FUNCTION pg_store_plans(
            OUT userid oid,
            OUT dbid oid,
            OUT queryid int8,
            OUT planid int8,
            OUT plan text,
            OUT calls int8,
            OUT total_time float8,
            OUT min_time float8,
            OUT max_time float8,
            OUT mean_time float8,
            OUT stddev_time float8,
            OUT rows int8,
            OUT shared_blks_hit int8,
            OUT shared_blks_read int8,
            OUT shared_blks_dirtied int8,
            OUT shared_blks_written int8,
            OUT local_blks_hit int8,
            OUT local_blks_read int8,
            OUT local_blks_dirtied int8,
            OUT local_blks_written int8,
            OUT temp_blks_read int8,
            OUT temp_blks_written int8,
            OUT shared_blk_read_time float8,
            OUT shared_blk_write_time float8,
            OUT local_blk_read_time float8,
            OUT local_blk_write_time float8,
            OUT temp_blk_read_time float8,
            OUT temp_blk_write_time float8,
            OUT first_call timestamptz,
            OUT last_call timestamptz
        )
        RETURNS SETOF record
        AS 'MODULE_PATHNAME', 'pg_store_plans_1_9'
        LANGUAGE C
        VOLATILE PARALLEL SAFE;
    ELSE
        -- PostgreSQL 17 below: use blk_read_time, blk_write_time
        CREATE FUNCTION pg_store_plans(
            OUT userid oid,
            OUT dbid oid,
            OUT queryid int8,
            OUT planid int8,
            OUT plan text,
            OUT calls int8,
            OUT total_time float8,
            OUT min_time float8,
            OUT max_time float8,
            OUT mean_time float8,
            OUT stddev_time float8,
            OUT rows int8,
            OUT shared_blks_hit int8,
            OUT shared_blks_read int8,
            OUT shared_blks_dirtied int8,
            OUT shared_blks_written int8,
            OUT local_blks_hit int8,
            OUT local_blks_read int8,
            OUT local_blks_dirtied int8,
            OUT local_blks_written int8,
            OUT temp_blks_read int8,
            OUT temp_blks_written int8,
            OUT blk_read_time float8,
            OUT blk_write_time float8,
            OUT temp_blk_read_time float8,
            OUT temp_blk_write_time float8,
            OUT first_call timestamptz,
            OUT last_call timestamptz
        )
        RETURNS SETOF record
        AS 'MODULE_PATHNAME', 'pg_store_plans_1_7'
        LANGUAGE C
        VOLATILE PARALLEL SAFE;
    END IF;
END
$$ LANGUAGE plpgsql;

-- Create view for the main function
CREATE VIEW pg_store_plans AS
  SELECT * FROM pg_store_plans();

-- Grant SELECT permission to all users
GRANT SELECT ON pg_store_plans TO PUBLIC;
