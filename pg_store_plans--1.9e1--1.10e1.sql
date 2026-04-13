/*
 * pg_store_plans/pg_store_plans--1.9e1--1.10e1.sql
 *
 * Upgrade script: pg_store_plans 1.9e1 -> 1.10e1
 *
 * - Rebind pg_store_plans function to the 1.10 C entry points
 *   (CREATE OR REPLACE to preserve dependent objects on the view)
 */

-- Prevent direct execution in psql (only through ALTER EXTENSION UPDATE)
\echo Use "ALTER EXTENSION pg_store_plans UPDATE" to load this file. \quit

-- Rebind pg_store_plans() to the new 1.10 C entry points.
-- Use CREATE OR REPLACE so the existing view and any user-defined
-- dependents (views, functions) remain intact.
DO
$$
BEGIN
    IF (SELECT split_part(setting,'.',1) FROM pg_settings WHERE name = 'server_version')::int >= 17 THEN
        -- PostgreSQL 17+: separate shared/local block time columns
        CREATE OR REPLACE FUNCTION pg_store_plans(
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
        AS 'MODULE_PATHNAME', 'pg_store_plans_1_10'
        LANGUAGE C
        VOLATILE PARALLEL SAFE;
    ELSE
        -- PostgreSQL 17 below: use blk_read_time, blk_write_time
        CREATE OR REPLACE FUNCTION pg_store_plans(
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
