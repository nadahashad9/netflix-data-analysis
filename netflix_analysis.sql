-- ***** Display *****
SELECT * FROM netflix;

-- ***** Movies vs TV Shows Count *****
SELECT type,COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- ***** Handle Missing Values *****
UPDATE netflix
SET country = 'Unknown'
WHERE country IS NULL;

UPDATE netflix
SET "cast" = 'Unknown'
WHERE "cast" IS NULL;

UPDATE netflix
SET rating = 'Unknown'
WHERE rating IS NULL;

UPDATE netflix
SET duration = 'Unknown'
WHERE duration IS NULL;

-- ***** Analysis by Year *****
SELECT 
    release_year,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY release_year
ORDER BY release_year;

-- ***** Analysis by Country *****
SELECT 
    TRIM(unnest(string_to_array(country, ','))) AS country_name,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY total_titles DESC;

-- ***** Top Genres *****
SELECT 
    TRIM(unnest(string_to_array(listed_in, ','))) AS genre,
    COUNT(*) AS total
FROM netflix
GROUP BY genre
ORDER BY total DESC
LIMIT 10;

-- ***** Missing Values Count *****
SELECT 
    COUNT(*) FILTER (WHERE director IS NULL) AS missing_director,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE date_added IS NULL) AS missing_date,
    COUNT(*) FILTER (WHERE rating IS NULL) AS missing_rating,
    COUNT(*) FILTER (WHERE duration IS NULL) AS missing_duration
FROM netflix;

-- ***** Duplicates Count *****
SELECT 
    title,
    type,
    COUNT(*) 
FROM netflix
GROUP BY title, type
HAVING COUNT(*) > 1;

-- ***** Remove Duplicates (using ROW_NUMBER) *****
DELETE FROM netflix
WHERE show_id IN (
    SELECT show_id FROM (
        SELECT 
            show_id,
            ROW_NUMBER() OVER (
                PARTITION BY title, type 
                ORDER BY show_id
            ) AS rn
        FROM netflix
    ) t
    WHERE t.rn > 1
);

-- ***** Using ROW_NUMBER top movies per year*****
SELECT *
FROM (
    SELECT 
        title,
        release_year,
        ROW_NUMBER() OVER (
            PARTITION BY release_year 
            ORDER BY title
        ) AS rn
    FROM netflix
    WHERE type = 'Movie'
) t
WHERE rn <= 5;

-- ***** Ranking genres by popularity *****
SELECT 
    genre,
    total_titles,
    RANK() OVER (ORDER BY total_titles DESC) AS genre_rank
FROM (
    SELECT 
        TRIM(unnest(string_to_array(listed_in, ','))) AS genre,
        COUNT(*) AS total_titles
    FROM netflix
    GROUP BY genre
) t;