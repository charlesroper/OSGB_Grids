OSGB Grids
==========

A collection of Ordance Survey National Grids in Shapefile (.shp) [OSGB 1936] and GeoJSON (.geojson) [WGS84] formats.

[[Download these files](https://github.com/charlesroper/OSGB_Grids/archive/master.zip)]

25km tile references
--------------------

The 25km set has two published `TILE_REF` forms:

- Letter form: two 100km square letters, then the south-west easting and
  northing offsets in kilometres (`00`, `25`, `50`, or `75`). For example,
  `HP2500` is 25km east and 0km north within square HP.
- Numeric form: one digit each for the 100km easting and northing, then
  1-based 25km indexes. For example, `4413` covers E 400-425km,
  N 450-475km. The numeric form is used for the southern 270 tiles.

The numeric form is valid and is kept as published. Every 25km feature also
has `LETTER_REF`, the equivalent letter code derived from its south-west
corner. For letter-form tiles `LETTER_REF` equals `TILE_REF`. Both 25km
files carry the field; the other tile sizes are unchanged.

Four published `TILE_REF` labels did not match their geometry and were
corrected: `NN7550` to `NN7525`, `NX7550` to `NX7525`, `NY5025` to
`NY5000`, and `HU7550` to `HU5050`.

Rebuilding the 25km files
-------------------------

`sql/25km_letter_ref.sql` derives `LETTER_REF` from each tile's south-west
corner, keeps the published numeric `TILE_REF`, and rebuilds letter-form
`TILE_REF` from geometry. Run it from the repository root with DuckDB and
the spatial extension:

    duckdb < sql/25km_letter_ref.sql

It prints feature, reference, and geometry counts. Export examples are at
the end of the script. Validate any output before replacing the published
files.

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
