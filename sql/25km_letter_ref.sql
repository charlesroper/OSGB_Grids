-- Derive LETTER_REF for the 25km OSGB grid from tile geometry.
--
-- Run from the repository root:
--   duckdb < sql/25km_letter_ref.sql
--
-- Rules:
--   * LETTER_REF is the 100km square pair plus the south-west offset in km
--     (00, 25, 50, 75), derived from the polygon's south-west corner.
--   * Numeric TILE_REF (four digits) is published data and is kept.
--   * Letter-form TILE_REF is rebuilt from geometry, which corrects labels
--     that do not match their cell.
--
-- Expected result: 537 features, 537 unique TILE_REF, 537 unique LETTER_REF,
-- 0 invalid geometries.

LOAD spatial;

CREATE OR REPLACE TEMP TABLE fixed_25km AS
WITH letters(e, n, l) AS (
    VALUES
        (0, 0, 'V'), (1, 0, 'W'), (2, 0, 'X'), (3, 0, 'Y'), (4, 0, 'Z'),
        (0, 1, 'Q'), (1, 1, 'R'), (2, 1, 'S'), (3, 1, 'T'), (4, 1, 'U'),
        (0, 2, 'L'), (1, 2, 'M'), (2, 2, 'N'), (3, 2, 'O'), (4, 2, 'P'),
        (0, 3, 'F'), (1, 3, 'G'), (2, 3, 'H'), (3, 3, 'J'), (4, 3, 'K'),
        (0, 4, 'A'), (1, 4, 'B'), (2, 4, 'C'), (3, 4, 'D'), (4, 4, 'E')
),
base AS (
    SELECT
        TILE_REF,
        LETTER_REF,
        round(ST_XMin(geom)) AS x,
        round(ST_YMin(geom)) AS y,
        geom
    FROM ST_Read('Shapefile/OSGB_Grid_25km.shp')
),
calc AS (
    SELECT
        *,
        floor(x / 500000)::INT AS e500,
        floor(y / 500000)::INT AS n500,
        floor((x % 500000) / 100000)::INT AS e100,
        floor((y % 500000) / 100000)::INT AS n100,
        floor((x % 100000) / 25000)::INT AS e25,
        floor((y % 100000) / 25000)::INT AS n25
    FROM base
),
named AS (
    SELECT
        c.*,
        CASE
            WHEN n500 = 0 AND e500 = 0 THEN 'S'
            WHEN n500 = 0 AND e500 = 1 THEN 'T'
            WHEN n500 = 1 AND e500 = 0 THEN 'N'
            WHEN n500 = 1 AND e500 = 1 THEN 'O'
            WHEN n500 = 2 AND e500 = 0 THEN 'H'
            WHEN n500 = 2 AND e500 = 1 THEN 'J'
        END AS first_letter,
        l.l AS second_letter
    FROM calc c
    JOIN letters l ON l.e = c.e100 AND l.n = c.n100
)
SELECT
    CASE
        WHEN TILE_REF ~ '^[0-9]{4}$' THEN TILE_REF
        ELSE first_letter || second_letter || printf('%02d%02d', e25 * 25, n25 * 25)
    END AS TILE_REF,
    first_letter || second_letter || printf('%02d%02d', e25 * 25, n25 * 25) AS LETTER_REF,
    geom
FROM named;

SELECT
    count(*) AS features,
    count(*) FILTER (WHERE TILE_REF ~ '^[0-9]{4}$') AS numeric_refs,
    count(*) FILTER (WHERE TILE_REF ~ '^[A-Z]{2}[0-9]{4}$') AS letter_refs,
    count(DISTINCT TILE_REF) AS unique_refs,
    count(DISTINCT LETTER_REF) AS unique_letters,
    count(*) FILTER (WHERE NOT ST_IsValid(geom)) AS invalid_geometries
FROM fixed_25km;

-- Export examples (run manually; write outside the repo or to a build dir):
--
--   SET geometry_always_xy = true;
--   COPY (SELECT * FROM fixed_25km) TO 'build/OSGB_Grid_25km.shp'
--     WITH (FORMAT GDAL, DRIVER 'ESRI Shapefile', SRS 'EPSG:27700');
--   COPY (
--     SELECT TILE_REF, LETTER_REF,
--            ST_Transform(geom, 'EPSG:27700', 'EPSG:4326') AS geom
--     FROM fixed_25km
--   ) TO 'build/OSGB_Grid_25km.geojson'
--     WITH (FORMAT GDAL, DRIVER 'GeoJSON', SRS 'EPSG:4326');
--
-- A COPY SRS label does not reproject; transform the geometry explicitly.
