OSGB Grids
==========

Polygon tiles covering Great Britain on the Ordnance Survey National Grid,
at seven tile sizes from 100 km to 1 km. Each size is complete in three
formats: GeoJSON in WGS84 (EPSG:4326), Shapefile in OSGB 1936 / British
National Grid (EPSG:27700), and GeoParquet in OSGB 1936 / British National
Grid (EPSG:27700).

[[Download all tiles (ZIP)](https://github.com/charlesroper/OSGB_Grids/releases/latest/download/OSGB_Grids.zip)]

Files
-----

Each tile size has one GeoJSON file in `GeoJSON/`, one Shapefile set in
`Shapefile/`, and one GeoParquet file in `GeoParquet/`:

| Size  | Features | GeoJSON                        | Shapefile                        | GeoParquet                        | Fields                                                                                                          |
| ----- | -------- | ------------------------------ | -------------------------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 100km | 56       | `OSGB_Grid_100km.geojson`      | `OSGB_Grid_100km.shp`            | `OSGB_Grid_100km.parquet`         | `TILE_NAME`, `250K`                                                                                             |
| 50km  | 163      | `OSGB_Grid_50km.geojson`       | `OSGB_Grid_50km.shp`             | `OSGB_Grid_50km.parquet`          | `TILE_NAME`                                                                                                     |
| 25km  | 537      | `OSGB_Grid_25km.geojson`       | `OSGB_Grid_25km.shp`             | `OSGB_Grid_25km.parquet`          | `TILE_REF`, `LETTER_REF`                                                                                        |
| 20km  | 824      | `OSGB_Grid_20km.geojson`       | `OSGB_Grid_20km.shp`             | `OSGB_Grid_20km.parquet`          | `PLAN_NO`, `50K`, `ENGLAND`, `SCOTLAND`, `WALES`                                                                |
| 10km  | 2886     | `OSGB_Grid_10km.geojson`       | `OSGB_Grid_10km.shp`             | `OSGB_Grid_10km.parquet`          | `TILE_NAME`, `25K`, `ENGLAND`, `SCOTLAND`, `WALES`                                                              |
| 5km   | 10719    | `OSGB_Grid_5km.geojson`        | `OSGB_Grid_5km.shp`              | `OSGB_Grid_5km.parquet`           | `TILE_NAME`, `DATAFOR10K`, `DATAFOROSS`, `DATAFORLFP`, `DATAFORL0`, `DATAFORL1`, `ENGLAND`, `SCOTLAND`, `WALES` |
| 1km   | 286300   | `OSGB_Grid_1km.geojson`        | `OSGB_Grid_1km.shp`              | `OSGB_Grid_1km.parquet`           | `PLAN_NO`                                                                                                       |

A Shapefile set is `.shp .shx .dbf .prj .cpg .qpj`. Keep the parts together.

GeoParquet
----------

Each GeoParquet file is GeoParquet 1.0 with a `geometry` column, ZSTD
compression, and the same fields as its Shapefile. The whole set is 2.3 MB.
Regenerate a file from its Shapefile with DuckDB:

```bash
duckdb -c "
LOAD spatial;
SET geometry_always_xy = true;
COPY (
  SELECT * EXCLUDE (OGC_FID) RENAME (geom AS geometry)
  FROM ST_Read('Shapefile/OSGB_Grid_1km.shp')
) TO 'GeoParquet/OSGB_Grid_1km.parquet' (FORMAT PARQUET, COMPRESSION ZSTD);
"
```

Change `1km` to any tile size. terrio and GDAL write SNAPPY only; DuckDB
is used here for ZSTD.

25km tile references
--------------------

A 25km tile has two `TILE_REF` forms:

- Letter form: the two letters of its 100km square, then the south-west
  easting and northing offsets in kilometres (`00`, `25`, `50`, or `75`).
  For example, `HP2500` is 25km east and 0km north within square HP.
- Numeric form: one digit each for the 100km easting and northing, then
  1-based 25km indexes. For example, `4413` covers E 400-425km,
  N 450-475km.

`LETTER_REF` gives the letter form for every tile. It is derived from the
tile's south-west corner, so for letter-form tiles it equals `TILE_REF`.

Four cells had duplicated or misplaced `TILE_REF` labels; they were
corrected from geometry to `NN7525`, `NX7525`, `NY5000`, and `HU5050`.

Derived fields
--------------

`sql/25km_letter_ref.sql` derives `LETTER_REF` from each tile's south-west
corner. Run it from the repository root with DuckDB and the spatial
extension:

```bash
duckdb < sql/25km_letter_ref.sql
```

It prints feature, reference, and geometry counts. Export examples are at
the end of the script.

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law,
  <a rel="dct:publisher"
     href="https://github.com/charlesroper/OSGB_Grids">
    <span property="dct:title">Charles Roper</span></a>
  has waived all copyright and related or neighboring rights to
  <span property="dct:title">OSGB_Grids</span>.
</p>
