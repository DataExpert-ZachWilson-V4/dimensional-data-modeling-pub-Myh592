INSERT INTO mymah592.Actors
WITH 
    last_year AS (
        SELECT 
            *
        FROM
            mymah592.actors
        WHERE
            current_year = 1999
        ),
    this_year_temp AS (
        SELECT
            actor,
            actor_id,
            year,
            -- Aggregating all films for an actor in one year
            ARRAY_AGG(ROW(
                year,
                film,
                votes,
                rating,
                film_id
                )) AS films,
            AVG(rating) AS avg_rating
        FROM
            bootcamp.actor_films
        WHERE
            year = 2000
        GROUP BY
            actor,
            actor_id,
            year
    ), 
    this_year AS (
        SELECT 
            actor,
            actor_id,
            year,
            films,
            CASE 
                WHEN avg_rating > 8 THEN 'star'
                WHEN avg_rating > 7 THEN 'good'
                WHEN avg_rating > 6 THEN 'average'
                ELSE 'bad' 
            END AS quality_class
        FROM 
            this_year_temp
    )
-- COALESCE all the values that are not changing to handle NULLS
SELECT
    COALESCE(ly.actor, ty.actor) AS actor,
    COALESCE(ly.actor_id, ty.actor_id) AS actor_id,
    CASE 
        WHEN ty.year IS NULL THEN ly.films 
        WHEN ty.year IS NOT NULL AND ly.films IS NULL THEN 
            ty.films
        WHEN ty.year IS NOT NULL AND ly.films IS NOT NULL THEN
            ty.films || ly.films
    END AS films,
    COALESCE(ty.quality_class, ly.quality_class) AS quality_class,
    ty.year IS NOT NULL AS is_active,
    COALESCE(ty.year, ly.year + 1) AS year
FROM 
    last_year ly
    FULL OUTER JOIN this_year ty
    ON ly.actor_id = ty.actor_id;
