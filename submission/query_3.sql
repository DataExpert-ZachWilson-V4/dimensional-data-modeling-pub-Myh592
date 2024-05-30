CREATE OR REPLACE TABLE mymah592.actors_history_scd (
    actor VARCHAR,
    quality_class VARCHAR,
    is_active BOOLEAN,
    Start_date INTEGER,
    End_Date   INTEGER,
    current_year INTEGER
)
WITH (
    format ='PARQUET',
partitioning = ARRAY['current_year']
)
