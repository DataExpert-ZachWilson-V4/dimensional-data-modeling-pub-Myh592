INSERT INTO mymah592.Actors
WITH 
    last_year AS (
        SELECT 
            Actor,
            actor_ID,
            films,
            quality_class,
            is_active           
        FROM
            mymah592.actors
        WHERE
            current_year = 1999
        ),
    This_year_temp AS (
        SELECT
            a.actor,
            a.actor_id,
            year,
            -- Aggregating all films for an actor in one year
            Array_AGG(ROW(
                a.Year,
                a.film,
                a.votes,
                a.rating,
                a.film_id
                )) AS Films,
                AVG(a.rating) as avg_Rating
        FROM
            bootcamp.actor_films a
        WHERE
            a.year = 2000
        GROUP BY
            a.Actor,
            a.actor_ID,
            a.year
    ), -- temporary table set up data then averages calculated in following. 
    This_year as(
        SELECT actor,
        actor_id,
        year,
        film,
        films,
        Case when avg_Rating > 8 THEN 'star'
        when avg_Rating > 7 then 'Good'
        when avg_Rating > 6 then 'average'
        else 'bad' end as quality_class
        from This_year_temp

    )

-- COALESCE all the values that are not changing to handle NULLS
    SELECT
    COALESCE(ly.actor, ty.actor) as actor,
    COALESCE(ly.actor_ID, ty.actor_ID) as actor_ID,
    CASE 
        WHEN ty.year IS NULL THEN ly.films 
        WHEN ty.year IS NOT NULL and ly.films IS NULL THEN 
        Array[
            ROW(
            ty.year, 
            ty.film,
            ty.votes,
            ty.rating,
            ty.film_id
            )
        ]
        WHEN ty.year IS NOT NULL and ly.films IS NOT NULL THEN
        Array[
            ROW(
            ty.year,
            ty.film,
            ty.votes,
            ty.rating,
            ty.film_id
            )
            ] || ly.films
        END as films,
    COALESCE(ty.quality_class, ly.quality_class) as quality_class,
    ty.year IS NOT NULL as is_active,
    COALESCE(ty.year, ly.year + 1) as year
    FROM last_year ly
    FULL OUTER JOIN This_year ty
    ON ly.actor_ID = ty.actor_ID

