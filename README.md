OSGB Grids
==========

Polygon tiles covering Great Britain on the Ordnance Survey National Grid,
at seven tile sizes from 100 km to 1 km. Each size is complete in two
formats: GeoJSON in WGS84 (EPSG:4326) and Shapefile in OSGB 1936 / British
National Grid (EPSG:27700).

[[Download all tiles (ZIP)](https://github.com/charlesroper/OSGB_Grids/releases/latest/download/OSGB_Grids.zip)]

Files
-----

Each tile size has one GeoJSON file in `GeoJSON/` and one Shapefile set in
`Shapefile/`:

| Size  | Features | GeoJSON                        | Shapefile                        | Fields                                                                                                          |
| ----- | -------- | ------------------------------ | -------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 100km | 56       | `OSGB_Grid_100km.geojson`      | `OSGB_Grid_100km.shp`            | `TILE_NAME`, `250K`                                                                                             |
| 50km  | 163      | `OSGB_Grid_50km.geojson`       | `OSGB_Grid_50km.shp`             | `TILE_NAME`                                                                                                     |
| 25km  | 537      | `OSGB_Grid_25km.geojson`       | `OSGB_Grid_25km.shp`             | `TILE_REF`, `LETTER_REF`                                                                                        |
| 20km  | 824      | `OSGB_Grid_20km.geojson`       | `OSGB_Grid_20km.shp`             | `PLAN_NO`, `50K`, `ENGLAND`, `SCOTLAND`, `WALES`                                                                |
| 10km  | 2883     | `OSGB_Grid_10km.geojson`       | `OSGB_Grid_10km.shp`             | `TILE_NAME`, `25K`, `ENGLAND`, `SCOTLAND`, `WALES`                                                              |
| 5km   | 10707    | `OSGB_Grid_5km.geojson`        | `OSGB_Grid_5km.shp`              | `TILE_NAME`, `DATAFOR10K`, `DATAFOROSS`, `DATAFORLFP`, `DATAFORL0`, `DATAFORL1`, `ENGLAND`, `SCOTLAND`, `WALES` |
| 1km   | 286000   | `OSGB_Grid_1km.geojson`        | `OSGB_Grid_1km.shp`              | `PLAN_NO`                                                                                                       |

A Shapefile set is `.shp .shx .dbf .prj .cpg .qpj`. Keep the parts together.

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

Derived fields
--------------

`sql/25km_letter_ref.sql` derives `LETTER_REF` from each tile's south-west
corner. Run it from the repository root with DuckDB and the spatial
extension:

    duckdb < sql/25km_letter_ref.sql

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
