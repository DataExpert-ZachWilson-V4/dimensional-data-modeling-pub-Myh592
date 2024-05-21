INSERT INTO mymah592.Actors
WITH 
    last_year AS (
        SELECT 
            *
        FROM
            bootcamp.actor_films
        WHERE
            year = 1999
        ),
    This_year AS (
        SELECT
            *
        FROM
            bootcamp.actor_films
        WHERE
            year = 2000
    )

-- COALESCE all the values that are not changing
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
    COALESCE(
        CASE
            WHEN ty.Quality_Class IS NULL and ly.Quality_Class IS NOT NULL THEN 
            CASE
            WHEN ly.Quality_Class > 8 THEN 'Star'
            WHEN ly.Quality_Class > 7 and ly.Quality_Class <= 8 THEN 'Good'
            WHEN ly.Quality_Class > 6 and ly.Quality_Class <= 7 THEN 'Average'
            WHEN ly.Quality_Class <= 6 THEN 'Bad'       
            END 
        When ty.Quality_Class IS NOT NULL and ly.Quality_Class IS NULL THEN
            CASE
            WHEN ty.Quality_Class > 8 THEN 'Star'
            WHEN ty.Quality_Class > 7 and ly.Quality_Class <= 8 THEN 'Good'
            WHEN ty.Quality_Class > 6 and ly.Quality_Class <= 7 THEN 'Average'
            WHEN ty.Quality_Class <= 6 THEN 'Bad'  
            END
        WHEN ty.Quality_Class IS NOT NULL and ly.Quality_Class IS NOT NULL THEN
            CASE
            WHEN ty.Quality_Class > 8 THEN 'Star'
            WHEN ty.Quality_Class > 7 and ly.Quality_Class <= 8 THEN 'Good'
            WHEN ty.Quality_Class > 6 and ly.Quality_Class <= 7 THEN 'Average'
            WHEN ty.Quality_Class <= 6 THEN 'Bad'  
            END
        END,
        'Unrated'
    ) as Quality_Class,
    ty.year IS NOT NULL as is_active,
    COALESCE(ty.year, ly.year + 1) as year
    FROM last_year ly
    FULL OUTER JOIN This_year ty
    ON ly.actor_ID = ty.actor_ID
