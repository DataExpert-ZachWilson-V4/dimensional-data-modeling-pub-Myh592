INSERT INTO mymah592.actors_history_scd
WITH lagged AS(


Select 
    actor_id,
    is_active,
    quality_class,
LAG(is_active,1 ) OVER (PARTITION BY actor_id ORDER BY current_year) As is_active_last_year,
LAG(quality_class,1 ) OVER (PARTITION by actor_id ORDER BY current_year) as quality_class_last_year,
current_year
From mymah592.actors
WHERE current_year <= 1999
),
-- breaking out streak case statement on its own for neatness
Streaked AS(
SELECT
  *,
  SUM(CASE 
        WHEN (is_active <> is_active_last_year) THEN 1
        WHEN (quality_class <> quality_class_last_year) THEN 1 
      ELSE 0 END)
    OVER(PARTITION BY actor_id ORDER BY current_year) AS Streak_identifier
    FROM lagged
)
-- Determining how many years active as well as which years are start and end of activity 
Select actor_id, Streak_identifier,
    quality_class,
    MAX(is_active) = 1 as is_active, -- this has been changed back into a boolen per WEEK 1 Lab 2
    MIN(current_year) as start_year,
    MAX(current_year) as end_year,
    2000 as current_year
    FROM streaked
    GROUP BY actor_id, Streak_identifier
