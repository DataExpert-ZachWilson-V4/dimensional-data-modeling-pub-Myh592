INSERT INTO mymah592.Actors
WITH 
    last_year AS (
        SELECT 
            Actor,
            actor_ID,
            films,
            quality_class,
            is_active,
            year
        FROM
            mymah592.actors
        WHERE
            current_year = 1999
        ),
    This_year_temp AS (
        SELECT
            actor,
            actor_id,
            year,
            -- Aggregating all films for an actor in one year
            Array_AGG(ROW(
                Year,
                film,
                votes,
                rating,
                film_id
                )) AS Films,
                AVG(rating) as avg_Rating
        FROM
            bootcamp.actor_films
        WHERE
            year = 2000
        GROUP BY
            Actor,
            actor_ID,
            year
    ), 
    This_year as(
        SELECT actor,
        actor_id,
        year,
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
        WHEN ty.year IS NOT NULL and ly.films IS NULL THEN ty.films
       
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

